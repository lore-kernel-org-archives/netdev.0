From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v3 01/11] net: phy: Add rockchip phy driver support
Date: Wed, 2 Aug 2017 15:21:21 +0200
Message-ID: <20170802132121.GA24708@lunn.ch>
References: <1501654546-17292-1-git-send-email-david.wu@rock-chips.com>
 <1501654546-17292-2-git-send-email-david.wu@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, heiko@sntech.de, f.fainelli@gmail.com,
        robh+dt@kernel.org, mark.rutland@arm.com, catalin.marinas@arm.com,
        will.deacon@arm.com, olof@lixom.net, linux@armlinux.org.uk,
        arnd@arndb.de, peppe.cavallaro@st.com, alexandre.torgue@st.com,
        huangtao@rock-chips.com, hwg@rock-chips.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-rockchip@lists.infradead.org, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Wu <david.wu@rock-chips.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1501654546-17292-2-git-send-email-david.wu@rock-chips.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +static struct phy_driver rockchip_phy_driver[] = {
> +{
> +	.phy_id			= 0x1234d400,
> +	.phy_id_mask		= 0xfffffff0,
> +	.name			= "Rockchip internal EPHY",
> +	.features		= (PHY_BASIC_FEATURES | SUPPORTED_Pause
> +				   | SUPPORTED_Asym_Pause),

Please take a look at Documentation/networking/phy.txt and
Fixes: 529ed1275263 ("net: phy: phy drivers should not set SUPPORTED_[Asym_]Pause")

Pause frames / flow control

 The PHY does not participate directly in flow control/pause frames except by
 making sure that the SUPPORTED_Pause and SUPPORTED_AsymPause bits are set in
 MII_ADVERTISE to indicate towards the link partner that the Ethernet MAC
 controller supports such a thing. Since flow control/pause frames generation
 involves the Ethernet MAC driver, it is recommended that this driver takes care
 of properly indicating advertisement and support for such features by setting
 the SUPPORTED_Pause and SUPPORTED_AsymPause bits accordingly. This can be done
 either before or after phy_connect() and/or as a result of implementing the
 ethtool::set_pauseparam feature.

	Andrew
