From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH net-next 2/4] net: systemport: use the new fixed PHY
 helpers
Date: Mon, 19 May 2014 22:19:46 +0200
Message-ID: <20140519221946.27dbad55@free-electrons.com>
References: <1400528625-32744-1-git-send-email-f.fainelli@gmail.com>
	<1400528625-32744-3-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	devicetree@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:54811 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932478AbaESUTt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2014 16:19:49 -0400
In-Reply-To: <1400528625-32744-3-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Florian Fainelli,

On Mon, 19 May 2014 12:43:43 -0700, Florian Fainelli wrote:
> +	priv->phydev = of_phy_connect(dev, priv->phy_dn, bcm_sysport_adj_link,
> +					0, priv->phy_interface);
>  	if (!priv->phydev) {
>  		netdev_err(dev, "could not attach to PHY\n");
>  		return -ENODEV;
> @@ -1551,6 +1551,20 @@ static int bcm_sysport_probe(struct platform_device *pdev)
>  	if (priv->phy_interface < 0)
>  		priv->phy_interface = PHY_INTERFACE_MODE_GMII;
>  
> +	/* SYSTEMPORT uses the old 'fixed-link' 5-digit property which is
> +	 * deprecated, we need to register the fixed PHY using the Ethernet
> +	 * MAC node since we do not have a 'fixed-link' subnode.
> +	 */

Actually even if you use the new fixed PHY DT binding, the DT node
linked to the PHY is the Ethernet MAC node. This is because I didn't
want to have a difference between how things are handled between the
old and the new binding.

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
