From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/7] [IPSEC]: Lock state when copying non-atomic fields
 to user-space
Date: Tue, 09 Oct 2007 13:33:07 -0700 (PDT)
Message-ID: <20071009.133307.88477317.davem@davemloft.net>
References: <20071009143517.GA20486@gondor.apana.org.au>
	<E1IfGCK-0005ML-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38031
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753443AbXJIUdH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 16:33:07 -0400
In-Reply-To: <E1IfGCK-0005ML-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 09 Oct 2007 22:36:36 +0800

> [IPSEC]: Lock state when copying non-atomic fields to user-space
> 
> This patch adds locking so that when we're copying non-atomic fields such as
> life-time or coaddr to user-space we don't get a partial result.
> 
> For af_key I've changed every instance of pfkey_xfrm_state2msg apart from
> expiration notification to include the keys and life-times.  This is in-line
> with XFRM behaviour.
> 
> The actual cases affected are:
> 
> * pfkey_getspi: No change as we don't have any keys to copy.
> * key_notify_sa:
> 	+ ADD/UPD: This wouldn't work otherwise.
> 	+ DEL: It can't hurt.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.

I would be more careful with the changelog description for
something like this in the future.  It sounds like this
patch will cause us to touch userspace with locks held,
which obviously only works in very limited scenerios
and is usually a BUG.

But you're actually just constructing SKB response netlink
bits, which later will be copied into userspace but long
after we've released these locks.
