From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: phy: adds backplane driver for Freescale's PCS PHY
Date: Fri, 18 Dec 2015 13:02:09 +0100
Message-ID: <20151218120209.GA477@lunn.ch>
References: <1450431054-5227-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, f.fainelli@gmail.com,
	Shaohui Xie <Shaohui.Xie@freescale.com>
To: shh.xie@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44308 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751794AbbLRMCN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Dec 2015 07:02:13 -0500
Content-Disposition: inline
In-Reply-To: <1450431054-5227-1-git-send-email-shh.xie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 18, 2015 at 05:30:54PM +0800, shh.xie@gmail.com wrote:
> +static int fsl_backplane_probe(struct phy_device *phydev)
> +{
> +	struct fsl_xgkr_inst *xgkr_inst;
> +	struct device_node *child, *parent, *lane_node;
> +	const char *lane_name;
> +	int len;
> +	int ret;
> +	u32 mode;
> +	u32 lane[2];
> +
> +	child = phydev->dev.of_node;
> +	parent = of_get_parent(child);
> +	if (!parent) {
> +		dev_err(&phydev->dev, "could not get parent node");
> +		return 0;
> +	}
> +
> +	lane_name = of_get_property(parent, "lane-instance", &len);
> +	if (!lane_name)
> +		return 0;
> +
> +	if (strstr(lane_name, "1000BASE-KX"))
> +		mode = BACKPLANE_1G_KX;
> +	else
> +		mode = BACKPLANE_10G_KR;
> +
> +	lane_node = of_parse_phandle(child, "lane-handle", 0);


Hi Shaohui

You are missing the device tree binding Documentation.

Parent will be the mdio bus device and you want 'lane-instance' and
'lane-handle' properties to be in the mdio bus node?

     Andrew
