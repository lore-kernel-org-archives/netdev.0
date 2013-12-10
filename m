From: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Subject: Re: Re: [PATCH 04/10] net: stmmac: sunxi platfrom
 extensions for GMAC in Allwinner A20 SoC's
Date: Tue, 10 Dec 2013 21:14:28 +0100
Message-ID: <20131210201428.GF3651@lukather>
References: <1386350983-13281-1-git-send-email-wens@csie.org>
 <1386350983-13281-5-git-send-email-wens@csie.org>
 <52A5A52C.50605@st.com>
 <52A5ECF4.6030301@redhat.com>
 <CAGb2v64LNxnz--vn0u9zwmt7MQJZ=uz2fs0H3zDSse_XDfdK4Q@mail.gmail.com>
 <52A61435.6040803@redhat.com>
Reply-To: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="DO5DiztRLs659m5i"
Cc: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>,
	linux-sunxi <linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
	Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Rob Herring <rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org>,
	devicetree <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Hans de Goede <hdegoede-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-sunxi+bncBD2ZNBF5VYJRBR7MTWKQKGQE3M6Z5RY-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <52A61435.6040803-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org


--DO5DiztRLs659m5i
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Dec 09, 2013 at 08:04:21PM +0100, Hans de Goede wrote:
> >>Now reading this has also made me take a closer look at wens' patch
> >>for this. Wens, I see that you directly modify registers in the ccm
> >>that is a big no-no instead you should add a helper function to
> >>sunxi-clk.c and use that, see ie:
> >>https://bitbucket.org/emiliolopez/linux/commits/2b95847d9aa4aa13317dd73=
58ffcbd951dcb5eff?at=3Dmaster
> >
> >Yes, this has been raised by Maxime. The odd "GMAC_IF_TYPE_RGMII" or
> >"gmac interface type bit" has been bugging me.
> >
> >Additionally, the TX clock has 2 inputs (not counting MII [1]).
> >The internal one is most likely controlled by the GMAC. The clock
> >rate is set internally to match the link speed. The external clock
> >source has controllable dividers to get the correct clock rate.
> >This shouldn't be hard to model with CCF though.
> >
> >In hardware, this is probably a mux between the GMAC clock generator
> >and the GMAC data transmit logic.
> >
> >My current plan is to choose MII when the clock is disabled,
> >and choose either of the inputs when it is enabled. I will
> >have to learn more about the CCF first.
>=20
> OK, in this case I would be tempted to just go with a custom sunxi
> function in the sunx-clk mode like what we have for the mmc stuff,
> but if you think you can model this with the regular clock stuff,
> that is of course fine too :)

Note that it's also ok to implement the clock driver out of
drivers/clk if it makes more sense.

So, if it's more convenient for you to declare both drivers (clock and
gmac), say in the glue file, I'm totally fine whith that.

Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com

--DO5DiztRLs659m5i
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIcBAEBAgAGBQJSp3YkAAoJEBx+YmzsjxAg/K8P/34ciYZeysTMk2NVR0N3qHwj
bNuhcUX2KwjQ9qXCJTyN/RTBppOV/acwuO/cs4Jjub6HHr0uEp8LlLF+HfF4D3jP
UtlucK6f4JU+C+P9tGAGTIWhPibtzrjSIWFBdtdMWKFLvyLoL5cTavW2dl+QCk/A
qB/O5L/NZKzlp/gcMFUqcg8iF1YVspyIWoVgBcgorz5eOxihZzJiP7aOCPkY+o9J
nk160S8K8CIFH30q6VGs+0CvrFIW4LMMDv8dNUEWF5ZDPKFESHi3DZZ1/tZSLx/n
yvBXjtL+8v/vbAQ95CPZTZQVXSRULmxM/s4R9zsYGyGiytPBb6h/0xEHyKDKGwDI
Yr7LpVM5ZXV80exyDLsTvlLh69jfdGWWcf2b8lBGVcywlyMzTctbPMOXG++QJGYZ
03IYWc1Uw8Pj72nGlV0M8QRWXvSSQ20/enFFGkkm3vMZjMEEXshJcNBCll/ypP3O
v/HBz82WzAXBgXqDoZK61jCLKjk1T468JSyJLdOPoutiXQCvXnhaEbA6xBhH7qX6
R4rapzOGPIRDTTcdd8B9+3EMa5JhRG7f0Oa/zobwNJDZz0kejECZv2alOtfoBfVP
21vqdSt0UrYRLHYIhTK+gyQ/1hQKgKJeWfSp2dkfzmOVn02jap/hohTOT9t6FXj/
gcN58a65Ax21p0kPGJSW
=DIkT
-----END PGP SIGNATURE-----

--DO5DiztRLs659m5i--
