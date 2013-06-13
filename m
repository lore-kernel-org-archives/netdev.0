From: Byungho An <bh74.an@samsung.com>
Subject: RE: [PATCH net-next] stmmac: added device tree support for fixed_phy
 and phy_addr
Date: Thu, 13 Jun 2013 19:25:56 +0900
Message-ID: <01b201ce6820$640897d0$2c19c770$%an@samsung.com>
References: <019301ce67d4$ed1e32b0$c75a9810$%an@samsung.com>
 <51B9989F.5020603@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ks_c_5601-1987
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	=?ks_c_5601-1987?B?J7HosbnB+Cc=?= <kgene.kim@samsung.com>,
	davem@davemloft.net, cpgs@samsung.com
To: 'Giuseppe CAVALLARO' <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:46624 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756119Ab3FMKZ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 06:25:58 -0400
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MOB00MV3UB87LX0@mailout1.samsung.com> for
 netdev@vger.kernel.org; Thu, 13 Jun 2013 19:25:56 +0900 (KST)
In-reply-to: <51B9989F.5020603@st.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 6/13/2013 7:04 PM, Giuseppe CAVALLARO wrote: 
> On 6/13/2013 3:25 AM, Byungho An wrote:
> >
> > This patch adds device tree support for fixed_phy and phy_addr it means
> > fixed_phy and phy_addr can be set in device tree file. "fixed_phy" and
> > "phy_addr" can be added in the device tree blob.
> 
> concerning this, we had added some work to pass from the platform
> the fixed bus name.
> 
> http://git.stlinux.com/?p=stm/linux-
> stm.git;a=blob;f=drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c;h=2d540e1d2151e4412a5af5356d24d
> 5c6b66cf72e;hb=HEAD
> 
> I wanted to also do a clean-up and update the DT support because
> the binding documentation remains obsolete etc.
> 

I think your previous work for DT support can cover my patch.
Do you have a plan to update and clean-up for DT support?

> peppe
> 
> >
> > Signed-off-by: Byungho An <bh74.an@samsung.com>
> > ---
> >   drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c |    7 +++++++
> >   1 file changed, 7 insertions(+)
> >
> > diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> > b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> > index 1d3780f..33ba995 100644
> > --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> > +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
> > @@ -34,6 +34,7 @@ static int stmmac_probe_config_dt(struct platform_device
> > *pdev,
> >   				  const char **mac)
> >   {
> >   	struct device_node *np = pdev->dev.of_node;
> > +	u32 phy_addr;
> >
> >   	if (!np)
> >   		return -ENODEV;
> > @@ -56,6 +57,12 @@ static int stmmac_probe_config_dt(struct platform_device
> > *pdev,
> >   		plat->pmt = 1;
> >   	}
> >
> > +	if (of_find_property(np, "fixed_phy", NULL)) {
> > +		plat->phy_bus_name = "fixed";
> > +		of_property_read_u32(np, "phy_addr", &phy_addr);
> > +		plat->phy_addr = phy_addr;
> > +	}
> > +
> >   	return 0;
> >   }
> >   #else
> >
