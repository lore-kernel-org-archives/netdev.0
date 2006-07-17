From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix slab corruption with netem (2nd try)
Date: Sun, 16 Jul 2006 19:02:06 -0700 (PDT)
Message-ID: <20060716.190206.18580391.davem@davemloft.net>
References: <44BAB60F.7060600@yahoo.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:61651
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932185AbWGQCBu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Jul 2006 22:01:50 -0400
To: guichaz@yahoo.fr
In-Reply-To: <44BAB60F.7060600@yahoo.fr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Guillaume Chazarain <guichaz@yahoo.fr>
Date: Sun, 16 Jul 2006 23:56:31 +0200

> CONFIG_DEBUG_SLAB found the following bug:
> netem_enqueue() in sch_netem.c gets a pointer inside a slab object:
> struct netem_skb_cb *cb = (struct netem_skb_cb *)skb->cb;
> But then, the slab object may be freed:
> skb = skb_unshare(skb, GFP_ATOMIC)
> cb is still pointing inside the freed skb, so here is a patch to
> initialize cb later, and make it clear that initializing it sooner
> is a bad idea.
> 
> [From Stephen Hemminger: leave cb unitialized in order to let gcc
> complain in case of use before initialization]

Looks good to me, applied, thanks a lot.
