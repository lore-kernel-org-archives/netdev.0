From: Shawn Guo <shawn.guo@freescale.com>
Subject: Re: [PATCH] net/smsc911x: add device tree probe support
Date: Sat, 30 Jul 2011 00:03:44 +0800
Message-ID: <20110729160343.GA2241@S2100-06.ap.freescale.net>
References: <1311587040-8988-1-git-send-email-shawn.guo@linaro.org>
 <20110725213723.GI26735@ponder.secretlab.ca>
 <20110726010154.GG21641@S2100-06.ap.freescale.net>
 <alpine.LFD.2.00.1107252105561.12766@xanadu.home>
 <20110726013026.GH21641@S2100-06.ap.freescale.net>
 <alpine.LFD.2.00.1107252222540.12766@xanadu.home>
 <20110729023626.GB1946@S2100-06.ap.freescale.net>
 <20110729154723.GC11164@ponder.secretlab.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Nicolas Pitre <nicolas.pitre@linaro.org>, <patches@linaro.org>,
	<netdev@vger.kernel.org>, <devicetree-discuss@lists.ozlabs.org>,
	Steve Glendinning <steve.glendinning@smsc.com>,
	Shawn Guo <shawn.guo@linaro.org>,
	"David S. Miller" <davem@davemloft.net>,
	<linux-arm-kernel@lists.infradead.org>
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from db3ehsobe004.messaging.microsoft.com ([213.199.154.142]:33640
	"EHLO DB3EHSOBE004.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752108Ab1G2P4Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jul 2011 11:56:25 -0400
Content-Disposition: inline
In-Reply-To: <20110729154723.GC11164@ponder.secretlab.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 29, 2011 at 09:47:23AM -0600, Grant Likely wrote:
> On Fri, Jul 29, 2011 at 10:36:26AM +0800, Shawn Guo wrote:
> > On Mon, Jul 25, 2011 at 10:28:05PM -0400, Nicolas Pitre wrote:
> > > On Tue, 26 Jul 2011, Shawn Guo wrote:
> > > 
> > > > On Mon, Jul 25, 2011 at 09:16:40PM -0400, Nicolas Pitre wrote:
> > > > > On Tue, 26 Jul 2011, Shawn Guo wrote:
> > > > > 
> > > > > > On Mon, Jul 25, 2011 at 03:37:23PM -0600, Grant Likely wrote:
> > > > > > > On Mon, Jul 25, 2011 at 05:44:00PM +0800, Shawn Guo wrote:
> > > > > > > > It adds device tree probe support for smsc911x driver.
> > > > > > > > 
> > > > > > > > Signed-off-by: Shawn Guo <shawn.guo@linaro.org>
> > > > > > > > Cc: Grant Likely <grant.likely@secretlab.ca>
> > > > > > > > Cc: Steve Glendinning <steve.glendinning@smsc.com>
> > > > > > > > Cc: David S. Miller <davem@davemloft.net>
> > > > > > > > ---
> > > > > > > >  Documentation/devicetree/bindings/net/smsc.txt |   34 +++++++
> > > > > > > >  drivers/net/smsc911x.c                         |  123 +++++++++++++++++++-----
> > > > > > > >  2 files changed, 132 insertions(+), 25 deletions(-)
> > > > > > > >  create mode 100644 Documentation/devicetree/bindings/net/smsc.txt
> > > > > > > > 
> > > > > > > > diff --git a/Documentation/devicetree/bindings/net/smsc.txt b/Documentation/devicetree/bindings/net/smsc.txt
> > > > > > > > new file mode 100644
> > > > > > > > index 0000000..1920695
> > > > > > > > --- /dev/null
> > > > > > > > +++ b/Documentation/devicetree/bindings/net/smsc.txt
> > > > > > > > @@ -0,0 +1,34 @@
> > > > > > > > +* Smart Mixed-Signal Connectivity (SMSC) LAN Controller
> > > > > > > > +
> > > > > > > > +Required properties:
> > > > > > > > +- compatible : Should be "smsc,lan<model>""smsc,lan"
> > > > > > > 
> > > > > > > Drop "smsc,lan".  That's far too generic.
> > > > > > > 
> > > > > > The following devices are supported by the driver.
> > > > > > 
> > > > > > LAN9115, LAN9116, LAN9117, LAN9118
> > > > > > LAN9215, LAN9216, LAN9217, LAN9218
> > > > > > LAN9210, LAN9211
> > > > > > LAN9220, LAN9221
> > > > > > 
> > > > > > If we only keep specific <model> as the compatible, we will have a
> > > > > > long match table which is actually used nowhere to distinguish the
> > > > > > device.
> > > > > > 
> > > > > > So we need some level generic compatible to save the meaningless
> > > > > > long match table.  What about: 
> > > > > > 
> > > > > > static const struct of_device_id smsc_dt_ids[] = {
> > > > > >         { .compatible = "smsc,lan9", },
> > > > > >         { /* sentinel */ }
> > > > > > };
> > > > > > 
> > > > > > Or:
> > > > > > 
> > > > > > static const struct of_device_id smsc_dt_ids[] = {
> > > > > >         { .compatible = "smsc,lan91", },
> > > > > >         { .compatible = "smsc,lan92", },
> > > > > >         { /* sentinel */ }
> > > > > > };
> > > > > 
> > > > > None of this unambiguously distinguish the devices supported by this 
> > > > > driver and the smc91x driver which supports LAN91C92, LAN91C94, 
> > > > > LAN91C95, LAN91C96, LAN91C100, LAN91C110.
> > > > > 
> > > > So you suggest to make a long list to explicitly tell the device type
> > > > that the driver supports?
> > > 
> > > I'm not suggesting anything.  :-)  I'm merely pointing out that the 
> > > above .compatible = "smsc,lan9" or .compatible = "smsc,lan91" are too 
> > > generic given that there is another driver with different devices to 
> > > which they could also apply.
> > > 
> > Since I do not get any suggestion here, I'm going to follow the driver
> > name to use '911' as the model number.  Please tell me if there is any
> > better one.
> 
> What is the manufacturer part name?  lan9111 or lan91c11?  The
> manufacturer's documented part number is almost always preferred.
> 
I just posted the v2 of the patch, and chose to use 'smsc,lan9115'
which is the first model supported in the driver.  This is the same
approach I used with i.mx device bindings.

-- 
Regards,
Shawn

