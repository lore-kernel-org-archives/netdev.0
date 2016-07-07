From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH v2 3/5] drivers: net: phy: Add MDIO driver
Date: Thu, 7 Jul 2016 15:14:22 +0100
Message-ID: <20160707141422.GQ1041@n2100.armlinux.org.uk>
References: <1464739840-21971-1-git-send-email-isubramanian@apm.com>
 <1464739840-21971-4-git-send-email-isubramanian@apm.com>
 <20160601011148.GD31982@lunn.ch>
 <CAKh23FmaQy8J=f-eyfBeNndz0oT5R0icvwJ3vrw1DMJnj9uv_g@mail.gmail.com>
 <20160705134950.GC5230@lunn.ch>
 <CAKh23FnvgWRMo=M35Mj4=a_KeUpvOoHa8stU=bSk9Y3VSRtyzQ@mail.gmail.com>
 <20160707140302.GP19800@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Iyappan Subramanian <isubramanian@apm.com>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, patches <patches@apm.com>,
	Matthias Brugger <matthias.bgg@gmail.com>,
	David Miller <davem@davemloft.net>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:40406 "EHLO
	pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750762AbcGGOOd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 10:14:33 -0400
Content-Disposition: inline
In-Reply-To: <20160707140302.GP19800@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 07, 2016 at 04:03:02PM +0200, Andrew Lunn wrote:
> > Wed, Jul 06, 2016 at 04:44:44PM -0700, Iyappan Subramanian wrote:
> > Hi Andrew,
> > 
> > On Tue, Jul 5, 2016 at 6:49 AM, Andrew Lunn <andrew@lunn.ch> wrote:
> > > On Mon, Jun 06, 2016 at 10:12:35AM -0700, Iyappan Subramanian wrote:
> > >> Hi Andrew,
> > >>
> > >> Thanks for the review.
> > >>
> > >> On Tue, May 31, 2016 at 6:11 PM, Andrew Lunn <andrew@lunn.ch> wrote:
> > >> > On Tue, May 31, 2016 at 05:10:38PM -0700, Iyappan Subramanian wrote:
> > >> >> +static int xgene_mdio_reset(struct xgene_mdio_pdata *pdata)
> > >> >> +{
> > >> >> +     int ret;
> > >> >> +
> > >> >> +     if (pdata->mdio_id == XGENE_MDIO_RGMII) {
> > >> >> +             if (pdata->dev->of_node) {
> > >> >> +                     clk_prepare_enable(pdata->clk);
> > >> >> +                     clk_disable_unprepare(pdata->clk);
> > >> >> +                     clk_prepare_enable(pdata->clk);
> > >> >
> > >> > Hi Iyappan
> > >> >
> > >> > Is that a workaround for a hardware problem? If so, i would suggest
> > >> > adding a comment, to stop people submitting a patch simplifying it.
> > >>
> > >> Hardware expects this clock sequence.  I'll add comment as you suggested.
> > >
> > > What exactly does the hardware require? Is this a workaround for a bug
> > > in the clock generator? Or a workaround for a bug in the MDIO device?
> > 
> > Hardware requires a clock pulse.  There is no bug.
> 
> And how are you guaranteeing a pulse? You enable/disable/enable
> without any sleeps, so it could all happen within a single clock
> cycle?

It's still really not good, because it does this:

- prepare + enable
- disable + unprepare
- prepare + enable

So every time the reset function is called, the prepare and enable
counts against the clock get incremented.  That's a bug.  This needs
a better solution.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
