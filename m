From: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Subject: Re: Re: [PATCH 7/7] ARM: sun7i: cubietruck: enable
 bluetooth module
Date: Wed, 16 Apr 2014 11:44:28 +0200
Message-ID: <20140416094428.GK3207@lukather>
References: <1397544101-18135-1-git-send-email-wens@csie.org>
 <1397544101-18135-8-git-send-email-wens@csie.org>
 <20140415144215.GG3207@lukather>
 <CAGb2v643HyvFdhQ0znreB8ENXHWpcx6tFwdeU7VuU8KYWcT4ZA@mail.gmail.com>
Reply-To: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="M0YLxmUXciMpOLPE"
Cc: Linus Walleij <linus.walleij-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Heikki Krogerus <heikki.krogerus-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	Mika Westerberg <mika.westerberg-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	Alexandre Courbot <gnurou-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Stephen Warren <swarren-3lzwWm7+Weoh9ZMKESR00Q@public.gmane.org>, linux-gpio-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	devicetree <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>, Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
	Ian Campbell <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
	Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-sunxi+bncBD2ZNBF5VYJRBINCXGNAKGQEQY42T5Y-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAGb2v643HyvFdhQ0znreB8ENXHWpcx6tFwdeU7VuU8KYWcT4ZA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org


--M0YLxmUXciMpOLPE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

Please try to keep me in CC, even though the ML doesn't make it easy..

On Wed, Apr 16, 2014 at 12:06:59AM +0800, Chen-Yu Tsai wrote:
> >> @@ -139,4 +152,16 @@
> >>       reg_usb2_vbus: usb2-vbus {
> >>               status =3D "okay";
> >>       };
> >> +
> >> +     rfkill_bt {
> >> +             compatible =3D "rfkill-gpio";
> >> +             pinctrl-names =3D "default";
> >> +             pinctrl-0 =3D <&bt_pwr_pin_cubietruck>, <&clk_out_a_pins=
_a>;
> >> +             clocks =3D <&clk_out_a>;
> >> +             clock-frequency =3D <32768>;
> >> +             gpios =3D <&pio 7 18 0>; /* PH18 */
> >> +             gpio-names =3D "reset";
> >> +             rfkill-name =3D "bt";
> >> +             rfkill-type =3D <2>;
> >> +     };
> >
> > Hmmm, I don't think that's actually right.
> >
> > If you have such a device, then I'd expect it to be represented as a
> > full device in the DT, probably with one part for the WiFi, one part
> > for the Bluetooth, and here the definition of the rfkill device that
> > controls it.
>=20
> The AP6210 is not one device, but 2 separate chips in one module. Each
> chip has its own controls and interface. They just so happen to share
> the same enclosure. Even 2-in-1 chips by Broadcom have separate controls
> and interfaces. The WiFi side is most likely connected via SDIO, while
> the Bluetooth side is connected to a UART, and optionally I2S for sound.

It's even easier to represent then.

> > But tying parts of the device to the rfkill that controls it, such as
> > the clocks, or the frequency it runs at seems just wrong.
>=20
> I understand where you're coming from. For devices on buses that require
> drivers (such as USB, SDIO) these properties probably should be tied to
> the device node.
>=20
> For our use case here, which is a bluetooth chip connected on the UART,
> there is no in kernel representation or driver to tie them to. Same goes
> for UART based GPS chips. They just so happen to require toggling a GPIO,
> and maybe enabling a specific clock, to get it running. Afterwards,
> accessing it is done solely from userspace. For our Broadcom chips, the
> user has to upload its firmware first, then designate the tty as a Blueto=
oth
> HCI using hciattach.
>=20
> We are using the rfkill device as a on-off switch.

I understand your point, but the fact that it's implemented in
user-space, or that UART is not a bus (which probably should be), is
only a Linux specific story, and how it's implemented in Linux (even
if the whole rfkill node is another one, but let's stay on topic).

This is a huge abstraction leak.

Let's say you need the I2S stream you mentionned for some
reason. Would you tie the audio stream to the rfkill node as well?
I'm sorry, but from an hardware description perspective, it makes no
sense.

What's the feeling of the DT maintainers?

--=20
Maxime Ripard, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com

--M0YLxmUXciMpOLPE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIcBAEBAgAGBQJTTlD8AAoJEBx+YmzsjxAgVPwQAKcyyp/p/GnRDy8ccpJjEwr3
3zkuQuLLqKzgliOziUP4z/MARbVWAvx+U+tP7Rp6EDIc0hnjpu7OQJ71d7kGbr2q
HAbBhSmrpE+WRkLpEgDilVK6Tu495OBMD9GIJ/S5a53PXP6C37i5l4A88i04M2Cl
y70wTfpGEur5wiNtYK2hh9MYY2k9Kh7fIVEnHth9HlMfjgfNvdSJ+9SJxghhkx1r
zSRRcG/8b8MJiNsdqHAcKp6Jr0Hsn0mHUWt+/MYR0brjzOrO4oOx/CswFnBGHOGP
ZcZtPEigwaDdDowKuFL03V3exEvKdDLVXHn5sLRoyCOYyDO98MvT2LUAHNqQQA8K
ko7Yas67MynpkLqQaV9k3W85orJZ6jTCFBBbd3HzyShqWfiKsVAqW+j6wJI9r25Q
28/sSek95Dul42V6MzzpsLSUF7IFz2In7Wc6a/c5PZI9ix50Md4cBsEoqrWmenkp
iXtKRJUyBho6dyn6gNZlzmKGPbRWxGZguQOSrojYLZklj8D4dXymL/9rkpP3Iv2E
VihOmH6e3aIIWzQT5hZnRe4KM70d3nsS4KYFL9XasKOYikVspoVEr4nWQ+09idY+
RN69mnzGGLyJp16MRDHTHJlCyt5jQaRYdxb2eGhAory/tRvRv6UM1VzDqziSX17e
dkL5CE2xThjcTU5u8Pa/
=ix4Q
-----END PGP SIGNATURE-----

--M0YLxmUXciMpOLPE--
