From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH 19/22] dt/bindings: add micrel,rmii_ref_clk_sel_25_mhz to
 eth-phy binding
Date: Thu, 13 Nov 2014 09:09:27 +0100
Message-ID: <20141113080927.GP30369@pengutronix.de>
References: <1415727460-20417-1-git-send-email-johan@kernel.org>
 <1415727460-20417-20-git-send-email-johan@kernel.org>
 <20141111175741.GF25295@leverpostej>
 <20141111181825.GH29789@localhost>
 <20141112070127.GF30369@pengutronix.de>
 <20141112091920.GC15215@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mark Rutland <mark.rutland@arm.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Johan Hovold <johan@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141112091920.GC15215@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 12, 2014 at 10:19:20AM +0100, Johan Hovold wrote:
> On Wed, Nov 12, 2014 at 08:01:27AM +0100, Sascha Hauer wrote:
> > On Tue, Nov 11, 2014 at 07:18:25PM +0100, Johan Hovold wrote:
> > > On Tue, Nov 11, 2014 at 05:57:42PM +0000, Mark Rutland wrote:
> > > > On Tue, Nov 11, 2014 at 05:37:37PM +0000, Johan Hovold wrote:
> > > > > Add "micrel,rmii_ref_clk_sel_25_mhz" to Micrel ethernet PHY binding
> > > > > documentation.
> > > > > 
> > > > > Cc: devicetree@vger.kernel.org
> > > > > Signed-off-by: Johan Hovold <johan@kernel.org>
> > > > > ---
> > > > >  Documentation/devicetree/bindings/net/micrel.txt | 5 +++++
> > > > >  1 file changed, 5 insertions(+)
> > > > > 
> > > > > diff --git a/Documentation/devicetree/bindings/net/micrel.txt b/Documentation/devicetree/bindings/net/micrel.txt
> > > > > index a1bab5eaae02..9b08dd6551dd 100644
> > > > > --- a/Documentation/devicetree/bindings/net/micrel.txt
> > > > > +++ b/Documentation/devicetree/bindings/net/micrel.txt
> > > > > @@ -19,6 +19,11 @@ Optional properties:
> > > > >  
> > > > >                See the respective PHY datasheet for the mode values.
> > > > >  
> > > > > + - micrel,rmii_ref_clk_sel_25_mhz: rmii_ref_clk_sel bit selects 25 MHz mode
> > > > > +
> > > > > +		Whether 25 MHz (rather than 50 Mhz) clock mode is selected
> > > > > +		when the rmii_ref_clk_sel bit is set.
> > > > 
> > > > s/_/-/ in property names please.
> > > 
> > > Ouch, copied from variable name, sorry.
> > > 
> > > > That said, I don't follow the meaning. Does this cause the kernel to do
> > > > something different, or is is simply that a 25MHz ref clock is wired up?
> > > 
> > > Yes, the driver currently sets this configuration bit based on a common
> > > clock binding.
> > > 
> > > However, it turns out the meaning of the bit is reversed on some PHY
> > > variants. On most PHYs 50 MHz mode is selected by setting this bit,
> > > whereas on the PHYs that need this new property, setting it selects 25
> > > MHz mode instead.
> > 
> > Maybe rename the property to something like rmii-ref-clk-25mhz-active-high
> > then? Also you should probably make it more explicit that this is a
> > hardware property and not for adjusting the clock.
> 
> You're right, but how about calling it
> 
> 	micrel,rmii-reference-clock-select-inverted
> 
> Then no one will set it believing it will change the clock mode and
> without reading the binding doc first.
> 
> The description could then read something like
> 
> 	micrel,rmii-reference-clock-select-inverted: RMII Reference
> 		Clock Select bit is inverted
> 
> 	The RMII Reference Clock Select bit is inverted so that setting
> 	it selects 25 MHz rather than 50 MHz clock mode. 
> 
> 	Note that this is only needed for PHY variants that has this bit
> 	inverted and that a clock reference ("rmii-ref" below) is always
> 	needed to select the actual mode.

"Inverted" only has a meaning when everybody agrees what's the normal
case. Since that not the case I really prefer talking about
"active-high" or "active-low".

Sascha


-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
