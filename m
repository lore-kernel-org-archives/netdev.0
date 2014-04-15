From: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 7/7] ARM: sun7i: cubietruck: enable
 bluetooth module
Date: Tue, 15 Apr 2014 16:42:15 +0200
Message-ID: <20140415144215.GG3207@lukather>
References: <1397544101-18135-1-git-send-email-wens@csie.org>
 <1397544101-18135-8-git-send-email-wens@csie.org>
Reply-To: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Wtrm9ATX0sn6fFKv"
Cc: Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Heikki Krogerus <heikki.krogerus-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	Mika Westerberg <mika.westerberg-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	Alexandre Courbot <gnurou-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Stephen Warren <swarren-3lzwWm7+Weoh9ZMKESR00Q@public.gmane.org>, linux-gpio-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
To: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
Return-path: <linux-sunxi+bncBD2ZNBF5VYJRB4ELWWNAKGQETP7QQLQ-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1397544101-18135-8-git-send-email-wens-jdAy2FN1RRM@public.gmane.org>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org


--Wtrm9ATX0sn6fFKv
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Apr 15, 2014 at 02:41:41PM +0800, Chen-Yu Tsai wrote:
> The CubieTruck has an AMPAK AP6210 WiFi+Bluetooth module. The Bluetooth
> part is a BCM20710 device connected to UART2 in the A20 SoC.
>=20
> The IC requires a 32.768 KHz low power clock input for proper
> auto-detection of the main clock, and an enable signal via GPIO.
>=20
> Signed-off-by: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
> ---
>  arch/arm/boot/dts/sun7i-a20-cubietruck.dts | 25 +++++++++++++++++++++++++
>  1 file changed, 25 insertions(+)
>=20
> diff --git a/arch/arm/boot/dts/sun7i-a20-cubietruck.dts b/arch/arm/boot/d=
ts/sun7i-a20-cubietruck.dts
> index cb25d3c..767c8e1 100644
> --- a/arch/arm/boot/dts/sun7i-a20-cubietruck.dts
> +++ b/arch/arm/boot/dts/sun7i-a20-cubietruck.dts
> @@ -61,6 +61,13 @@
>  				allwinner,drive =3D <0>;
>  				allwinner,pull =3D <0>;
>  			};
> +
> +			bt_pwr_pin_cubietruck: bt_pwr_pin@0 {
> +				allwinner,pins =3D "PH18";
> +				allwinner,function =3D "gpio_out";
> +				allwinner,drive =3D <0>;
> +				allwinner,pull =3D <0>;
> +			};
>  		};
> =20
>  		uart0: serial@01c28000 {
> @@ -69,6 +76,12 @@
>  			status =3D "okay";
>  		};
> =20
> +		uart2: serial@01c28800 {
> +			pinctrl-names =3D "default";
> +			pinctrl-0 =3D <&uart2_pins_a>;
> +			status =3D "okay";
> +		};
> +

Please make this a separate patch.

>  		i2c0: i2c@01c2ac00 {
>  			pinctrl-names =3D "default";
>  			pinctrl-0 =3D <&i2c0_pins_a>;
> @@ -139,4 +152,16 @@
>  	reg_usb2_vbus: usb2-vbus {
>  		status =3D "okay";
>  	};
> +
> +	rfkill_bt {
> +		compatible =3D "rfkill-gpio";
> +		pinctrl-names =3D "default";
> +		pinctrl-0 =3D <&bt_pwr_pin_cubietruck>, <&clk_out_a_pins_a>;
> +		clocks =3D <&clk_out_a>;
> +		clock-frequency =3D <32768>;
> +		gpios =3D <&pio 7 18 0>; /* PH18 */
> +		gpio-names =3D "reset";
> +		rfkill-name =3D "bt";
> +		rfkill-type =3D <2>;
> +	};

Hmmm, I don't think that's actually right.

If you have such a device, then I'd expect it to be represented as a
full device in the DT, probably with one part for the WiFi, one part
for the Bluetooth, and here the definition of the rfkill device that
controls it.

But tying parts of the device to the rfkill that controls it, such as
the clocks, or the frequency it runs at seems just wrong.

Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com

--Wtrm9ATX0sn6fFKv
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIcBAEBAgAGBQJTTUVHAAoJEBx+YmzsjxAg6TMP/0G0r2/dNXOxOM8l6eWhk4VH
gQq6tk1gX+Bkb9YfFFWl4GtPcRVD7lTeX6NoVhQtTLGGSctuVaojsOJ6UvIPg3K/
JYTNf2QBk4b0pmzpST+l2pDzbGr+SzByKjL85eKZdZvmbm9LJJit8SxEGVKHFhAz
ztDfUlmotR7nZtculXRkxAow7uNsoRmVWVGWpifVJGtIqqYD+TAaSc+2W7xaLFF8
bRh7Ri0jdtBQeaegVVTm/COEdAGmBH32exW4d0v2edvdDdnKTI/PLzkvk5YI1vhm
6S5Vm/sL644ZeGCH6/9A84zrRoqsceJuGVIxc5BkG2mm88UPh0Nx1mAheO5jvh3A
VjaKT0hNAvDEF7FKRUDbhK+cLPyWpfkc+vDaKJgJtZ6fBlj3nrB4pxHwYbIGGfPv
VCAJSQBhplGYTbERO4S4UHQwMZ74N1RRVDs4mM+2hGrv8wryYkE/FlTX75bd64Py
+HMdcJIOo2xsvF4DmHk0NvKWgkJUT1yAmaCnoWzrbykza/Kwisn4Goj6QQfQJCFT
9New/zkrYOXTy7jTnSRfNFb7ItkaD19MFDR4vLzd416PdJkRX8U5H6OLCqVrUdtj
S67EIjvS/kPOV4QYcyrrpGwGm4Sy+hBEgn82mZmZ6SjVz/ou5aW9uD1PXh2DBoSi
6wvwNOvHBcutEks+WwlF
=071c
-----END PGP SIGNATURE-----

--Wtrm9ATX0sn6fFKv--
