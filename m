From: "Reizer, Eyal" <eyalr-l0cyMroinI0@public.gmane.org>
Subject: RE: [PATCHv2] wlcore: spi: add wl18xx support
Date: Tue, 19 Apr 2016 14:35:24 +0000
Message-ID: <8665E2433BC68541A24DFFCA87B70F5B360C0C5D@DFRE01.ent.ti.com>
References: <1460273570-12298-1-git-send-email-eyalr@ti.com>
 <1463330011.BhWEcYYuGD@wuerfel>
 <8665E2433BC68541A24DFFCA87B70F5B360C0745@DFRE01.ent.ti.com>
 <4133521.UUI3B1RTyv@wuerfel>
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
In-Reply-To: <4133521.UUI3B1RTyv@wuerfel>
Content-Language: en-US
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> > > > It is also part of the generic spi.h (include/Linux/spi/spi.h),
> > > > already part of " struct spi_device" So it seemed redundant adding
> > > > another mechanism for implementing the same.
> > > > Platform that interact with a wilink need to use it, and platforms
> > > > that don't have this capability will probably not interact with a
> > > > wilink device
> > > using SPI.
> > >
> > > The cs_gpio field in spi_device belongs to the spi host controller,
> > > no other slave driver uses it.
> > >
> > > I wasn't asking for a duplication of this mechanism, but an
> > > interface to use it properly. Internally, the spi core uses the spi_set_cs()
> function to pick a CS.
> > > Find a way to use that rather than reimplementing it incorrectly.
> > >
> >
> > Understood. As this special CS manipulation is unique to wspi (wilink
> > spi)  I think the best option is to move this gpio allocation into
> > wlcore_spi as a new device tree entry used only by this driver.
> > If you agree I will submit a v3.
> 
> I don't think that can work either: aside of not solving the problem of wilink
> devices on spi controllers that don't use gpio, it also doesn't solve the
> problem of what happens when the driver manually triggers the gpio to hold
> the CS signal while another driver talks to a different device using another CS
> on the same controller.
> 
Ok, understood. Will look into it.

Best Regards,
Eyal
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
