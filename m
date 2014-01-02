From: David Miller <davem@davemloft.net>
Subject: Re: [Patch v2] ipv6: mld: Prevent skb_over_panic with large MTUs
Date: Wed, 01 Jan 2014 23:30:22 -0500 (EST)
Message-ID: <20140101.233022.923203259739709098.davem@davemloft.net>
References: <1387586456-25892-1-git-send-email-travisb@aristanetworks.com>
	<1387840581-10995-1-git-send-email-travisb@aristanetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: travisb@aristanetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46389 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750762AbaABEaX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jan 2014 23:30:23 -0500
In-Reply-To: <1387840581-10995-1-git-send-email-travisb@aristanetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Travis Brown <travisb@aristanetworks.com>
Date: Mon, 23 Dec 2013 15:16:21 -0800

> MLD limits the maximum skb size to fit within a single page. Later
> code uses the device MTU, if available, to determine whether the skb
> has sufficient room for another field. On interfaces with MTUs larger
> than the page size, less the skb overhead, this can result in the skb
> being overrun and a skb_over_panic being generated.
> 
> Use skb_availroom() instead of MTU check.
> 
> Signed-off-by: Travis Brown <travisb@aristanetworks.com>
> Fixes: 72e09ad107e78 ("ipv6: avoid high order allocations")

I would rather that you, for consistency, mimick what the ipv4
multicast code does, which is:

1) Try the requested size, no matter how large, then progressively
   try smaller sizes.

2) Store the obtained size in the SKB control block.

Thanks.
