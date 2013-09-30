From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/2] ip_tunnel: Fix a memory corruption in
 ip_tunnel_xmit
Date: Mon, 30 Sep 2013 14:40:26 -0400 (EDT)
Message-ID: <20130930.144026.652414415839724107.davem@davemloft.net>
References: <CALnjE+ofaXQa3gsPPxqdWZeBxgML6M1vnC9mmc5dufwy0gJO-Q@mail.gmail.com>
	<20130927074530.GD7660@secunet.com>
	<CALnjE+pkaAwiSp_S=TE70L+QvyZr1TzEC48Dnz9+8Hy3fbnOyQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35073 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755776Ab3I3Sk2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Sep 2013 14:40:28 -0400
In-Reply-To: <CALnjE+pkaAwiSp_S=TE70L+QvyZr1TzEC48Dnz9+8Hy3fbnOyQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin Shelar <pshelar@nicira.com>
Date: Fri, 27 Sep 2013 19:34:59 -0700

> All callers of iptunnel_xmit() are required to setup sufficient
> headroom. So skb_push check are not necessary.

This bug shows that such a check is needed, and would have saved
people like Steffen lots of time tracking down the problem.

I think we should re-instate the check.

I also think that __skb_push() is quite dangerous, in general.  And if
it is to be used at all, it should only be used in circumstances where
all of the context necessary to assert that it cannot underflow the
buffer are right there in the same function.

In fact, the whole damn reason for the assertions in skb_push() is the
catch cases where preconditions are not met across functional
boundaries.  Exactly like the case here.

So again, __skb_push() should be changed back to skb_push() here.

Steffen can you respin these patches and make sure to:

1) Add reference to SHA1_ID and commit header line of commit
   introducing this bug, as Eric requested, in this format:

	$SHA1_ID ("Commit header line text.")

2) __skb_push() --> skb_push()

Thank you.
