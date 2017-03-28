From: Sean Wang <sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH net-next v2 5/5] net-next: dsa: add dsa support for
 Mediatek MT7530 switch
Date: Tue, 28 Mar 2017 14:50:17 +0800
Message-ID: <1490683817.14184.49.camel@mtkswgap22>
References: <1490088910-19405-1-git-send-email-sean.wang@mediatek.com>
         <1490088910-19405-6-git-send-email-sean.wang@mediatek.com>
         <20170324141953.GH28518@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <vivien.didelot-4ysUXcep3aM1wj+D4I0NRVaTQe2KTcn/@public.gmane.org>,
        <matthias.bgg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        <mark.rutland-5wv7dgnIgG8@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-mediatek-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        <Landen.Chao-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org>, <keyhaede-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        <objelf-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170324141953.GH28518-g2DYL2Zd6BY@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Andrew 


On Fri, 2017-03-24 at 15:19 +0100, Andrew Lunn wrote:
> On Tue, Mar 21, 2017 at 05:35:10PM +0800, sean.wang-NuS5LvNUpcJWk0Htik3J/w@public.gmane.org wrote:
> 
> Hi Sean
> 
> > +	/* Lower Tx Driving */
> > +	for (i = 0 ; i < 6 ; i++)
> 
> Could MT7530_CPU_PORT be used here? 
> 

I should create meaningful definition instead of avoiding hard coding 

where 6 should be corrected into 5 which is meant for the number for

control register to configure TRGMII path


> > +		mt7530_write(priv, MT7530_TRGMII_TD_ODT(i),
> > +			     TD_DM_DRVP(8) | TD_DM_DRVN(8));
> > +
> > +	/* Setup MT7530 core clock */
> > +	if (!trgint) {
> > +		/* Disable MT7530 core clock */
> > +		core_clear(priv, CORE_TRGMII_GSW_CLK_CG, REG_GSWCK_EN);
> > +
> > +		/* Disable MT7530 PLL, since phy_device has not yet been
> > +		 * created when this function is called. So we provide
> > +		 * core_write_mmd_indirect to complete this function
> > +		 */
> > +		core_write_mmd_indirect(priv,
> > +					CORE_GSWPLL_GRP1,
> > +					MDIO_MMD_VEND2,
> > +					0);
> > +
> > +		/* Setup MT7530 core clock into 500Mhz */
> > +		core_write(priv, CORE_GSWPLL_GRP2,
> > +			   RG_GSWPLL_POSDIV_500M(1) |
> > +			   RG_GSWPLL_FBKDIV_500M(25));
> > +
> > +		/* Enable MT7530 PLL */
> > +		core_write(priv, CORE_GSWPLL_GRP1,
> > +			   RG_GSWPLL_EN_PRE |
> > +			   RG_GSWPLL_POSDIV_200M(2) |
> > +			   RG_GSWPLL_FBKDIV_200M(32));
> > +
> > +		/* Enable MT7530 core clock */
> > +		core_set(priv, CORE_TRGMII_GSW_CLK_CG, REG_GSWCK_EN);
> > +	}
> > +
> > +	/* Setup the MT7530 TRGMII Tx Clock */
> > +	core_set(priv, CORE_TRGMII_GSW_CLK_CG, REG_GSWCK_EN);
> > +	core_write(priv, CORE_PLL_GROUP5, RG_LCDDS_PCW_NCPO1(ncpo1));
> > +	core_write(priv, CORE_PLL_GROUP6, RG_LCDDS_PCW_NCPO0(0));
> > +	core_write(priv, CORE_PLL_GROUP10, RG_LCDDS_SSC_DELTA(ssc_delta));
> > +	core_write(priv, CORE_PLL_GROUP11, RG_LCDDS_SSC_DELTA1(ssc_delta));
> > +	core_write(priv, CORE_PLL_GROUP4,
> > +		   RG_SYSPLL_DDSFBK_EN | RG_SYSPLL_BIAS_EN |
> > +		   RG_SYSPLL_BIAS_LPF_EN);
> > +	core_write(priv, CORE_PLL_GROUP2,
> > +		   RG_SYSPLL_EN_NORMAL | RG_SYSPLL_VODEN |
> > +		   RG_SYSPLL_POSDIV(1));
> > +	core_write(priv, CORE_PLL_GROUP7,
> > +		   RG_LCDDS_PCW_NCPO_CHG | RG_LCCDS_C(3) |
> > +		   RG_LCDDS_PWDB | RG_LCDDS_ISO_EN);
> > +	core_set(priv, CORE_TRGMII_GSW_CLK_CG,
> > +		 REG_GSWCK_EN | REG_TRGMIICK_EN);
> > +
> > +	if (!trgint)
> > +		for (i = 0 ; i < 5 ; i++)
> 
> Why only 5 here? All other similar loops are to 6.  Replacing 5 with a
> #define might help make this more readable.

the same as above, it should be corrected

> > +			mt7530_rmw(priv, MT7530_TRGMII_RD(i),
> > +				   RD_TAP_MASK, RD_TAP(16));
> > +	else
> > +		mt7623_trgmii_set(priv, GSW_INTF_MODE, INTF_MODE_TRGMII);
> > +
> > +	return 0;
> > +}
> > +
> > +static int
> > +mt7623_pad_clk_setup(struct dsa_switch *ds)
> > +{
> > +	struct mt7530_priv *priv = ds->priv;
> > +	int i;
> > +
> > +	for (i = 0 ; i < 6; i++)
> 
> MT7530_CPU_PORT?


the same as above , it should be corrected
> > +
> > +/* Registers to mac forward conrol for unknown frames */
> 
> /conrol/control
> 

will fix it up
> > +
> > +/* Registor for port control */
> 
> Register
> 

will fix it up
> > +/* Regiser for TOP signal control */
> 
> Register
> 

will fix it up
> > +/* struct mt7530_priv -	This is the main datasructure for holding the state
> 
> data structure
> 
> > + *			of the driver
> > + * @dev:		The device pointer
> > + * @ds:			The pointer to the dsa core structure
> > + * @bus:		The bus used for the device and built-in PHY
> > + * @ethsys:		The regmap used for enabling the necessary PLL
> > + * @ethernet:		The regmap used for access TRGMII-based registers
> > + * @core_pwr:		The power supplied into the core
> > + * @io_pwr:		The power supplied into the I/O
> > + * @mcm:		Flag for distinguishing if standalone IC or module
> > + *			coupling
> > + * @reset:		The descriptor for GPIO line tied to its reset pin
> > + * @phy_mode:		The xMII for cpu port used
> > + * @ports:		Holding the state amongs ports
> 
> among

will fix it up

thank for your careful reviewing again!!



> 	Andrew


--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
