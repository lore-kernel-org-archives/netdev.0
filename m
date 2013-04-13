From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] fec: Fix PHC device log
Date: Sat, 13 Apr 2013 09:49:39 -0700
Message-ID: <1365871779.2358.3.camel@joe-AO722>
References: <1365871134-6834-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Frank.Li@freescale.com,
	netdev@vger.kernel.org, Fabio Estevam <fabio.estevam@freescale.com>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:52036 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753494Ab3DMQtl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Apr 2013 12:49:41 -0400
In-Reply-To: <1365871134-6834-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-04-13 at 13:38 -0300, Fabio Estevam wrote:
> Currently when booting a mx6 device we get the following on boot:
> registered PHC device on eth%d
[]
> diff --git a/drivers/net/ethernet/freescale/fec_ptp.c b/drivers/net/ethernet/freescale/fec_ptp.c
[]
> @@ -380,6 +380,6 @@ void fec_ptp_init(struct net_device *ndev, struct platform_device *pdev)
>  		fep->ptp_clock = NULL;
>  		pr_err("ptp_clock_register failed\n");
>  	} else {
> -		pr_info("registered PHC device on %s\n", ndev->name);
> +		pr_info("registered PHC device on eth%d\n", fep->dev_id);

Maybe better as:
		netdev_info(ndev, "registered PHC device %d\n", fep->dev_id);
