From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: Re: [PATCH] net/smsc911x: add device tree probe support
Date: Mon, 25 Jul 2011 21:16:40 -0400 (EDT)
Message-ID: <alpine.LFD.2.00.1107252105561.12766@xanadu.home>
References: <1311587040-8988-1-git-send-email-shawn.guo@linaro.org> <20110725213723.GI26735@ponder.secretlab.ca> <20110726010154.GG21641@S2100-06.ap.freescale.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Grant Likely <grant.likely@secretlab.ca>, patches@linaro.org,
	netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	Steve Glendinning <steve.glendinning@smsc.com>,
	Shawn Guo <shawn.guo@linaro.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org
To: Shawn Guo <shawn.guo@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:36290 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752062Ab1GZBQo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2011 21:16:44 -0400
Received: by qyk29 with SMTP id 29so1181735qyk.19
        for <netdev@vger.kernel.org>; Mon, 25 Jul 2011 18:16:43 -0700 (PDT)
In-Reply-To: <20110726010154.GG21641@S2100-06.ap.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 26 Jul 2011, Shawn Guo wrote:

> On Mon, Jul 25, 2011 at 03:37:23PM -0600, Grant Likely wrote:
> > On Mon, Jul 25, 2011 at 05:44:00PM +0800, Shawn Guo wrote:
> > > It adds device tree probe support for smsc911x driver.
> > > 
> > > Signed-off-by: Shawn Guo <shawn.guo@linaro.org>
> > > Cc: Grant Likely <grant.likely@secretlab.ca>
> > > Cc: Steve Glendinning <steve.glendinning@smsc.com>
> > > Cc: David S. Miller <davem@davemloft.net>
> > > ---
> > >  Documentation/devicetree/bindings/net/smsc.txt |   34 +++++++
> > >  drivers/net/smsc911x.c                         |  123 +++++++++++++++++++-----
> > >  2 files changed, 132 insertions(+), 25 deletions(-)
> > >  create mode 100644 Documentation/devicetree/bindings/net/smsc.txt
> > > 
> > > diff --git a/Documentation/devicetree/bindings/net/smsc.txt b/Documentation/devicetree/bindings/net/smsc.txt
> > > new file mode 100644
> > > index 0000000..1920695
> > > --- /dev/null
> > > +++ b/Documentation/devicetree/bindings/net/smsc.txt
> > > @@ -0,0 +1,34 @@
> > > +* Smart Mixed-Signal Connectivity (SMSC) LAN Controller
> > > +
> > > +Required properties:
> > > +- compatible : Should be "smsc,lan<model>""smsc,lan"
> > 
> > Drop "smsc,lan".  That's far too generic.
> > 
> The following devices are supported by the driver.
> 
> LAN9115, LAN9116, LAN9117, LAN9118
> LAN9215, LAN9216, LAN9217, LAN9218
> LAN9210, LAN9211
> LAN9220, LAN9221
> 
> If we only keep specific <model> as the compatible, we will have a
> long match table which is actually used nowhere to distinguish the
> device.
> 
> So we need some level generic compatible to save the meaningless
> long match table.  What about: 
> 
> static const struct of_device_id smsc_dt_ids[] = {
>         { .compatible = "smsc,lan9", },
>         { /* sentinel */ }
> };
> 
> Or:
> 
> static const struct of_device_id smsc_dt_ids[] = {
>         { .compatible = "smsc,lan91", },
>         { .compatible = "smsc,lan92", },
>         { /* sentinel */ }
> };

None of this unambiguously distinguish the devices supported by this 
driver and the smc91x driver which supports LAN91C92, LAN91C94, 
LAN91C95, LAN91C96, LAN91C100, LAN91C110.


Nicolas
