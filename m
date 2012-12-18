From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH] ipv6 multicast forwarding: Remove threshold
 checking and some trivial bugs
Date: Mon, 17 Dec 2012 21:03:33 -0800 (PST)
Message-ID: <20121217.210333.1952508082741483861.davem@davemloft.net>
References: <50CFF7A7.1070508@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: wcang@sfc.wide.ad.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55120 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750852Ab2LRFDe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2012 00:03:34 -0500
In-Reply-To: <50CFF7A7.1070508@sfc.wide.ad.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ang Way Chuang <wcang@sfc.wide.ad.jp>
Date: Tue, 18 Dec 2012 12:57:11 +0800

> This patch fixes trivial bugs for IPv6 multicast forwarding code and remove
> threshold checking for multicast forwarding cache.
> 
> 1. Threshold checking in IPv6 multicast forwarding cache (MFC) was not properly implemented.
> syscall to setsockopt(... MRT6_ADD_MIF,...) doesn't affect the TTL because it is never used.
> In fact, all MFC will always have ttl of 1 as set by ip6mr_mfc_add. From my limited knowledge of
> multicast routing, threshold setting on interface is only used by DVMRP which doesn't support
> IPv6. FreeBSD's struct mif6ctl doesn't have vifc_threshold. This patch removes the ttl cruft
> within kernel. Userspace ABI for backward compatibility. Can someone knowledgable in multicast
> routing please verify whether my understanding is correct?
> 2. Don't allow addition of MFC with non-existent multicast interface index.
> 3. Don't allow addition of MFC where incoming interface is part of oif list. This does not make
>    sense. Why would we want to send a multicast back to the interface where it originates from.
> 4. setsockopt(....MRT6_ADD_MIF, ) allows a "physical" interface to be registered as multicast 
>    interface multiple times. This doesn't make sense. Don't allow registration duplicate 
>    registration of the same "physical" interface. 
> 
> This patch has been tested, albeit minimally using a simple program. Is this patch okay for
> inclusion? Will sign off if it is okay.

How about we don't mix together a set of bug fixes, with a semantic
change (the removal of the threshold checking)?

I also don't see what the point is of not signing off on this change
when you submit it.

If you delay the signoff until after review, you're just causing it to
take longer to have your changes integrated.  It also makes it look
like you didn't believe fully in your change, so you probably should
have sent it as an RFC and listed your doubts in the email instead.

Overall I would rate this as an extremely poor patch submission,
sorry.
