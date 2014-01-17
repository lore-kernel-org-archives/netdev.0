From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH RFC 4/6] net: rfkill: gpio: add device tree support
Date: Fri, 17 Jan 2014 21:13:13 +0100
Message-ID: <201401172113.14322.arnd@arndb.de>
References: <1389941251-32692-1-git-send-email-wens@csie.org> <201401171747.46332.arnd@arndb.de> <CAGb2v67UKiyfJbKZ_Frk3OwZupMPoA2Ck3Hj2zsRFXBQPztavg@mail.gmail.com>
Reply-To: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: Text/Plain; charset=ISO-8859-1
Cc: "linux-arm-kernel" <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
 Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
 "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
 devicetree <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 "linux-wireless" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 "linux-sunxi" <linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 "linux-kernel" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
 Alexandre Courbot <gnurou-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 linux-gpio-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Chen-Yu Tsai" <wens-jdAy2FN1RRM@public.gmane.org>,
 Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Return-path: <linux-sunxi+bncBDEKVJM7XAHRBYU542LAKGQEEMDUROY-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
In-Reply-To: <CAGb2v67UKiyfJbKZ_Frk3OwZupMPoA2Ck3Hj2zsRFXBQPztavg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org

On Friday 17 January 2014, Chen-Yu Tsai wrote:
> On Sat, Jan 18, 2014 at 12:47 AM, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org> wrote:
> > On Friday 17 January 2014, Chen-Yu Tsai wrote:
> >> diff --git a/Documentation/devicetree/bindings/rfkill/rfkill-gpio.txt b/Documentation/devicetree/bindings/rfkill/rfkill-gpio.txt
> >> new file mode 100644
> >> index 0000000..8a07ea4
> >> --- /dev/null
> >> +++ b/Documentation/devicetree/bindings/rfkill/rfkill-gpio.txt
> >> @@ -0,0 +1,26 @@
> >> +GPIO controlled RFKILL devices
> >> +
> >> +Required properties:
> >> +- compatible   : Must be "rfkill-gpio".
> >> +- rfkill-name  : Name of RFKILL device
> >> +- rfkill-type  : Type of RFKILL device: 1 for WiFi, 2 for BlueTooth
> >> +- NAME_shutdown-gpios  : GPIO phandle to shutdown control
> >> +                         (phandle must be the second)
> >> +- NAME_reset-gpios     : GPIO phandle to reset control
> >> +
> >> +NAME must match the rfkill-name property. NAME_shutdown-gpios or
> >> +NAME_reset-gpios, or both, must be defined.
> >> +
> >
> > I don't understand this part. Why do you include the name in the
> > gpios property, rather than just hardcoding the property strings
> > to "shutdown-gpios" and "reset-gpios"?
> 
> This quirk is a result of how gpiod_get_index implements device tree
> lookup. You'll also notice that the shutdown GPIO must be the second
> phandle, as the driver uses indexed lookup to support ACPI cases.
> If con_id is given, it is prepended to "gpios" as the property string.
> con_id is also used as the label passed to gpiod_request, which is
> then shown in /sys/kernel/debug/gpio.

The Linux implementation should not enforce an inferior DT binding.
I think it would be better to change the code instead and make this
work with a more sensible representation.

> I can do a seperate lookup for the device tree case, with or without
> fallback to platform lookup tables. Then the names can be "reset-gpio"
> and "shutdown-gpio". Need to promote gpiod_request to non-static so
> we can register usage of the gpio, to match non-dt code path.
> 
> Personally I prefer adding a "label" parameter to gpiod_get_index, so
> we can use a different name than con_id. con_id isn't used in the ACPI
> case, and is optional in platform lookup case. However device tree
> lookup is dependent on this. What I see is non-uniform behavior
> between the three. In my opinion this is undesirable, but I haven't
> come up with a good solution yet.

(adding the gpio people here). I don't understand enough of the
current API to make a good call here, but I agree that we should try
to make it more uniform and do it in a way that allows simpler DT
bindings for devices using it.

> About the property string, is the plural form required, even though we
> only want one?

I would keep the plural form for consistency.

	Arnd
