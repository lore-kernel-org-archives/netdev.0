From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC] net: add alloc_skb_mustcopy() to make clone copy
Date: Tue, 20 Oct 2009 00:52:47 -0700 (PDT)
Message-ID: <20091020.005247.59537364.davem@davemloft.net>
References: <4ADD5666.9090409@goop.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: jeremy@goop.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42698
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751134AbZJTHwZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 03:52:25 -0400
In-Reply-To: <4ADD5666.9090409@goop.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeremy Fitzhardinge <jeremy@goop.org>
Date: Tue, 20 Oct 2009 15:19:18 +0900

> When doing network IO on behalf of guests, a Xen dom0 kernel gets granted
> pages from guests.  These pages cannot be released normally, so we must
> handle releasing them specially, which can do with a skb_destructor.
> 
> This is complicated by the fact that the lifetime of an skb's
> frags can be extended via cloning.  To address this, this patch adds
> alloc_skb_mustcopy() which allocates an skb with fclone==SKB_MUST_COPY.
> If skb_clone() sees an skb with this set, it simply calls skb_copy
> instead so that there are no aliases to the granted pages.
> 
> /* Signed-off-by: Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com> */

This looks perfectly fine to me.

Let me know if it actually works out for you and we can merge
this.
