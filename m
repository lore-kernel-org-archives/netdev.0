From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 4/5] netdev/phy: Add driver for Broadcom BCM87XX 10G
 Ethernet PHYs
Date: Tue, 22 May 2012 11:17:40 -0700
Message-ID: <1337710660.3432.8.camel@joe2Laptop>
References: <1337709592-23347-1-git-send-email-ddaney.cavm@gmail.com>
	 <1337709592-23347-5-git-send-email-ddaney.cavm@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: devicetree-discuss@lists.ozlabs.org,
	Grant Likely <grant.likely@secretlab.ca>,
	Rob Herring <rob.herring@calxeda.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mips@linux-mips.org,
	Andy Fleming <afleming@freescale.com>,
	David Daney <david.daney@cavium.com>
To: David Daney <ddaney.cavm@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:41760 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751928Ab2EVSRo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 May 2012 14:17:44 -0400
In-Reply-To: <1337709592-23347-5-git-send-email-ddaney.cavm@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-05-22 at 10:59 -0700, David Daney wrote:
> From: David Daney <david.daney@cavium.com>

trivia:

> diff --git a/drivers/net/phy/bcm87xx.c b/drivers/net/phy/bcm87xx.c
[]
> @@ -0,0 +1,237 @@

> +static int bcm87xx_of_reg_init(struct phy_device *phydev)
> +{
> +	const __be32 *paddr;
> +	int len, i, ret;
> +
> +	if (!phydev->dev.of_node)
> +		return 0;
> +
> +	paddr = of_get_property(phydev->dev.of_node,
> +				"broadcom,c45-reg-init", &len);
> +	if (!paddr || len < (4 * sizeof(*paddr)))
> +		return 0;
> +
> +	ret = 0;
> +	len /= sizeof(*paddr);
> +	for (i = 0; i < len - 3; i += 4) {
> +		u16 devid = be32_to_cpup(paddr + i);
> +		u16 reg = be32_to_cpup(paddr + i + 1);
> +		u16 mask = be32_to_cpup(paddr + i + 2);
> +		u16 val_bits = be32_to_cpup(paddr + i + 3);
> +		int val;

These might read better as

	len /= 4;
	for (i = 0; i < len; i++) {
		u16 devid	= be32_to_cpu(*paddr++);
		u16 reg		= be32_to_cpu(*paddr++);
		u16 mask	= be32_to_cpu(*paddr++);
		u16 val_bits	= be32_to_cpu(*paddr++);
		...
	}
