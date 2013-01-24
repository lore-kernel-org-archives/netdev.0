From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH v2 1/1 net-next] net: fec: add napi support to improve
 proformance
Date: Thu, 24 Jan 2013 14:11:43 +0100
Message-ID: <5101330F.3030702@openwrt.org>
References: <1359014309-8636-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: lznuaa@gmail.com, shawn.guo@linaro.org, B38611@freescale.com,
	davem@davemloft.net, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, s.hauer@pengutronix.de
To: Frank Li <Frank.Li@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:60182 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750975Ab3AXNOa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2013 08:14:30 -0500
Received: by mail-lb0-f177.google.com with SMTP id go11so3125239lbb.36
        for <netdev@vger.kernel.org>; Thu, 24 Jan 2013 05:14:29 -0800 (PST)
In-Reply-To: <1359014309-8636-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/24/2013 08:58 AM, Frank Li wrote:
65,6 +566,20 @@ fec_timeout(struct net_device *ndev)
>   }
>
>   static void
> +fec_enet_rx_int_is_enabled(struct net_device *ndev, bool enabled)
> +{
> +	struct fec_enet_private *fep = netdev_priv(ndev);
> +	uint    int_events;
> +
> +	int_events = readl(fep->hwp + FEC_IMASK);
> +	if (enabled)
> +		int_events |= FEC_ENET_RXF;
> +	else
> +		int_events &= ~FEC_ENET_RXF;
> +	writel(int_events, fep->hwp + FEC_IMASK);
> +}

This function is badly named with respect to what it does. A better name 
would be fec_enet_rx_interrupt_set() for instance.
--
Florian
