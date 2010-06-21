From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gainfar.c : skb_over_panic
Date: Mon, 21 Jun 2010 13:47:33 -0700 (PDT)
Message-ID: <20100621.134733.115953029.davem@davemloft.net>
References: <4C1A4E36.5060902@extricom.com>
	<20100617.122030.112600189.davem@davemloft.net>
	<4C1F2D39.9050804@extricom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: galak@kernel.crashing.org, netdev@vger.kernel.org
To: liberty@extricom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52963
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758169Ab0FUUrV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jun 2010 16:47:21 -0400
In-Reply-To: <4C1F2D39.9050804@extricom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eran Liberty <liberty@extricom.com>
Date: Mon, 21 Jun 2010 12:13:29 +0300

> I have compared the suggested patch with what the function
> skb_recycle_check() does. Both patch and skb_recycle_check()
> have skb_reset_tail_pointer(). While the patch zero only skb->len,
> skb_recycle_check()
> clears the whole skb (up to tail). On top of that skb_recycle_check()
> preforms a whole set of other checks and cleanups. The question is,
> which action is MORE correct: the pin-point action of the patch
> suggested or the broader checks of skb_recycle_check() function?

At this stage in the code we know exactly what modifications, if any,
we've made to the SKB state.  Therefore it makes sense to only fix
up the tiny amount of changes we've made instead of doing a complete
skb_recycle_call() which seems entirely excessive in this situation.
