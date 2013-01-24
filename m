From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: Re: [PATCH v2 1/1 net-next] net: fec: add napi support to improve
 proformance
Date: Thu, 24 Jan 2013 10:56:53 -0700
Message-ID: <510175E5.4000306@boundarydevices.com>
References: <1359014309-8636-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: lznuaa@gmail.com, shawn.guo@linaro.org, B38611@freescale.com,
	davem@davemloft.net, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, s.hauer@pengutronix.de
To: Frank Li <Frank.Li@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:56594 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751658Ab3AXR44 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2013 12:56:56 -0500
Received: by mail-pa0-f52.google.com with SMTP id fb1so5690961pad.39
        for <netdev@vger.kernel.org>; Thu, 24 Jan 2013 09:56:56 -0800 (PST)
In-Reply-To: <1359014309-8636-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/24/2013 12:58 AM, Frank Li wrote:
> diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
> index f52ba33..39be2ab 100644
> --- a/drivers/net/ethernet/freescale/fec.c
> +++ b/drivers/net/ethernet/freescale/fec.c
> @@ -67,6 +67,7 @@
>   #endif
>   
>   #define DRIVER_NAME	"fec"
> +#define FEC_NAPI_WEIGHT	64
>   
>   /* Pause frame feild and FIFO threshold */
>   #define FEC_ENET_FCE	(1 << 5)
> @@ -565,6 +566,20 @@ fec_timeout(struct net_device *ndev)
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

fec_enet_rx_int_is_enabled looks like a question.
fec_enet_rx_int_enable would be a better name
