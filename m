From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] net: make skb_gso_segment error handling more
 robust
Date: Sun, 19 Oct 2014 20:39:43 -0400 (EDT)
Message-ID: <20141019.203943.579204096575757665.davem@davemloft.net>
References: <1413751340-19621-1-git-send-email-fw@strlen.de>
	<1413751340-19621-3-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56974 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751888AbaJTBAI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Oct 2014 21:00:08 -0400
In-Reply-To: <1413751340-19621-3-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Sun, 19 Oct 2014 22:42:19 +0200

> skb_gso_segment has three possible return values:
> 1. a pointer to the first segmented skb
> 2. an errno value (IS_ERR())
> 3. NULL.  This can happen when GSO is used for header verification.
> 
> However, several callers currently test IS_ERR instead of IS_ERR_OR_NULL
> and would oops when NULL is returned.
> 
> Note that these call sites should never actually see such a NULL return
> value; all callers mask out the GSO bits in the feature argument.
> 
> However, in the past, there have been issues with some protocol handlers
> erronously not respecting the specified feature mask in some cases.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

I don't think it makes sense to return PTR_ERR(p) when
p is NULL.
