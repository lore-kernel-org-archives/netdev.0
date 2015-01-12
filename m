From: Shaohui Xie <Shaohui.Xie@freescale.com>
Subject: RE: [PATCH] net/fsl: Add mEMAC MDIO support to XGMAC MDIO
Date: Mon, 12 Jan 2015 03:13:48 +0000
Message-ID: <DM2PR0301MB08645F00A0FAE0899DD6BD8DE2430@DM2PR0301MB0864.namprd03.prod.outlook.com>
References: <1420364162-13109-1-git-send-email-shh.xie@gmail.com>
 <54B035F4.4020804@Freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Andy Fleming <afleming@gmail.com>
To: Emilian Medve <Emilian.Medve@freescale.com>,
	"shh.xie@gmail.com" <shh.xie@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0143.outbound.protection.outlook.com ([157.56.110.143]:44000
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751015AbbALDNv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jan 2015 22:13:51 -0500
In-Reply-To: <54B035F4.4020804@Freescale.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Emil,

> -----Original Message-----
> From: Emil Medve [mailto:Emilian.Medve@Freescale.com]
> Sent: Saturday, January 10, 2015 4:12 AM
> To: shh.xie@gmail.com; netdev@vger.kernel.org; davem@davemloft.net
> Cc: Andy Fleming; Xie Shaohui-B21989
> Subject: Re: [PATCH] net/fsl: Add mEMAC MDIO support to XGMAC MDIO
> 
> Hello Shao-Hui,
> 
> 
> On 01/04/2015 03:36 AM, shh.xie@gmail.com wrote:
> > From: Andy Fleming <afleming@gmail.com>
> >
> > The Freescale mEMAC supports operating at 10/100/1000/10G, and its
> > associated MDIO controller is likewise capable of operating both
> > Clause 22 and Clause 45 MDIO buses. It is nearly identical to the MDIO
> > controller on the XGMAC, so we just modify that driver.
> >
> > Portions of this driver developed by:
> >
> > Sandeep Singh <sandeep@freescale.com>
> > Roy Zang <tie-fei.zang@freescale.com>
> >
> > Signed-off-by: Andy Fleming <afleming@gmail.com>
> > Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>
> > ---
> >  drivers/net/ethernet/freescale/Kconfig      |  3 +-
> >  drivers/net/ethernet/freescale/xgmac_mdio.c | 64
> > ++++++++++++++++++++++++-----
> >  2 files changed, 55 insertions(+), 12 deletions(-)
> >
> > 	...
> >
> > diff --git a/drivers/net/ethernet/freescale/xgmac_mdio.c
> > b/drivers/net/ethernet/freescale/xgmac_mdio.c
> > index a352445..e0fc3d1 100644
> > --- a/drivers/net/ethernet/freescale/xgmac_mdio.c
> > +++ b/drivers/net/ethernet/freescale/xgmac_mdio.c
> >
> > 	...
> >
> > @@ -123,21 +144,39 @@ static int xgmac_mdio_write(struct mii_bus *bus,
> > int phy_id, int regnum, u16 val  static int xgmac_mdio_read(struct
> > mii_bus *bus, int phy_id, int regnum)  {
> >  	struct tgec_mdio_controller __iomem *regs = bus->priv;
> > -	uint16_t dev_addr = regnum >> 16;
> > +	uint16_t dev_addr;
> > +	uint32_t mdio_stat;
> >  	uint32_t mdio_ctl;
> >  	uint16_t value;
> >  	int ret;
> >
> > +	mdio_stat = in_be32(&regs->mdio_stat);
> > +	if (regnum & MII_ADDR_C45) {
> > +		dev_addr = (regnum >> 16) & 0x1f;
> > +		mdio_stat |= MDIO_STAT_ENC;
> > +	} else {
> > +		dev_addr = regnum & 0x1f;
> > +		mdio_stat = ~MDIO_STAT_ENC;
> 
> Shouldn't this be 'mdio_stat &= ~MDIO_STAT_ENC'?
[S.H] You are right! should be "mdio_stat &= ~MDIO_STAT_ENC".
We have this bug for a long time!

I'll post a patch to fix it.

Thanks!
Shaohui
