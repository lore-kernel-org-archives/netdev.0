From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 11/11] net: xilinx: Show csum in bootlog
Date: Thu, 4 Oct 2012 20:15:44 +0100
Message-ID: <1349378144.2817.23.camel@bwh-desktop.uk.solarflarecom.com>
References: <1349374497-9540-1-git-send-email-monstr@monstr.eu>
	 <1349374497-9540-11-git-send-email-monstr@monstr.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Anirudha Sarangi <anirudh@xilinx.com>,
	John Linn <John.Linn@xilinx.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	Rob Herring <rob.herring@calxeda.com>,
	"David S. Miller" <davem@davemloft.net>
To: Michal Simek <monstr@monstr.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:15981 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751816Ab2JDTPs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2012 15:15:48 -0400
In-Reply-To: <1349374497-9540-11-git-send-email-monstr@monstr.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-10-04 at 20:14 +0200, Michal Simek wrote:
> Just show current setting in bootlog.
[...]
> --- a/drivers/net/ethernet/xilinx/ll_temac_main.c
> +++ b/drivers/net/ethernet/xilinx/ll_temac_main.c
> @@ -1052,12 +1052,14 @@ static int __devinit temac_of_probe(struct platform_device *op)
>  	/* Setup checksum offload, but default to off if not specified */
>  	lp->temac_features = 0;
>  	p = (__be32 *)of_get_property(op->dev.of_node, "xlnx,txcsum", NULL);
> +	dev_info(&op->dev, "TX_CSUM %d\n", be32_to_cpup(p));
>  	if (p && be32_to_cpu(*p)) {
>  		lp->temac_features |= TEMAC_FEATURE_TX_CSUM;
>  		/* Can checksum TCP/UDP over IPv4. */
>  		ndev->features |= NETIF_F_IP_CSUM;
>  	}
>  	p = (__be32 *)of_get_property(op->dev.of_node, "xlnx,rxcsum", NULL);
> +	dev_info(&op->dev, "RX_CSUM %d\n", be32_to_cpup(p));
[...]

Is there any particular reason you think this needs to be logged by
default, rather than letting users run ethtool -k?  I suggest using
dev_dbg() instead.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
