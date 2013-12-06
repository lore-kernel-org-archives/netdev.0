From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: Re: [PATCH RFC 08/10] net: stmmac:sti: Add STi SOC glue driver.
Date: Fri, 6 Dec 2013 19:37:57 +0100
Message-ID: <20131206183757.GH24519@lukather>
References: <1384264311-7308-1-git-send-email-srinivas.kandagatla@st.com>
 <1384264383-7653-1-git-send-email-srinivas.kandagatla@st.com>
 <20131129193715.GA3441@lukather>
 <529C8198.7000106@st.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="dMyqICaxQaaUjrCL"
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	Rob Herring <rob.herring@calxeda.com>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Stephen Warren <swarren@wwwdotorg.org>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Rob Landley <rob@landley.net>,
	Russell King <linux@arm.linux.org.uk>,
	Stuart Menefy <stuart.menefy@st.com>,
	Pavel Machek <pavel@ucw.cz>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>,
	Len Brown <len.brown@intel.com>, stephen.gallimore@st.com,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Grant Likely <grant.likely@linaro.org>,
	devicetree@vger.kernel.org, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel@stlinux.com,
	linux-pm@vger.kernel.org
To: srinivas kandagatla <srinivas.kandagatla@st.com>
Return-path: <linux-doc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <529C8198.7000106@st.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--dMyqICaxQaaUjrCL
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Srinivas,

On Mon, Dec 02, 2013 at 12:48:24PM +0000, srinivas kandagatla wrote:
> Hi Maxime,
>=20
> Thankyou for the comments.
>=20
> On 29/11/13 19:37, Maxime Ripard wrote:
> >> +
> >> > +ethernet0: ethernet0{
> >> > +	#address-cells =3D <1>;
> >> > +	#size-cells =3D <1>;
> >> > +	compatible		=3D "st,stih415-dwmac";
> >> > +	reg			=3D <0x148 0x4>;
> >> > +	resets			=3D <&softreset STIH415_ETH0_SOFTRESET>;
> >> > +	st,syscon		=3D <&syscfg_rear>;
> >> > +	st,tx-retime-src	=3D "clk_125";
> >> > +	ranges;
> >> > +
> >> > +	dwmac0:dwmac@fe810000 {
> >> > +		device_type 	=3D "network";
> >> > +		compatible	=3D "snps,dwmac", "snps,dwmac-3.610";
> >> > +		reg 		=3D <0xfe810000 0x8000>;
> >> > +		interrupts 	=3D <0 147 0>;
> >> > +		interrupt-names =3D "macirq";
> >> > +		...
> >> > +	};
> >> > +};
> > Sorry for stepping up so late, but I dont' think this is the right way
> > to do it.
> >=20
> Not a issue.
>=20
> > DT is to describe how the hardware is laid out in a system agnostic
> > way, hence, it should not be impacted by the implementation details.
> >=20
> If "hardware is laid out" means at SoC level? Then I attempted to do
> describe it in system agnostic way.
>=20
> On ST SoCs "snps,dwmac" IP always has a hw glue layer on top of it.
>=20
> > The fact that you use a glue to the dwmac driver *is* an
> > implementation detail.
>=20
> Glue layer described here is actually a hardware glue on ST SoCs.

Ho, ok, it makes sense then :)

Sorry for the noise.

> > I think you'd rather have something like:
> >=20
> > dwmac0: ethernet@fe810000 {
> > 	compatible		=3D "st,stih415-dwmac";
> > 	reg 			=3D <0xfe810000 0x8000 0x148 0x4>;
> > 	resets			=3D <&softreset STIH415_ETH0_SOFTRESET>;
> > 	st,syscon		=3D <&syscfg_rear>;
> > 	st,tx-retime-src	=3D "clk_125";
> > 	interrupts 		=3D <0 147 0>;
> > 	interrupt-names 	=3D "macirq";Am happy to go with=20
> > 	...
> > };
> >=20
> > Then, the driver can have its init functions associated to the
> > compatible you're using, through the .data field of the of_device_id
> > structure, and you just call it in the generic driver at probe's time.
>=20
> This is changing the device tree bindings for the generic driver.
> Is this something Acceptable?

It really depends. As long as these are based on new compatibles, and
you require these new properties only for this new compatible, it's
fine most of the time.

> Peppe, are you Ok with such intrusive changes to the driver?
>=20
> I did try few things before I sent this patch,
>=20
> 1> Doing it via AUXDATA which was discouraged by Arnd.
>=20
> 2> Doing it the way you suggested which did not fit in very neatly,
> which looked like lot of SOC specific changes are added to generic driver.
>=20
> 3> Doing it as this patch, influenced by dwc3 code drivers/usb/dwc3/,
> Which fitted in very neatly without touching the existing generic driver.
>=20
> stmmac driver is a generic synopsis driver which ST has written the
> driver, so I did not want to pollute this driver with ST specific glue
> logic bindings.

Yeah, I didn't know that. My apologies.

Thanks,
Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com

--dMyqICaxQaaUjrCL
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIcBAEBAgAGBQJSohmFAAoJEBx+YmzsjxAgOdoQALD1sk4bw2m1nD5sUeasviJK
ho2hpWgijyP1cS9+4t7FAbY5mOc10Rxa2p40j0owP/vFGGTpSJL7t94kr8VjXDGj
g+04Z/ooP3ljC/rjzMQ4KtLfI4USVJ98lhTsv9sswI3rt37AQ3jkayLBmzXDS1yV
mriLLeWUk9r9DVbVyF+y7poLDAQbZNrRVR3+KcmICiq0OTZ9+2+Jp5Wfm+M40OSq
y+0iOT5a6xad4ELW63mhDKzs+dL61FxycgsEEE2E9ygsEwLtAz4hXENUNsDBZ+yo
z7zZUzgBpmlR8sPdIJsDEnmrg3ebMke/LTg8CigX0S9W27uGn0OzkjaVRwUYcUV1
mouM9HOf774vl3ZVJW6Kq34xU0/WrCupLSsT3tvKWuFNCnJ5RKVeONz6I8G8rAy/
jX52DP4DGgqdrE7TqI1mDtbL67/nD3M/9QQSNiNvfrUwBlbM0+VcJY7BnNMJpGya
faoWLBWrQ0nwiNwDYhLYAMjSeEQcpqmqZhH4MGknZ5Q9oV/xNZjOyYwAOOS1Jl1O
pSJ3gLz1fW+F0kemAUs3rYtIezZi29HyXe8YG0w0qakIJKl3bo3jRcb5qUcZA3lD
4wYdto+B5uV5GcSZKS+XF9VqB8yc7SrnjEHRyUWs2977557glYUcnU9CZdUwFwP3
q5vfPrJUel6INnPCsJXp
=EKC6
-----END PGP SIGNATURE-----

--dMyqICaxQaaUjrCL--
