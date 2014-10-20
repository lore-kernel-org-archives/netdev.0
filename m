From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/3] net: minor gso encapsulation fixes
Date: Mon, 20 Oct 2014 14:04:09 -0400 (EDT)
Message-ID: <20141020.140409.651849137033134113.davem@davemloft.net>
References: <1413805758-30026-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, therbert@google.com
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37353 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751102AbaJTSEP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2014 14:04:15 -0400
In-Reply-To: <1413805758-30026-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Mon, 20 Oct 2014 13:49:15 +0200

> The following series fixes a minor bug in the gso segmentation handlers
> when encapsulation offload is used.
> 
> Theoretically this could cause kernel panic when the stack tries
> to software-segment such a GRE offload packet, but it looks like there
> is only one affected call site (tbf scheduler) and it handles NULL
> return value.
> 
> I've included a followup patch to add IS_ERR_OR_NULL checks where needed.
> 
> While looking into this, I also found that size computation of the individual
> segments is incorrect if skb->encapsulation is set.
> 
> Please see individual patches for delta vs. v1.

Series applied, thanks Florian.

Longer term I'd really like to see the ops->gso_segment() implementations not
return NULL, but rather locally determinned pointer error codes instead.
