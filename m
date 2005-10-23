From: Ben Greear <greearb@candelatech.com>
Subject: Re: [3/3] [NEIGH] Fix timer leak in neigh_changeaddr
Date: Sun, 23 Oct 2005 11:00:17 -0700
Message-ID: <435BCFB1.4010109@candelatech.com>
References: <43534273.2050106@reub.net> <E1ETaJB-0004a0-00@gondolin.me.apana.org.au> <20051023073331.GC17626@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Reuben Farrelly <reuben-lkml@reub.net>, akpm@osdl.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	acme@conectiva.com.br, davem@davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750813AbVJWSAv@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20051023073331.GC17626@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> [NEIGH] Fix timer leak in neigh_changeaddr
> 
> neigh_changeaddr attempts to delete neighbour timers without setting
> nud_state.  This doesn't work because the timer may have already fired
> when we acquire the write lock in neigh_changeaddr.  The result is that
> the timer may keep firing for quite a while until the entry reaches
> NEIGH_FAILED.
> 
> It should be setting the nud_state straight away so that if the timer
> has already fired it can simply exit once we relinquish the lock.
> 
> In fact, this whole function is simply duplicating the logic in
> neigh_ifdown which in turn is already doing the right thing when
> it comes to deleting timers and setting nud_state.
> 
> So all we have to do is take that code out and put it into a common
> function and make both neigh_changeaddr and neigh_ifdown call it.

Thanks for all who reproduced and fixed this...I'm glad to know I wasn't
insane when I first tried to fix it and then couldn't reproduce
the problem anymore! :)

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
