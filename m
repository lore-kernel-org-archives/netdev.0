From: Johan Hovold <johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 19/22] dt/bindings: add micrel,rmii_ref_clk_sel_25_mhz to
 eth-phy binding
Date: Tue, 11 Nov 2014 19:18:25 +0100
Message-ID: <20141111181825.GH29789@localhost>
References: <1415727460-20417-1-git-send-email-johan@kernel.org>
 <1415727460-20417-20-git-send-email-johan@kernel.org>
 <20141111175741.GF25295@leverpostej>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johan Hovold <johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20141111175741.GF25295@leverpostej>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 11, 2014 at 05:57:42PM +0000, Mark Rutland wrote:
> On Tue, Nov 11, 2014 at 05:37:37PM +0000, Johan Hovold wrote:
> > Add "micrel,rmii_ref_clk_sel_25_mhz" to Micrel ethernet PHY binding
> > documentation.
> > 
> > Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> > Signed-off-by: Johan Hovold <johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> > ---
> >  Documentation/devicetree/bindings/net/micrel.txt | 5 +++++
> >  1 file changed, 5 insertions(+)
> > 
> > diff --git a/Documentation/devicetree/bindings/net/micrel.txt b/Documentation/devicetree/bindings/net/micrel.txt
> > index a1bab5eaae02..9b08dd6551dd 100644
> > --- a/Documentation/devicetree/bindings/net/micrel.txt
> > +++ b/Documentation/devicetree/bindings/net/micrel.txt
> > @@ -19,6 +19,11 @@ Optional properties:
> >  
> >                See the respective PHY datasheet for the mode values.
> >  
> > + - micrel,rmii_ref_clk_sel_25_mhz: rmii_ref_clk_sel bit selects 25 MHz mode
> > +
> > +		Whether 25 MHz (rather than 50 Mhz) clock mode is selected
> > +		when the rmii_ref_clk_sel bit is set.
> 
> s/_/-/ in property names please.

Ouch, copied from variable name, sorry.

> That said, I don't follow the meaning. Does this cause the kernel to do
> something different, or is is simply that a 25MHz ref clock is wired up?

Yes, the driver currently sets this configuration bit based on a common
clock binding.

However, it turns out the meaning of the bit is reversed on some PHY
variants. On most PHYs 50 MHz mode is selected by setting this bit,
whereas on the PHYs that need this new property, setting it selects 25
MHz mode instead.

> Surely that should be described via the common clock bindings? Or if
> internal through a clock-frequency property?

The driver currently selects the mode using the common clock bindings,
but this new property is needed to properly handle those PHY variants on
which the clock configuration bit has the reverse meaning.

Thanks,
Johan
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
