From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: Re: [PATCH RFC 08/10] net: stmmac:sti: Add STi SOC glue driver.
Date: Fri, 29 Nov 2013 20:37:15 +0100
Message-ID: <20131129193715.GA3441@lukather>
References: <1384264311-7308-1-git-send-email-srinivas.kandagatla@st.com>
 <1384264383-7653-1-git-send-email-srinivas.kandagatla@st.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="n8g4imXOkfNTN/H1"
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
To: srinivas.kandagatla@st.com
Return-path: <linux-pm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1384264383-7653-1-git-send-email-srinivas.kandagatla@st.com>
Sender: linux-pm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--n8g4imXOkfNTN/H1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Srinivas,

On Tue, Nov 12, 2013 at 01:53:03PM +0000, srinivas.kandagatla@st.com wrote:
> From: Srinivas Kandagatla <srinivas.kandagatla@st.com>
>=20
> STi series SOCs have a glue layer on top of the synopsis gmac IP, this
> glue layer needs to be configured before the gmac driver starts using
> the IP.
>=20
> This patch adds a platform driver for the glue layer which configures
> the IP before stmmac driver takes over.
>=20
> Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>
> ---
>  .../devicetree/bindings/net/sti-dwmac.txt          |   45 +++
>  drivers/net/ethernet/stmicro/stmmac/Makefile       |    1 +
>  drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c    |  294 ++++++++++++++=
++++++
>  3 files changed, 340 insertions(+), 0 deletions(-)
>  create mode 100644 Documentation/devicetree/bindings/net/sti-dwmac.txt
>  create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac-sti.c
>=20
> diff --git a/Documentation/devicetree/bindings/net/sti-dwmac.txt b/Docume=
ntation/devicetree/bindings/net/sti-dwmac.txt
> new file mode 100644
> index 0000000..5431d9d
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/sti-dwmac.txt
> @@ -0,0 +1,45 @@
> +STMicroelectronics SoC DWMAC controller
> +
> +The device node has following properties.
> +
> +Required properties:
> + - compatible	: Can be "st,stih415-dwmac", "st,stih416-dwmac" or
> +   "st,stid127-dwmac".
> + - reg		: Offset of the glue configuration register map in system
> +   configuration regmap pointed by st,syscon property and size.
> + - st,syscon	: Should be phandle to system configuration node which
> +   encompases this glue registers.
> + - st,tx-retime-src: This specifies which clk is wired up to the mac for
> +   retimeing tx lines. This is totally board dependent and can take one =
of the
> +   posssible values from "txclk", "clk_125", "phyclk" or "clkgen".
> +
> +Optional properties:
> + - resets	: phandle pointing to the system reset controller with correct
> +   reset line index for ethernet reset.
> +
> +Sub-nodes:
> +The dwmac core should be added as subnode to STMicroelectronics dwmac gl=
ue.
> +- dwmac :	The binding details of dwmac can be found in
> +  Documentation/devicetree/bindings/net/stmmac.txt
> +
> +Example:
> +
> +ethernet0: ethernet0{
> +	#address-cells =3D <1>;
> +	#size-cells =3D <1>;
> +	compatible		=3D "st,stih415-dwmac";
> +	reg			=3D <0x148 0x4>;
> +	resets			=3D <&softreset STIH415_ETH0_SOFTRESET>;
> +	st,syscon		=3D <&syscfg_rear>;
> +	st,tx-retime-src	=3D "clk_125";
> +	ranges;
> +
> +	dwmac0:dwmac@fe810000 {
> +		device_type 	=3D "network";
> +		compatible	=3D "snps,dwmac", "snps,dwmac-3.610";
> +		reg 		=3D <0xfe810000 0x8000>;
> +		interrupts 	=3D <0 147 0>;
> +		interrupt-names =3D "macirq";
> +		...
> +	};
> +};

Sorry for stepping up so late, but I dont' think this is the right way
to do it.

DT is to describe how the hardware is laid out in a system agnostic
way, hence, it should not be impacted by the implementation details.

The fact that you use a glue to the dwmac driver *is* an
implementation detail.

I think you'd rather have something like:

dwmac0: ethernet@fe810000 {
	compatible		=3D "st,stih415-dwmac";
	reg 			=3D <0xfe810000 0x8000 0x148 0x4>;
	resets			=3D <&softreset STIH415_ETH0_SOFTRESET>;
	st,syscon		=3D <&syscfg_rear>;
	st,tx-retime-src	=3D "clk_125";
	interrupts 		=3D <0 147 0>;
	interrupt-names 	=3D "macirq";
	...
};

Then, the driver can have its init functions associated to the
compatible you're using, through the .data field of the of_device_id
structure, and you just call it in the generic driver at probe's time.


I don't really know what this syscon thing is either, but I think the
reg <0x148 0x4> is related to that.

Why don't you pass it directly in the st,syscon property, to have
something like <&syscfg_rear 0x148>?

Maxime

--=20
Maxime Ripard, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com

--n8g4imXOkfNTN/H1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIcBAEBAgAGBQJSmOzrAAoJEBx+YmzsjxAgrw0QAI9JhZLvGUDKp70jGHcp/xtZ
20OVTR2WYS1DA6M/qTZQOc2NDWzvq3MFE6NIz3e+P9GaoRjiQGYLIbHEXtTWXdR8
RVrYKJDmsMYVTbt7Ir3s+olWCv2dmQJqkbvnhMaVoAoTO6+B1QMTMmzT+FbhLCBV
CBQxJLjuYVT1erqtSv1daMqzsw40iAObi9IG4MJyXo7ZQ92F5BOSohCCQ5JN+4wN
WCk2uzhTjDClbY4ReuMXy9QSdcIWBvkH9g+pGZr5WXvtfdtL7abwG19xQesxQrk9
SUVJyVfoE8zwnQWesWJ/LlvgkfMvuKXn3aNWM2py57Wfkh1F5jTQ/aqLUKHI734S
zwJvn0SjNv5P9T3REJtK1BnxaNhc/bBrIuwj1xnGok5XdXZr8jwIPzT1QV1PBcdk
TrvABsopxySnskguYEyOgYF5g5SE/0fWoGxjsbcihFGq8HfoV/BPpTW45NMun/jy
Z20l4QsV7Ymk+7DxDtHYZ8FP1Y3/Y0MG2jseJHD8pbRBclIKFe34Lh07OYci3xsE
85W0lvLfIV9MPNKyeQEW7ZGc8hEG3QM8a7tNugyjSvFcVwB863nnjR7VKYqrJlSF
HiEvh2Qf5z+jj4HCO0Vwgel4RrzGos07QqRKiZdshZU1UaV5Q978U+oJJCQyP6zz
+PzArETdO7W+CDdm4Rs+
=9Opn
-----END PGP SIGNATURE-----

--n8g4imXOkfNTN/H1--
