From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH] Prevent netpoll hanging when link is down
Date: Mon, 11 Oct 2004 11:58:52 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041011165851.GN31237@waste.org>
References: <20041007214505.GB31558@wotan.suse.de> <20041008090610.70d7e183@pirandello> <20041008220001.GE31237@waste.org> <20041008151839.01823e0c.akpm@osdl.org> <20041010205928.6e54df7e.davem@davemloft.net> <20041011154000.GB26350@wotan.suse.de> <20041011162224.GL31237@waste.org> <20041011163226.GG26350@wotan.suse.de> <20041011163601.GM31237@waste.org> <20041011164315.GH26350@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, Andrew Morton <akpm@osdl.org>,
        colin@colino.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
Content-Disposition: inline
In-Reply-To: <20041011164315.GH26350@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Oct 11, 2004 at 06:43:15PM +0200, Andi Kleen wrote:
> > It's not recursion on printk that's a problem, it's recursion on
> > ->poll() and attempting to take whatever internal driver locks.
> 
> There is no recursion on poll because printk will never call into
> the low level console driver when the console sem is already taken.

Ergh, you deleted the context. Again, imagine we're originally in
->poll() for _a non-netpoll-related reason_. In other words, the
console sem is not taken, because we're just doing routine network
I/O. While in poll(), we take a private driver lock. Then for whatever
reason, we printk -> netconsole -> netpoll -> poll() again where we
attempt to retake the private driver lock.

> P.S.: I made the same mistake long ago, but akpm set me straight.

I'm pretty sure this case is different.

-- 
Mathematics is the supreme nostalgia of our time.
