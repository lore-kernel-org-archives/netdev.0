From: Ben Hutchings <bhutchings@solarflare.com>
Subject: MDIO clause 45 (was Re: [PATCH net-next 2/13]bnx2x: Adding bnx2x_link)
Date: Wed, 4 Jun 2008 15:34:00 +0100
Message-ID: <20080604143359.GB11300@solarflare.com>
References: <1212333127.6967.121.camel@ubuntu804desktop.localdomain> <87tzgc283g.fsf@basil.nowhere.org> <1212474679.18365.34.camel@ubuntu804desktop.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, netdev <netdev@vger.kernel.org>,
	jeff@garzik.org, davem@davemloft.net,
	Eliezer Tamir <eliezert@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	Yaniv Rosner <yanivr@broadcom.com>
To: Eilon Greenstein <eilong@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:45838 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753170AbYFDOeO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2008 10:34:14 -0400
Content-Disposition: inline
In-Reply-To: <1212474679.18365.34.camel@ubuntu804desktop.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eilon Greenstein wrote:
> On Sun, 2008-06-01 at 22:50 +0200, Andi Kleen wrote:
[...]
> > > +static u8 bnx2x_reset_unicore(struct link_params *params)
> > > +{
> > > +	struct bnx2x *bp = params->bp;
> > > +	u16 mii_control;
> > > +	u16 i;
> > > +
> > > +	CL45_RD_OVER_CL22(bp, params->port,
> > > +			      params->phy_addr,
> > > +			      MDIO_REG_BANK_COMBO_IEEE0,
> > > +			      MDIO_COMBO_IEEE0_MII_CONTROL, &mii_control);
> > > +
> > > +	/* reset the unicore */
> > > +	CL45_WR_OVER_CL22(bp, params->port,
> > > +			      params->phy_addr,
> > > +			      MDIO_REG_BANK_COMBO_IEEE0,
> > > +			      MDIO_COMBO_IEEE0_MII_CONTROL,
> > > +			      (mii_control |
> > > +			       MDIO_COMBO_IEEO_MII_CONTROL_RESET));
> > 
> > Your macro naming is certainly "interesting".
> :) The original code (which is currently part of bnx2x.c) was using CL22
> and CL45 - we changed everything to CL45 by using these accessories
> macros and the "interesting" name is wrong... it should read CL22 over
> CL45 - we will fix it in the next patch as well

This reminds me that there isn't currently a standard way to do clause 45
MDIO through ioctl().  The sfc driver currently has its own way of unpacking
PHY address, MMD number and a clause 45 flag from SIOC{G,S}MIIREG arguments.
cxgb3 is doing something similar but without the flag, and we choose
different default MMDs.  None of the other 10 GbE drivers appear to support
clause 45 MDIO through ioctl().  It seems like it would be useful to set a
rule that all the drivers can follow.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
