From: Byungho An <bh74.an@samsung.com>
Subject: RE: [PATCH 1/3] net: stmmac: change GMAC control register for SGMII
Date: Wed, 28 Nov 2012 19:57:02 +0900
Message-ID: <009401cdcd57$18b275d0$4a176170$%an@samsung.com>
References: <004b01cdc959$80af8030$820e8090$%an@samsung.com>
 <50B344FC.4070405@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, kgene.kim@samsung.com,
	linux-kernel@vger.kernel.org
To: 'Giuseppe CAVALLARO' <peppe.cavallaro@st.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <50B344FC.4070405@st.com>
Content-language: ko
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/26/2012 07:31 PM, Giuseppe CABALLARO wrote:
> On 11/23/2012 10:04 AM, Byungho An wrote:
> >
> > This patch changes GMAC control register (TC(Transmit
> > Configuration) and PS(Port Selection) bit for SGMII.
> > In case of SGMII, TC bit is '1' and PS bit is 0.
> 
> IMO this new support that should be released for net-next and further 
> effort is actually needed.
>
OK, I see but if possible, I want to support the new features which is
included in this patch from v3.8
 
> The availability of the PCS registers is given by looking at the HW 
> feature register. In fact, these are optional registers.
> I don't want to break the compatibility with old chips.
> 
It means that old chip doesn't have this bit or this register? If that, how
about using compatible in DT blob like snps,dwmac-3.70a and then in just
this case trying to read this bit and this register.

> I do not see why we have to use Kconfig macro to select ANE etc (as 
> you do in your patches).
OK. I agree with you.

> The driver could directly manage the phy device by itself if possible 
> and the stmmac_init_phy should be reworked.
> 
Could you explain more detail? As I understood, after set ANE bit in MAC
side then PHY auto-negotiation can be enabled. If I'm wrong let me know.
According to your mention, MAC and PHY auto-negotiation can be managed in
stmmac_init_phy?

> There are several things that need to be implemented. For example:
> 
> The ISR (e.g. priv->hw->mac->host_irq_status) should be able to manage 
> these new interrupts.
I think that there would be two additional interrupts."PCS Auto-Negotiation
Complete" and "PCS Link Status Changed". These two interrupts are added to
"stmmac_interrupt". In my opinion, there are no specific processing for
these two irqs. What do you think about it?

> The code has to be able to maintain the user interface.
> For example if you want to enable ANE or manage Advertisement caps.
> 
Does it mean that command line or other network command(e.g. ifconfig...) or
ioctol? Actually I don't understand exact user interface way. Could you
recommend the method for user interface?

> > Signed-off-by: Byungho An <bh74.an@samsung.com>
> > ---
> 
> [snip]
> 
> > +	if (priv->phydev->interface == PHY_INTERFACE_MODE_SGMII) {
> > +		value = readl(priv->ioaddr);
> > +		/* GMAC_CONTROL_TC : transmit config in RGMII/SGMII */
> > +		value |= 0x1000000;
> > +		/* GMAC_CONTROL_PS : Port Selection for GMII */
> > +		value &= ~(0x8000);
> > +		writel(value, priv->ioaddr);
> > +	}
> > +
> 
> 
> This parts of code have to be moved in 
> drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c
> 
OK.

> Pls, do not use value |= 0x1000000 but provide the appropriate defines.
> 
OK.

> >   	/* Request the IRQ lines */
> >   	ret = request_irq(dev->irq, stmmac_interrupt,
> >   			 IRQF_SHARED, dev->name, dev);
> >
Thank you.
Byungho An.
