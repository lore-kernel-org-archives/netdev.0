From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] Prevent netpoll hanging when link is down
Date: Mon, 11 Oct 2004 17:40:00 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041011154000.GB26350@wotan.suse.de>
References: <20041007075319.6b31430d@jack.colino.net> <20041006234912.66bfbdcc.davem@davemloft.net> <20041007160532.60c3f26b@pirandello> <20041007112846.5c85b2d9.davem@davemloft.net> <20041007224422.1c1bea95@jack.colino.net> <20041007214505.GB31558@wotan.suse.de> <20041008090610.70d7e183@pirandello> <20041008220001.GE31237@waste.org> <20041008151839.01823e0c.akpm@osdl.org> <20041010205928.6e54df7e.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, mpm@selenic.com, colin@colino.net,
        ak@suse.de, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041010205928.6e54df7e.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Oct 10, 2004 at 08:59:28PM -0700, David S. Miller wrote:
> 
> Wait, I think I see the problem.
> 
> Sungem processes link status in it's ->poll() NAPI handler.
> This occurs via calls to gem_pcs_interrupt(), for example.
> Non-pcs sungem variants use a timer to poll link status.
> 
> When the link changes state, this link state processing
> does printk()'s.
> 
> So perhaps that is why it deadlocks.

printk handles recursion with the down_trylock on console_sem.
So it shouldn't deadlock.

-Andi
