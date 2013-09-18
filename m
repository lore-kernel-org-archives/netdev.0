From: Joe Perches <joe@perches.com>
Subject: Re: [RFC] b44: use phylib
Date: Wed, 18 Sep 2013 08:19:05 -0700
Message-ID: <1379517545.1787.20.camel@joe-AO722>
References: <1377298608-18016-1-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: zambrano@broadcom.com, netdev@vger.kernel.org,
	Florian Fainelli <florian@openwrt.org>
To: Hauke Mehrtens <hauke@hauke-m.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0112.hostedemail.com ([216.40.44.112]:52008 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751218Ab3IRPTL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Sep 2013 11:19:11 -0400
In-Reply-To: <1377298608-18016-1-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-08-24 at 00:56 +0200, Hauke Mehrtens wrote:
> This splits the driver into the mac and a phy driver. On routers where
> this driver is used we have a switch which implements a phy and can be
> controlled by a phy driver.

One more trivial note:

> diff --git a/drivers/net/ethernet/broadcom/b44.c b/drivers/net/ethernet/broadcom/b44.c
[]
> +static void b44_adjust_link(struct net_device *dev)
> +{
[]
> +	if (status_changed) {
> +		pr_info("%s: link %s", dev->name, phydev->link ?
> +			"UP" : "DOWN");
> +		if (phydev->link)
> +			pr_cont(" - %d/%s", phydev->speed,
> +			phydev->duplex == DUPLEX_FULL ? "full" : "half");
> +		pr_cont("\n");
> +	}

This bit would be better as:

	if (status_change) {
		if (phydev->link)
			netdev_info(dev, "link UP - %d/%s\n",
				    phydev->speed,
				    phydev->duplex == DUPLEX_FULL
				    ? "full" : "half");
		else
			netdev_info(dev, "link DOWN\n");
	}

so there's no possible interleaving by other
thread messages.
