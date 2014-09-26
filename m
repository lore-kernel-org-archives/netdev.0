From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fec: remove memory copy for rx path
Date: Fri, 26 Sep 2014 17:07:20 -0400 (EDT)
Message-ID: <20140926.170720.2230061639326332503.davem@davemloft.net>
References: <1411538730-31480-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: b20596@freescale.com, netdev@vger.kernel.org, shawn.guo@linaro.org,
	bhutchings@solarflare.com
To: b38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51424 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755770AbaIZVHX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2014 17:07:23 -0400
In-Reply-To: <1411538730-31480-1-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fugang Duan <b38611@freescale.com>
Date: Wed, 24 Sep 2014 14:05:30 +0800

> Re-allocate skb instead of memory copy skb data in rx path to improve
> enet rx performance.
> 
> Signed-off-by: Fugang Duan <B38611@freescale.com>
> Signed-off-by: Frank Li <Frank.Li@freescale.com>

For small packet sizes, copying is almost certainly faster and it avoids
mismatched skb->truesize vs. skb->len which hurts TCP performance.

We call this rx_copybreak, and there are many drivers you can look at
to see how this works.

Thanks.
