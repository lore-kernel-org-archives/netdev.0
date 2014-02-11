From: Marc Dietrich <marvin24@gmx.de>
Subject: Re: [PATCH] net: rfkill-regulator: Add devicetree support.
Date: Tue, 11 Feb 2014 09:42 +0100
Message-ID: <1905162.oG8AgdvPKu@fb07-iapwap2>
References: <1391802529-29861-1-git-send-email-marek@goldelico.com> <20140210101842.GS25314@e106331-lin.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Marek Belisko <marek@goldelico.com>,
	"robh+dt@kernel.org" <robh+dt@kernel.org>,
	Pawel Moll <Pawel.Moll@arm.com>,
	"ijc+devicetree@hellion.org.uk" <ijc+devicetree@hellion.org.uk>,
	"galak@codeaurora.org" <galak@codeaurora.org>,
	"rob@landley.net" <rob@landley.net>,
	"linville@tuxdriver.com" <linville@tuxdriver.com>,
	"johannes@sipsolutions.net" <johannes@sipsolutions.net>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"grant.likely@linaro.org" <grant.likely@linaro.org>,
	"neilb@suse.de" <neilb@suse.de>,
	"hns@goldelico.com" <hns@goldelico.com>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Mark Rutland <mark.rutland@arm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140210101842.GS25314@e106331-lin.cambridge.arm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Montag, 10. Februar 2014, 10:18:42 schrieb Mark Rutland:
> On Fri, Feb 07, 2014 at 07:48:49PM +0000, Marek Belisko wrote:
> > Signed-off-by: NeilBrown <neilb@suse.de>
> > Signed-off-by: Marek Belisko <marek@goldelico.com>
> > ---
> > Based on Neil's patch and extend for documentation and bindings include.
> > 
> >  .../bindings/net/rfkill/rfkill-relugator.txt       | 28 ++++++++++++++++
> >  include/dt-bindings/net/rfkill-regulator.h         | 23 +++++++++++++
> >  net/rfkill/rfkill-regulator.c                      | 38
> >  ++++++++++++++++++++++ 3 files changed, 89 insertions(+)
> >  create mode 100644
> >  Documentation/devicetree/bindings/net/rfkill/rfkill-relugator.txt create
> >  mode 100644 include/dt-bindings/net/rfkill-regulator.h
> > 
> > diff --git
> > a/Documentation/devicetree/bindings/net/rfkill/rfkill-relugator.txt
> > b/Documentation/devicetree/bindings/net/rfkill/rfkill-relugator.txt new
> > file mode 100644
> > index 0000000..cdb7dd7
> > --- /dev/null
> > +++ b/Documentation/devicetree/bindings/net/rfkill/rfkill-relugator.txt
> > @@ -0,0 +1,28 @@
> > +Regulator consumer for rfkill devices
> 
> What exactly is an "rfkill" device? How is it used? How does it relate
> to other devices in the DT?
> 
> To me, this looks like a leak of a Linux abstraction.
> 
> > +
> > +Required properties:
> > +- compatible   : Must be "rfkill-regulator".
> > +- label  : Name of rfkill device.
> 
> What's this for? Why does this need a label in the DT? Surely this can
> be implied by the relationship to a particular radio device?
> 
> > +- type  : Type of rfkill device.
> > +
> > +Possible values (defined in include/dt-bindings/net/rfkill-regulator.h):
> > +	RFKILL_TYPE_ALL
> > +	RFKILL_TYPE_WLAN
> > +	RFKILL_TYPE_BLUETOOTH
> > +	RFKILL_TYPE_UWB
> > +	RFKILL_TYPE_WIMAX
> > +	RFKILL_TYPE_WWAN
> > +	RFKILL_TYPE_GPS
> > +	RFKILL_TYPE_FM
> > +	RFKILL_TYPE_NFC
> 
> What do these mean? Why can these not be implied by a relationship to
> any devices of these particular types?

This problem comes up from time to time. rfkill-gpio has a similar problem, 
btw. You can of course list an rfkill property inside the device node where it 
is connected to, but what are you going to to if there is no device node, e.g. 
the device is enumerated on a bus (e.g. usb, pci, ...)?

In such cases it may be better to define a standalone rfkill node similar to 
the "backlight" device, even if it just contains a gpio or regulator.

Marc
