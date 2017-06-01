From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/2] ARM: imx6ul-14x14-evk: Fix suspend over nfs by
 phy
Date: Thu, 01 Jun 2017 15:03:20 -0400 (EDT)
Message-ID: <20170601.150320.128443002523337995.davem@davemloft.net>
References: <cover.1496224930.git.leonard.crestez@nxp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, andrew@lunn.ch, shawnguo@kernel.org,
        fugang.duan@nxp.com, johan@kernel.org,
        alexandre.belloni@free-electrons.com, p.zabel@pengutronix.de,
        fabio.estevam@nxp.com, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: leonard.crestez@nxp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1496224930.git.leonard.crestez@nxp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Leonard Crestez <leonard.crestez@nxp.com>
Date: Wed, 31 May 2017 13:29:28 +0300

> Right now attempting doing suspend/resume while root is mounted over NFS
> hangs on imx6ul-14x14-evk. This is happening because ksz8081 phy fixups are
> lost on resume.
> 
> Fix this by using equivalent devicetree properties instead of a phy fixup
> and handling those properties on resume in the micrel driver.
> 
> In theory it might now be possible to remove the phy fixup from mach-imx6ul
> entirely but it is possible that this would break other imx6ul boards which
> use the same phy. The solution would be to patch their dts but it's not
> clear how to identify affected boards.
> 
> This code is shared with imx6ull-14x14-evk but 6ull suspend needs an
> unrelated patch: https://lkml.org/lkml/2017/5/30/584
> 
> This is something of a corner case so there is no CC: stable.
> 
> Changes since v1: https://lkml.org/lkml/2017/5/30/672 
>  * Split a kszphy_config_reset function for stuff shared between
> config_init and resume. Calling config_init directly could be an option but
> on some HW variants it does extra stuff like parsing devicetree options.
> That would not be appropriate for resume code.

Series applied.
