From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] cls_u32: use skb_header_pointer() to dereference
 data safely
Date: Wed, 02 Jun 2010 07:15:10 -0700 (PDT)
Message-ID: <20100602.071510.255391809.davem@davemloft.net>
References: <1275487236-14452-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59350
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755062Ab0FBOPA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 10:15:00 -0400
In-Reply-To: <1275487236-14452-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Wed,  2 Jun 2010 22:00:36 +0800

> use skb_header_pointer() to dereference data safely
> 
> the original skb->data dereference isn't safe, as there isn't any skb->len or
> skb_is_nonlinear() check. skb_header_pointer() is used instead in this patch.
> And when the skb isn't long enough, we terminate the function u32_classify()
> immediately with -1. Unaligned access is also fixed.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

Please don't do so many things at once Changli.

Everything is fine except the get_unaligned() addition.  It's
intentionally not there, and by adding the get_unaligned() you're
going to kill performance as this expands to 4 byte loads per u32 key
check on RISC systems.

If it's not aligned, that's a path or configuration that will need to
be fixed up such that the accesses are aligned.

Please respin this patch with the get_unaligned() part removed.

Thanks.
