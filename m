From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/7] [XFRM] user: Move attribute copying code into
 copy_to_user_state_extra
Date: Tue, 09 Oct 2007 13:31:07 -0700 (PDT)
Message-ID: <20071009.133107.98747322.davem@davemloft.net>
References: <20071009143517.GA20486@gondor.apana.org.au>
	<E1IfGCJ-0005MD-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38184
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753643AbXJIUbH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 16:31:07 -0400
In-Reply-To: <E1IfGCJ-0005MD-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 09 Oct 2007 22:36:35 +0800

> [XFRM] user: Move attribute copying code into copy_to_user_state_extra
> 
> Here's a good example of code duplication leading to code rot.  The
> notification patch did its own netlink message creation for xfrm states.
> It duplicated code that was already in dump_one_state.  Guess what, the
> next time (and the time after) when someone updated dump_one_state the
> notification path got zilch.
> 
> This patch moves that code from dump_one_state to copy_to_user_state_extra
> and uses it in xfrm_notify_sa too.  Unfortunately whoever updates this
> still needs to update xfrm_sa_len since the notification path wants to
> know the exact size for allocation.
> 
> At least I've added a comment saying so and if someone still forgest, we'll
> have a WARN_ON telling us so.
> 
> I also changed the security size calculation to use xfrm_user_sec_ctx since
> that's what we actually put into the skb.  However it makes no practical
> difference since it has the same size as xfrm_sec_ctx.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks!
