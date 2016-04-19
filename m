From: "Reizer, Eyal" <eyalr-l0cyMroinI0@public.gmane.org>
Subject: RE: [PATCHv2] wlcore: spi: add wl18xx support
Date: Tue, 19 Apr 2016 09:05:45 +0000
Message-ID: <8665E2433BC68541A24DFFCA87B70F5B360C0745@DFRE01.ent.ti.com>
References: <1460273570-12298-1-git-send-email-eyalr@ti.com>
 <14313437.cDJIgY3kzo@wuerfel>
 <8665E2433BC68541A24DFFCA87B70F5B360BF614@DFRE01.ent.ti.com>
 <1463330011.BhWEcYYuGD@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Eyal Reizer <eyalreizer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-spi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-spi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <linux-spi-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1463330011.BhWEcYYuGD@wuerfel>
Content-Language: en-US
Sender: linux-spi-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Arnd,

> > > >
> > > > - all wilink family needs special init command for entering wspi mode.
> > > >   extra clock cycles should be sent after the spi init command while the
> > > >   cs pin is high.
> > > > - switch to controling the cs pin from the spi driver for achieveing the
> > > >   above.
> > > > - the selected cs gpio is read from the spi device-tree node using the
> > > >   cs-gpios field and setup as a gpio.
> > > > - See the example below for specifying the cs gpio using the cs-gpios
> entry
> > > > &spi0   {
> > > >         ...
> > > >         cs-gpios = <&gpio0 5 0>;
> > > >         ...
> > > >         wlcore: wlcore@0 {
> > > >                 compatible = "ti,wl1835";
> > > >         ...
> > > >         ...
> > > >         };
> > > > };
> > > >
> > > > Signed-off-by: Eyal Reizer <eyalr-l0cyMroinI0@public.gmane.org>
> > >
> > > I don't think this can work in general: not all SPI hosts uses GPIOs
> > > for controlling CS, so the logic can't work, and it's also a
> > > layering violation for the driver to look at the parent.
> > >
> > > I would suggest fixing this using a new API function from the SPI
> > > core, if we don't already have a generic way to do it.
> > >
> > Originally this is what I have done until I was pointed to the generic
> > cs-gpio mechanism in the SPI core.
> > It is a generic mechanism already in the SPI core driver.
> > See: Documentation/devicetree/bindings/spi/spi-bus.txt
> 
> The cs-gpios property is documented as optional, it defines how you should
> list the gpios if CS is implemented using gpio, but not all hardware does it like
> this.
> 
> > It is also part of the generic spi.h (include/Linux/spi/spi.h),
> > already part of " struct spi_device" So it seemed redundant adding
> > another mechanism for implementing the same.
> > Platform that interact with a wilink need to use it, and platforms
> > that don't have this capability will probably not interact with a wilink device
> using SPI.
> 
> The cs_gpio field in spi_device belongs to the spi host controller, no other
> slave driver uses it.
> 
> I wasn't asking for a duplication of this mechanism, but an interface to use it
> properly. Internally, the spi core uses the spi_set_cs() function to pick a CS.
> Find a way to use that rather than reimplementing it incorrectly.
> 

Understood. As this special CS manipulation is unique to wspi (wilink spi)  I think the 
best option is to move this gpio allocation into wlcore_spi as a new device tree entry
used only by this driver.
If you agree I will submit a v3.

Best Regards,
Eyal
--
To unsubscribe from this list: send the line "unsubscribe linux-spi" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
