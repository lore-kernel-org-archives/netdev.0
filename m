From: "Nori, Sekhar" <nsekhar@ti.com>
Subject: RE: [PATCH 2/2] davinci: introduce EMAC PHY clock usage
Date: Mon, 15 Mar 2010 20:29:58 +0530
Message-ID: <B85A65D85D7EB246BE421B3FB0FBB59301E623BAE0@dbde02.ent.ti.com>
References: <1268317491-3822-1-git-send-email-srk@ti.com>
	<1268317491-3822-2-git-send-email-srk@ti.com>
	<1268317491-3822-3-git-send-email-srk@ti.com>
 <87wrxh5foj.fsf@deeprootsystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davinci-linux-open-source@linux.davincidsp.com"
	<davinci-linux-open-source@linux.davincidsp.com>,
	"Govindarajan, Sriramakrishnan" <srk@ti.com>
To: Kevin Hilman <khilman@deeprootsystems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:49620 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965065Ab0COPAM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Mar 2010 11:00:12 -0400
In-Reply-To: <87wrxh5foj.fsf@deeprootsystems.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 13, 2010 at 04:08:20, Kevin Hilman wrote:
> Sriramakrishnan <srk@ti.com> writes:
>
> > From: Sekhar Nori <nsekhar@ti.com>
> >
> > The patch "TI DaVinci EMAC: Add EMAC PHY clock handling" adds
> > support for enabling and disabling the EMAC PHY clock.
> >
> > The PHY clock on all DaVinci boards is derived from a fixed
> > on board clock. This patch adds the PHY clock definition to
> > the clock tree for all the DaVinci boards using EMAC. Also,
> > the existing input to EMAC module is differentiated from the
> > PHY clock using the clock name "emac_clk".
> >
> > Without this patch ethernet fails to initialize since it cannot
> > get the PHY clock and EMAC clock.
> >
> > Tested on EVM boards for DM365, DM6467, DM644x, DA830 and DA850.
> >
> > Signed-off-by: Sekhar Nori <nsekhar@ti.com>

[...]

> >
> > +#define EMAC_PHY_CLK_RATE  50000000
> > +
> > +static struct clk emac_phy = {
> > +   .name   = "emac_phy",
> > +   .rate   = EMAC_PHY_CLK_RATE,
> > +};
> > +
> > +static struct clk_lookup emac_phy_clks[] = {
> > +   CLK("davinci_emac.1", "phy_clk", &emac_phy),
>

[...]

>
> > +   CLK(NULL, NULL, NULL),
> > +};
> > +
>
> I'm not crazy about the clock definitions in the board files.  I
> assume you put it here instead of <soc>.c is because each clock
> has a board specific rate.

That and the fact that none of the DaVinci devices have an
integrated PHY on the SoC. The clock comes from an onboard
oscillator too. So, it seemed odd to include phy clock structure
in the SoC specific file.

>
> Instead, what I'd rather see is the clock defined once for each
> <soc>.c with a custom set_rate hook.  The default rate could
> be a per-SoC default (25MHz looks common) and any board files
> that don't use the default can use clk_set_rate() to change it.
>
> This approach should simplfy things and minimize changes to board
> files.

Right, that surely will lead to a much simpler patch so I will
go ahead and change. Also, only DA850 offers a choice between
MII (25MHz) and RMII (50MHz) phy. So, the set_rate needs to be
implemented only for this SoC.

Thanks,
Sekhar

