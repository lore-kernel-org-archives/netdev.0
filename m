From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] Prevent netpoll hanging when link is down
Date: Thu, 7 Oct 2004 20:43:00 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041007184259.GA25071@wotan.suse.de>
References: <20041006232544.53615761@jack.colino.net> <20041006214322.GG31237@waste.org> <20041007075319.6b31430d@jack.colino.net> <20041006234912.66bfbdcc.davem@davemloft.net> <20041007160532.60c3f26b@pirandello> <20041007112846.5c85b2d9.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Colin Leroy <colin@colino.net>, mpm@selenic.com, akpm@osdl.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041007112846.5c85b2d9.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Oct 07, 2004 at 11:28:46AM -0700, David S. Miller wrote:
> On Thu, 7 Oct 2004 16:05:32 +0200
> Colin Leroy <colin@colino.net> wrote:
> 
> > First, my newbie question: is it possible to deadlock a spinlock on a
> > Uniprocessor kernel ? For example, there's something I find suspect in
> > netpoll/sungem interaction:
> > 
> 
> Oh yes, it appears that netpoll doesn't support NETIF_F_LLTX locking,
> crap :(
> 
> When a device has NETIF_F_LLTX set, it means that the driver's
> dev->hard_start_xmit() routine is what takes the xmit_lock, not
> the caller one level up.

It takes an own lock, not xmit_lock.

It's fine to ignore it completely.  In the worst case the poll
will not be retried, but netpoll has no way to do that anyways I think.

-Andi
