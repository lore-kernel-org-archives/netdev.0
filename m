From: "Reizer, Eyal" <eyalr-l0cyMroinI0@public.gmane.org>
Subject: RE: [PATCHv2] wlcore: spi: add wl18xx support
Date: Mon, 18 Apr 2016 05:55:51 +0000
Message-ID: <8665E2433BC68541A24DFFCA87B70F5B360BF614@DFRE01.ent.ti.com>
References: <1460273570-12298-1-git-send-email-eyalr@ti.com>
 <8665E2433BC68541A24DFFCA87B70F5B360B6C90@DFRE01.ent.ti.com>
 <14313437.cDJIgY3kzo@wuerfel>
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
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <14313437.cDJIgY3kzo@wuerfel>
Content-Language: en-US
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> >
> > - all wilink family needs special init command for entering wspi mode.
> >   extra clock cycles should be sent after the spi init command while the
> >   cs pin is high.
> > - switch to controling the cs pin from the spi driver for achieveing the
> >   above.
> > - the selected cs gpio is read from the spi device-tree node using the
> >   cs-gpios field and setup as a gpio.
> > - See the example below for specifying the cs gpio using the cs-gpios entry
> > &spi0   {
> >         ...
> >         cs-gpios = <&gpio0 5 0>;
> >         ...
> >         wlcore: wlcore@0 {
> >                 compatible = "ti,wl1835";
> >         ...
> >         ...
> >         };
> > };
> >
> > Signed-off-by: Eyal Reizer <eyalr-l0cyMroinI0@public.gmane.org>
> 
> I don't think this can work in general: not all SPI hosts uses GPIOs for
> controlling CS, so the logic can't work, and it's also a layering violation for the
> driver to look at the parent.
> 
> I would suggest fixing this using a new API function from the SPI core, if we
> don't already have a generic way to do it.
>
Originally this is what I have done until I was pointed to the generic cs-gpio mechanism 
in the SPI core. 
It is a generic mechanism already in the SPI core driver.
See: Documentation/devicetree/bindings/spi/spi-bus.txt

It is also part of the generic spi.h (include/Linux/spi/spi.h), already part of 
" struct spi_device" So it seemed redundant adding another mechanism for 
implementing the same.
Platform that interact with a wilink need to use it, and platforms that don't  
have this capability will probably not interact with a wilink device using SPI.

Best Regards,
Eyal



--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
