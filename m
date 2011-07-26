From: Shawn Guo <shawn.guo-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
Subject: Re: [PATCH] net/smsc911x: add device tree probe support
Date: Tue, 26 Jul 2011 09:30:26 +0800
Message-ID: <20110726013026.GH21641@S2100-06.ap.freescale.net>
References: <1311587040-8988-1-git-send-email-shawn.guo@linaro.org>
	<20110725213723.GI26735@ponder.secretlab.ca>
	<20110726010154.GG21641@S2100-06.ap.freescale.net>
	<alpine.LFD.2.00.1107252105561.12766@xanadu.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: patches-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	Steve Glendinning <steve.glendinning-sdUf+H5yV5I@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Nicolas Pitre <nicolas.pitre-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1107252105561.12766-QuJgVwGFrdf/9pzu0YdTqQ@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
	<mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 25, 2011 at 09:16:40PM -0400, Nicolas Pitre wrote:
> On Tue, 26 Jul 2011, Shawn Guo wrote:
> 
> > On Mon, Jul 25, 2011 at 03:37:23PM -0600, Grant Likely wrote:
> > > On Mon, Jul 25, 2011 at 05:44:00PM +0800, Shawn Guo wrote:
> > > > It adds device tree probe support for smsc911x driver.
> > > > 
> > > > Signed-off-by: Shawn Guo <shawn.guo-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
> > > > Cc: Grant Likely <grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
> > > > Cc: Steve Glendinning <steve.glendinning-sdUf+H5yV5I@public.gmane.org>
> > > > Cc: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> > > > ---
> > > >  Documentation/devicetree/bindings/net/smsc.txt |   34 +++++++
> > > >  drivers/net/smsc911x.c                         |  123 +++++++++++++++++++-----
> > > >  2 files changed, 132 insertions(+), 25 deletions(-)
> > > >  create mode 100644 Documentation/devicetree/bindings/net/smsc.txt
> > > > 
> > > > diff --git a/Documentation/devicetree/bindings/net/smsc.txt b/Documentation/devicetree/bindings/net/smsc.txt
> > > > new file mode 100644
> > > > index 0000000..1920695
> > > > --- /dev/null
> > > > +++ b/Documentation/devicetree/bindings/net/smsc.txt
> > > > @@ -0,0 +1,34 @@
> > > > +* Smart Mixed-Signal Connectivity (SMSC) LAN Controller
> > > > +
> > > > +Required properties:
> > > > +- compatible : Should be "smsc,lan<model>""smsc,lan"
> > > 
> > > Drop "smsc,lan".  That's far too generic.
> > > 
> > The following devices are supported by the driver.
> > 
> > LAN9115, LAN9116, LAN9117, LAN9118
> > LAN9215, LAN9216, LAN9217, LAN9218
> > LAN9210, LAN9211
> > LAN9220, LAN9221
> > 
> > If we only keep specific <model> as the compatible, we will have a
> > long match table which is actually used nowhere to distinguish the
> > device.
> > 
> > So we need some level generic compatible to save the meaningless
> > long match table.  What about: 
> > 
> > static const struct of_device_id smsc_dt_ids[] = {
> >         { .compatible = "smsc,lan9", },
> >         { /* sentinel */ }
> > };
> > 
> > Or:
> > 
> > static const struct of_device_id smsc_dt_ids[] = {
> >         { .compatible = "smsc,lan91", },
> >         { .compatible = "smsc,lan92", },
> >         { /* sentinel */ }
> > };
> 
> None of this unambiguously distinguish the devices supported by this 
> driver and the smc91x driver which supports LAN91C92, LAN91C94, 
> LAN91C95, LAN91C96, LAN91C100, LAN91C110.
> 
So you suggest to make a long list to explicitly tell the device type
that the driver supports?

-- 
Regards,
Shawn
