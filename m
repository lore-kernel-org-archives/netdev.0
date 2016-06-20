From: Joe Perches <joe@perches.com>
Subject: Re: [RFC PATCH] net: macb: Add gmii2rgmii converter support
Date: Sun, 19 Jun 2016 23:06:25 -0700
Message-ID: <1466402785.19647.138.camel@perches.com>
References: <1466400437-21277-1-git-send-email-appanad@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Kedareswara rao Appana <appana.durga.rao@xilinx.com>,
	nicolas.ferre@atmel.com, punnaia@xilinx.com, harinik@xilinx.com,
	anirudh@xilinx.com, michals@xilinx.com, appanad@xilinx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0230.hostedemail.com ([216.40.44.230]:54685 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751660AbcFTGH6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 02:07:58 -0400
In-Reply-To: <1466400437-21277-1-git-send-email-appanad@xilinx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-06-20 at 10:57 +0530, Kedareswara rao Appana wrote:
> This patch adds support for gmii2rgmii converter
> in the macb driver.
[]
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethern=
et/cadence/macb.c
[]
> @@ -376,6 +389,20 @@ static int macb_mii_probe(struct net_device *dev=
)
> =A0	int phy_irq;
> =A0	int ret;
> =A0
> +	if (bp->gmii2rgmii_phy_node) {
> +		phydev =3D of_phy_attach(bp->dev,
> +				=A0=A0=A0=A0=A0=A0=A0bp->gmii2rgmii_phy_node,
> +				=A0=A0=A0=A0=A0=A0=A00, 0);
> +		if (!phydev) {
> +			dev_err(&bp->pdev->dev, "%s: no gmii_to_rgmii found\n",
> +				dev->name);

why use dev_err(&bp->pdev->dev, ...) and not netdev_err(dev, ...) ?
