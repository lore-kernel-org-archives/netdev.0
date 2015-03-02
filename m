From: Tony Lindgren <tony@atomide.com>
Subject: Re: [PATCH net-next 2/2] net: netcp: select davinci_mdio driver by
 default
Date: Mon, 2 Mar 2015 08:11:55 -0800
Message-ID: <20150302161155.GB3665@atomide.com>
References: <1424813251-31610-1-git-send-email-m-karicheri2@ti.com>
 <1424813251-31610-2-git-send-email-m-karicheri2@ti.com>
 <20150227162921.GX11056@atomide.com>
 <54F0D9E9.1020705@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, mugunthanvnm@ti.com,
	prabhakar.csengg@gmail.com, varkabhadram@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	grygorii.strashko@ti.com, lokeshvutla@ti.com, mpa@pengutronix.de,
	w-kwok2@ti.com
To: Murali Karicheri <m-karicheri2@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <54F0D9E9.1020705@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Murali Karicheri <m-karicheri2@ti.com> [150227 12:59]:
> On 02/27/2015 11:29 AM, Tony Lindgren wrote:
> >* Murali Karicheri<m-karicheri2@ti.com>  [150224 13:31]:
> >>Keystone netcp driver re-uses davinci mdio driver. So enable it
> >>by default for keystone netcp driver.
> >>
> >>Signed-off-by: Murali Karicheri<m-karicheri2@ti.com>
> >>---
> >>  drivers/net/ethernet/ti/Kconfig |    1 +
> >>  1 file changed, 1 insertion(+)
> >>
> >>diff --git a/drivers/net/ethernet/ti/Kconfig b/drivers/net/ethernet/ti/Kconfig
> >>index 3bc992c..945a221 100644
> >>--- a/drivers/net/ethernet/ti/Kconfig
> >>+++ b/drivers/net/ethernet/ti/Kconfig
> >>@@ -88,6 +88,7 @@ config TI_CPTS
> >>  config TI_KEYSTONE_NETCP
> >>  	tristate "TI Keystone NETCP Core Support"
> >>  	select TI_CPSW_ALE
> >>+	select TI_DAVINCI_MDIO
> >>  	depends on OF
> >>  	depends on KEYSTONE_NAVIGATOR_DMA&&  KEYSTONE_NAVIGATOR_QMSS
> >>  	---help---
> >
> >These options should be silent Kconfig options if we're selecting
> >them. Or else you should use depends on instead.
> >
> Just followed the existing implementation as it made sense.
> 
> config TI_DAVINCI_EMAC
> 	tristate "TI DaVinci EMAC Support"
> 	depends on ARM && ( ARCH_DAVINCI || ARCH_OMAP3 )
> 	select TI_DAVINCI_MDIO
> 	select TI_DAVINCI_CPDMA
> 	select PHYLIB
> 	---help---
> 	  This driver supports TI's DaVinci Ethernet .
> 
> 	  To compile this driver as a module, choose M here: the module
> 	  will be called davinci_emac_driver.  This is recommended.
> 
> config TI_CPSW
> 	tristate "TI CPSW Switch Support"
> 	depends on ARCH_DAVINCI || ARCH_OMAP2PLUS
> 	select TI_DAVINCI_CPDMA
> 	select TI_DAVINCI_MDIO
> 	select TI_CPSW_PHY_SEL
> 	select TI_CPSW_ALE
> 	select MFD_SYSCON
> 	select REGMAP
> 	---help---
> 	  This driver supports TI's CPSW Ethernet Switch.
> 
> 	  To compile this driver as a module, choose M here: the module
> 	  will be called cpsw.
> 
> Why it has to be silent options?

Because we are now force selecting items that may have other
dependencies later on that will not be satisfied. That causes
all kinds of make randconfig build errors.

> NetCP driver would require DAVINCI_MDIO driver to function.
> So "select" make sense to me instead of "depend". How do
> you think depend can be used here?

In that case you'd have to have things the other way around:

config TI_CPSW
	tristate "TI CPSW Switch Support"
	depends on ARCH_DAVINCI || ARCH_OMAP2PLUS || \
		TI_DAVINCI_CPDMA || TI_DAVINCI_MDIO || \
		TI_CPSW_PHY_SEL || TI_CPSW_ALE || \
		MFD_SYSCON || REGMAP

But I think it's best to make these options silent Kconfig
options so the consumer drivers can select whatever components
they need to use. There should not be any need for users to
have to select these options.

Regards,

Tony 
