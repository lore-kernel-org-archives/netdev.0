From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH] Prevent netpoll hanging when link is down
Date: Mon, 11 Oct 2004 11:36:01 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041011163601.GM31237@waste.org>
References: <20041007112846.5c85b2d9.davem@davemloft.net> <20041007224422.1c1bea95@jack.colino.net> <20041007214505.GB31558@wotan.suse.de> <20041008090610.70d7e183@pirandello> <20041008220001.GE31237@waste.org> <20041008151839.01823e0c.akpm@osdl.org> <20041010205928.6e54df7e.davem@davemloft.net> <20041011154000.GB26350@wotan.suse.de> <20041011162224.GL31237@waste.org> <20041011163226.GG26350@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, Andrew Morton <akpm@osdl.org>,
        colin@colino.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
Content-Disposition: inline
In-Reply-To: <20041011163226.GG26350@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Oct 11, 2004 at 06:32:26PM +0200, Andi Kleen wrote:
> On Mon, Oct 11, 2004 at 11:22:24AM -0500, Matt Mackall wrote:
> > On Mon, Oct 11, 2004 at 05:40:00PM +0200, Andi Kleen wrote:
> > > On Sun, Oct 10, 2004 at 08:59:28PM -0700, David S. Miller wrote:
> > > > 
> > > > Wait, I think I see the problem.
> > > > 
> > > > Sungem processes link status in it's ->poll() NAPI handler.
> > > > This occurs via calls to gem_pcs_interrupt(), for example.
> > > > Non-pcs sungem variants use a timer to poll link status.
> > > > 
> > > > When the link changes state, this link state processing
> > > > does printk()'s.
> > > > 
> > > > So perhaps that is why it deadlocks.
> > > 
> > > printk handles recursion with the down_trylock on console_sem.
> > > So it shouldn't deadlock.
> > 
> > If we're in the ->poll() handler for non-netpoll reasons, and the link
> > state changes, causing a printk, we'll potentially reenter ->poll() via
> > netconsole.
> 
> It won't because printk catches the case.

It's not recursion on printk that's a problem, it's recursion on
->poll() and attempting to take whatever internal driver locks.

-- 
Mathematics is the supreme nostalgia of our time.
