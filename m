From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next v2 2/4] net: fec: add interrupt coalescence
 feature support
Date: Tue, 16 Sep 2014 16:45:23 -0400 (EDT)
Message-ID: <20140916.164523.1376753359151264152.davem@davemloft.net>
References: <1410890290-11248-1-git-send-email-Frank.Li@freescale.com>
	<1410890290-11248-3-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: b38611@freescale.com, netdev@vger.kernel.org, lznuaa@gmail.com,
	shawn.guo@linaro.org, linux-arm-kernel@lists.infradead.org
To: Frank.Li@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58207 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750811AbaIPUpZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 16:45:25 -0400
In-Reply-To: <1410890290-11248-3-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <Frank.Li@freescale.com>
Date: Wed, 17 Sep 2014 01:58:08 +0800

> +/* ENET interrupt coalescing macro define */
> +#define FEC_ITR_CLK_SEL		(0x1 << 30)
> +#define FEC_ITR_EN		(0x1 << 31)
> +#define FEC_ITR_ICFT(X)		((X & 0xFF) << 20)
> +#define FEC_ITR_ICTT(X)		((X) & 0xFFFF)
> +#define FEC_ITR_ICFT_DEFAULT	200  /* Set 200 frame count threshold */
> +#define FEC_ITR_ICTT_DEFAULT	1000 /* Set 1000us timer threshold */
 ...
> +static int
> +fec_enet_set_coalesce(struct net_device *ndev, struct ethtool_coalesce *ec)

The size of these fields in the register determines the limitations of
the various parameters that this chip can support.

Therefore you must validate the user's request and signal an error if
the user asks for coalescing parameters that don't fit into those
fields.
