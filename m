From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH] Prevent netpoll hanging when link is down
Date: Fri, 8 Oct 2004 17:00:01 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041008220001.GE31237@waste.org>
References: <20041006232544.53615761@jack.colino.net> <20041006214322.GG31237@waste.org> <20041007075319.6b31430d@jack.colino.net> <20041006234912.66bfbdcc.davem@davemloft.net> <20041007160532.60c3f26b@pirandello> <20041007112846.5c85b2d9.davem@davemloft.net> <20041007224422.1c1bea95@jack.colino.net> <20041007214505.GB31558@wotan.suse.de> <20041008090610.70d7e183@pirandello>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, "David S. Miller" <davem@davemloft.net>,
        akpm@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Colin Leroy <colin@colino.net>
Content-Disposition: inline
In-Reply-To: <20041008090610.70d7e183@pirandello>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Oct 08, 2004 at 09:06:10AM +0200, Colin Leroy wrote:
> On 07 Oct 2004 at 23h10, Andi Kleen wrote:
> 
> Hi, 
> 
> > > This patch should do that. It works OK for me, but I'd like it
> > > checked before sent upstream...
> > > 
> > > However, it doesn't fix the hang. it looks like this hang is really
> > > coming from sungem.
> > 
> > IMHO it's not needed. Taking xmit_lock is harmless even when
> > the NETIF_F_LLTX flag is set. 
> 
> Should that be completely dropped, or is it still ok ? (I think
> differenciating action based on hard_start_xmit status, that is, don't
> goto repeat undefinitely when NETDEV_TX_BUSY, could be a good idea).
> I mean, should I rework that patch, forget about it or leave it as-is?

Well the purpose of the LLTX flag is to reduce serializing on the
xmit_lock. If we take the lock anyway, that should be harmless as Andi
says. So I'm afraid it looks to be a performance fix at best (which is
a low priority here). Let's back burner it for now.
 
> Concerning the hang, I see that Andrew has put my first patch, the one
> checking for netif_carrier_ok(), in his tree. Is it an OK solution from
> your (net dev hackers) point of view?

It seems to be papering over a driver bug of some sort, which is not
the way we like to fix things.

-- 
Mathematics is the supreme nostalgia of our time.
