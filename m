From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] sh_eth: replace devm_kzalloc() with devm_kmalloc()
Date: Sun, 11 May 2014 17:10:35 -0700
Message-ID: <1399853435.9156.1.camel@joe-AO725>
References: <201405120005.51199.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0116.hostedemail.com ([216.40.44.116]:34868 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750942AbaELAKi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 May 2014 20:10:38 -0400
In-Reply-To: <201405120005.51199.sergei.shtylyov@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-05-12 at 00:05 +0400, Sergei Shtylyov wrote:
> Now that devm_kmalloc() has become available, we can avoid the needless
> zeroing out of the PHY IRQ array.
[]
> net-next/drivers/net/ethernet/renesas/sh_eth.c
[]
> @@ -2627,7 +2627,7 @@ static int sh_mdio_init(struct sh_eth_pr
[]
> -	mdp->mii_bus->irq = devm_kzalloc(dev, sizeof(int) * PHY_MAX_ADDR,
> +	mdp->mii_bus->irq = devm_kmalloc(dev, sizeof(int) * PHY_MAX_ADDR,

perhaps

	mdp->mii_bus->irq = devm_kmalloc_array(dev, PHY_MAX_ADDR, sizeof(int),
