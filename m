From: David Miller <davem@davemloft.net>
Subject: Re: Revert 462fb2af9788a82a534f8184abfde31574e1cfa0 (bridge :
 Sanitize skb before it enters the IP stack)
Date: Thu, 29 May 2014 15:34:24 -0700 (PDT)
Message-ID: <20140529.153424.1310751217059624351.davem@davemloft.net>
References: <53803488.6000400@davidnewall.com>
	<20140524.134356.992924324126016022.davem@davemloft.net>
	<53815623.8020506@davidnewall.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bdschuym@pandora.be, fw@strlen.de, stephen@networkplumber.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	bridge@lists.linux-foundation.org, bsd@redhat.com,
	vyasevich@gmail.com
To: davidn@davidnewall.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47151 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751329AbaE2WeZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2014 18:34:25 -0400
In-Reply-To: <53815623.8020506@davidnewall.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Newall <davidn@davidnewall.com>
Date: Sun, 25 May 2014 12:02:03 +0930

> +	pskb_trim_rcsum(skb, len);

You really need to check the return value as this can perform allocations,
GFP_ATOMIC ones in fact.

Also, why are we not bumping the statistics any more?  I didn't see a
discussion of that in this thread.
