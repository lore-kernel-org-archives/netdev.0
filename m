From: Tomasz Figa <tomasz.figa@gmail.com>
Subject: Re: [PATCH 4/4] wl1251: spi: add device tree support
Date: Mon, 28 Oct 2013 23:38:36 +0100
Message-ID: <4893578.SBstXOAcJY@flatron>
References: <1382890469-25286-1-git-send-email-sre@debian.org> <1382890469-25286-5-git-send-email-sre@debian.org> <FF34C626-4A49-43B1-B0AD-DC6146ABBB11@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Kumar Gala <galak@codeaurora.org>,
	Sebastian Reichel <sre@debian.org>,
	Mark Rutland <mark.rutland@arm.com>, linux-doc@vger.kernel.org,
	Tony Lindgren <tony@atomide.com>,
	Russell King <linux@arm.linux.org.uk>,
	Sachin Kamat <sachin.kamat@linaro.org>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Sebastian Reichel <sre@ring0.de>,
	Luciano Coelho <luca@coelho.fi>, devicetree@vger.kernel.org,
	Pawel Moll <pawel.moll@arm.com>,
	Stephen Warren <swarren@wwwdotorg.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Rob Herring <rob.herring@calxeda.com>,
	Bill Pemberton <wfp5p@virginia.edu>,
	linux-omap@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	Felipe Balbi <balbi@ti.com>, Rob Landley <rob@landley.net>,
	netdev@vger.kernel.org
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <FF34C626-4A49-43B1-B0AD-DC6146ABBB11@codeaurora.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 28 of October 2013 01:37:34 Kumar Gala wrote:
> On Oct 27, 2013, at 11:14 AM, Sebastian Reichel wrote:
> > Add device tree support for the spi variant of wl1251
> > and document the binding.
> > 
> > Signed-off-by: Sebastian Reichel <sre@debian.org>
> > ---
> > .../devicetree/bindings/net/wireless/ti,wl1251.txt | 36
> > ++++++++++++++++++++++ drivers/net/wireless/ti/wl1251/spi.c          
> >     | 23 ++++++++++---- 2 files changed, 53 insertions(+), 6
> > deletions(-)
> > create mode 100644
> > Documentation/devicetree/bindings/net/wireless/ti,wl1251.txt
> > 
> > diff --git
> > a/Documentation/devicetree/bindings/net/wireless/ti,wl1251.txt
> > b/Documentation/devicetree/bindings/net/wireless/ti,wl1251.txt new
> > file mode 100644
> > index 0000000..5f8a154
> > --- /dev/null
> > +++ b/Documentation/devicetree/bindings/net/wireless/ti,wl1251.txt
> > @@ -0,0 +1,36 @@
> > +* Texas Instruments wl1251 controller
> > +
> > +The wl1251 chip can be connected via SPI or via SDIO. The linux
> > +kernel currently only supports device tree for the SPI variant.
> > +
> 
> From the binding I have no idea what this chip actually does, also we
> don't normally reference linux kernel support in bindings specs (so
> please remove it).
> 
> However, what would expect the SDIO binding to look like?  Or more
> specifically, how would you distinguish the SPI vs SDIO
> binding/connection?  I'm wondering if the compatible should be
> something like "ti,wl1251-spi" and than the sdio can be
> "ti,wl1251-sdio"

Well, you can easily distinguish an SDIO device from an SPI device by its 
parent node, but...

The binding for SDIO might require different set of properties (other than 
ones inherited from generic SDIO or SPI bindings) than one for SPI. So 
probably different compatible values might be justified.

Did we already have such case before? (maybe some I2C + SPI devices?)

> > +Required properties:
> > +- compatible : Should be "ti,wl1251"
> 
> reg is not listed as a required prop.

It is implied by SPI bindings, but it might be a good idea to have this 
stated here as well.

> 
> > +- interrupts : Should contain interrupt line
> > +- interrupt-parent : Should be the phandle for the interrupt
> > +  controller that services interrupts for this device
> > +- vio-supply : phandle to regulator providing VIO
> > +- power-gpio : GPIO connected to chip's PMEN pin
> 
> should be vendor prefixed: ti,power-gpio

Hmm, out of curiosity, is it a rule for this kind of properties? I can see 
both cases with and without prefixes when grepping for "-gpios" in 
Documentation/devicetree/bindings. We should really have such things 
written down somewhere.

> 
> > +- For additional required properties on SPI, please consult
> > +  Documentation/devicetree/bindings/spi/spi-bus.txt
> > +
> > +Optional properties:
> > +- ti,use-eeprom : If found, configuration will be loaded from eeprom.
> 
> can you be a bit more specific on what cfg will be loaded.  Also, is
> this property a boolean, if so how do I know which eeprom the cfg is
> loaded from (is it one that is directly connected to the wl1251?

Maybe one from ti,has-eeprom or ti,config-eeprom would be better name for 
this property?

Best regards,
Tomasz

