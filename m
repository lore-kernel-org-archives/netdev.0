From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: Re: [PATCH net-next v2 2/2] gianfar: Use Single-Queue polling for
 "fsl,etsec2"
Date: Fri, 7 Mar 2014 16:50:29 +0200
Message-ID: <5319DCB5.1080104@freescale.com>
References: <1394196166-24932-1-git-send-email-claudiu.manoil@freescale.com> <1394196166-24932-3-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co9ehsobe001.messaging.microsoft.com ([207.46.163.24]:26680
	"EHLO co9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753064AbaCGOul (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2014 09:50:41 -0500
In-Reply-To: <1394196166-24932-3-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/7/2014 2:42 PM, Claudiu Manoil wrote:
[...]
> @@ -723,9 +737,22 @@ static int gfar_of_init(struct platform_device *ofdev, struct net_device **pdev)
>   	if (!np || !of_device_is_available(np))
>   		return -ENODEV;
>
> -	/* parse the num of tx and rx queues */
> +	/* parse the num of HW tx and rx queues */
>   	tx_queues = (u32 *)of_get_property(np, "fsl,num_tx_queues", NULL);
> -	num_tx_qs = tx_queues ? *tx_queues : 1;
> +	rx_queues = (u32 *)of_get_property(np, "fsl,num_rx_queues", NULL);
> +
> +	if (priv->mode == SQ_SG_MODE) {

priv->mode not known at this point.
The checks to limit the number of supported queues
are not trivial (awkward DT structure).

I'm recalling this patch for now. Sorry.
