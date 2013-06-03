From: Joe Perches <joe@perches.com>
Subject: Re: [PATCHv2 net-next] net: fec: add fallback to random MAC address
Date: Mon, 03 Jun 2013 05:54:40 -0700
Message-ID: <1370264080.2025.29.camel@joe-AO722>
References: <1370255919-12762-1-git-send-email-l.stach@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Pavel Machek <pavel@denx.de>
To: Lucas Stach <l.stach@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:54269 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755856Ab3FCMyn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jun 2013 08:54:43 -0400
In-Reply-To: <1370255919-12762-1-git-send-email-l.stach@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-06-03 at 12:38 +0200, Lucas Stach wrote:
> If no valid MAC address could be obtained from the hardware,
> fall back to a randomly generated one.
[]
> diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
[]
> @@ -1039,6 +1039,18 @@ static void fec_get_mac(struct net_device *ndev)
[]
> +	if (!is_valid_ether_addr(iap)) {
> +		/* Report it and use a random ethernet address instead */
> +		netdev_err(ndev, "Invalid MAC address: %pM\n", iap);
> +		eth_hw_addr_random(ndev);
> +		netdev_info(ndev, "Using random MAC address: %pM\n",
> +			    ndev->dev_addr);

Perhaps a single line message would be better, something like:

		eth_hw_addr_random(ndev);
		netdev_info(ndev, "Has invalid MAC addr %pM, using random %pM\n",
			    iap, ndev->dev_addr);

Looking treewide at uses of eth_hw_addr_random, there's no
standard message so maybe standardization is a possible
effort for another time.
