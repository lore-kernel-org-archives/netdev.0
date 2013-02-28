From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1 net-next] fec: net: put tx to napi poll function to
 fix dead lock
Date: Thu, 28 Feb 2013 15:39:42 -0500 (EST)
Message-ID: <20130228.153942.1205752844713252540.davem@davemloft.net>
References: <1362023060-10277-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lznuaa@gmail.com, shawn.guo@linaro.org, B38611@freescale.com,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	s.hauer@pengutronix.de
To: Frank.Li@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47877 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756359Ab3B1Ujo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2013 15:39:44 -0500
In-Reply-To: <1362023060-10277-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Li <Frank.Li@freescale.com>
Date: Thu, 28 Feb 2013 11:44:20 +0800

> +	int tx_pkts = fec_enet_tx(ndev);
> +
> +	if (tx_pkts)
> +		return budget;

This isn't right, you don't want to finish the NAPI poll because
TX work was done.

Ignore the TX work for poll completion purposes, see
drivers/net/ethernet/broadcom/tg3.c:tg3_poll_work() for
example.
