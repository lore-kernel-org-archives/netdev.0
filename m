From: "Reizer, Eyal" <eyalr-l0cyMroinI0@public.gmane.org>
Subject: RE: [PATCH] wlcore: spi: add wl18xx support
Date: Thu, 7 Apr 2016 12:45:13 +0000
Message-ID: <8665E2433BC68541A24DFFCA87B70F5B360B5430@DFRE01.ent.ti.com>
References: <1459343218-24536-1-git-send-email-eyalr@ti.com>
 <87shyx38tz.fsf@purkki.adurom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Eyal Reizer <eyalreizer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87shyx38tz.fsf-5ukZ45wKbUHoml4zekdYB16hYfS7NtTn@public.gmane.org>
Content-Language: en-US
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Kalle Valo [mailto:kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org]
> Sent: Thursday, April 07, 2016 3:25 PM
> To: Eyal Reizer
> Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-
> kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; Reizer, Eyal; devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Subject: Re: [PATCH] wlcore: spi: add wl18xx support
> 
> Eyal Reizer <eyalreizer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
> 
> > Add support for using with both wl12xx and wl18xx.
> >
> > - all wilink family needs special init command for entering wspi mode.
> >   extra clock cycles should be sent after the spi init command while the
> >   cs pin is high.
> > - switch to controling the cs pin from the spi driver for achieveing the
> >   above.
> > - the selected cs gpio is read from the spi device-tree node using the
> >   cs-gpios field and setup as a gpio.
> > - See the example below for specifying the cs gpio using the cs-gpios
> > entry
> >
> > &spi0	{
> >  	status = "okay";
> > 	pinctrl-names = "default";
> > 	pinctrl-0 = <&spi0_pins>;
> > 	cs-gpios = <&gpio0 5 0>;
> > 	#address-cells = <1>;
> > 	#size-cells = <0>;
> >  	wlcore: wlcore@0 {
> > 		compatible = "ti,wl1835";
> > 		vwlan-supply = <&wlan_en_reg>;
> > 		spi-max-frequency = <48000000>;
> > 		reg = <0>;      /* chip select 0 on spi0, ie spi0.0 */
> > 		interrupt-parent = <&gpio0>;
> > 		interrupts = <27 IRQ_TYPE_EDGE_RISING>;
> >  	};
> > };
> >
> > Signed-off-by: Eyal Reizer <eyalr-l0cyMroinI0@public.gmane.org>
> 
> [...]
> 
> >  static const struct of_device_id wlcore_spi_of_match_table[] = {
> > -	{ .compatible = "ti,wl1271" },
> > +	{ .compatible = "ti,wl1271", .data = &wl12xx_data},
> > +	{ .compatible = "ti,wl1273", .data = &wl12xx_data},
> > +	{ .compatible = "ti,wl1281", .data = &wl12xx_data},
> > +	{ .compatible = "ti,wl1283", .data = &wl12xx_data},
> > +	{ .compatible = "ti,wl1801", .data = &wl18xx_data},
> > +	{ .compatible = "ti,wl1805", .data = &wl18xx_data},
> > +	{ .compatible = "ti,wl1807", .data = &wl18xx_data},
> > +	{ .compatible = "ti,wl1831", .data = &wl18xx_data},
> > +	{ .compatible = "ti,wl1835", .data = &wl18xx_data},
> > +	{ .compatible = "ti,wl1837", .data = &wl18xx_data},
> >  	{ }
> 
> Shouldn't you also update bindings/net/wireless/ti,wlcore,spi.txt? Now it only
> mentions about ti,wl1271 and not anything about the rest.

You are right! 
Will be fixed in v2

> 
> Adding devicetree list for further comments.
> 
> --
> Kalle Valo

Best Regards,
Eyal
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
