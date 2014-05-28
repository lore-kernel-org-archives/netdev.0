From: Mark Brown <broonie@kernel.org>
Subject: Re: [PATCH v2 1/4] devicetree: bindings: Properly document micrel
 ks8851 SPI chips
Date: Wed, 28 May 2014 10:44:54 +0100
Message-ID: <20140528094454.GH12304@sirena.org.uk>
References: <1400875040-13269-1-git-send-email-sboyd@codeaurora.org>
 <1400875040-13269-2-git-send-email-sboyd@codeaurora.org>
 <20140524124858.GR22111@sirena.org.uk>
 <5385063F.30407@codeaurora.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="F+GrfnmevXhaz2Un"
Cc: "David S . Miller" <davem@davemloft.net>,
	Nishanth Menon <nm@ti.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Pawel Moll <pawel.moll@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	linux-arm-msm@vger.kernel.org, Kumar Gala <galak@codeaurora.org>,
	linux-kernel@vger.kernel.org, devicetree@vger.kernel.org,
	Rob Herring <robh+dt@kernel.org>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
To: Stephen Boyd <sboyd@codeaurora.org>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5385063F.30407@codeaurora.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--F+GrfnmevXhaz2Un
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, May 27, 2014 at 02:40:15PM -0700, Stephen Boyd wrote:
> On 05/24/14 05:48, Mark Brown wrote:

> > That said it looks like this is intended to be a supply for an external
> > PHY rather than the device itself, but even so my original question
> > about it being able to operate without power still applies.  Looking at
> > the code it's certainly not doing any of the handling of a missing
> > supply that I would associate with using _optional().

> I agree, both supplies don't look optional. Unfortunately
> efm32gg-dk3750.dts doesn't look to be listing any supply, and this
> driver only recently got support for the VDD_A3.3 supply that the omap
> board uses (adding Uwe for any comments on efm setup). I presume on
> these boards VDD_IO is tied to some always on power source that software
> doesn't want to deal with. Nishant, what's VDD_IO connected to on omap?

> What's the proper solution here? Should we use regulator_get() and check
> for EPROBE_DEFER and ignore other errors?

As an implementation extension if no supply is specified at all the
regulator API will happily substitute in a dummy if the board is using
DT or ACPI, or if it has specified full constraints.

> Should the get_optional() variant just drop the "Other consumers will
> be... " part and should the get_exclusive() variant say "obtain this
> regulator while this reference is held" ?

Yes.

> From: Stephen Boyd <sboyd@codeaurora.org>
> Subject: [PATCH] regulator: Fix regulator_get_{optional,exclusive}()
>  documentation

Documentation/SubmittingPatches.

--F+GrfnmevXhaz2Un
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBAgAGBQJThbATAAoJELSic+t+oim9Hv8P/0wo8aYnBoyFv+R9/tAAkqM3
cqFew+QnqKruZ0h4Joc8Q21tawR80Qeu2/QXkf+Kq0c7b0C+ILjC3SXHA8vULfYD
gnc6JXEo2mw4AhKVeXt4JzhVBGr83hAVH8ccGlRVXxfBcb9DEA/v5d/vc2W95bs9
LwqPH8J+sdAk1iPNoGsVQFp6e+9SlRUZCJyXx6aBu14ENjkR53SmkJL53xjTweon
yZMfSYmTE2s4CUdQ0IBifu7JnJfhyL+Dg6bKtczoZpcRPb1v+WdZBI3ANy/qTyuw
wTHMCuWZAXGSYSDH+WpTletN5w0t6ZVF3oOmhHzzdzZpR9nHxxCdtCwLW/k6ma1f
QqS2a7FOSImO21uCdWVEYzBOPy72sT9lNJ4F3lQxJ53WwdvmIdv63twpny+/O3Ee
AoAeeCVghoFhUpwVz+fSH/5fiEN7xFD/FDqQYlEZg6zw0W/uyYLPbxd0xpHAR9aY
zeHlnpf4r7XznBAY/C7NFhkWSW0ir+eg7kv1Lu5b85pAfc7GMLHQgeC8eOZP73mR
OCdNuO5jeyZ6/JNV6xW5VTvJ/RbQvlA51hRj9aiRoQST6yiUexSo4KQAweOZd1Di
t/iAtDe3nJXmyAC7WGnDoxjXubSHtqE/eY9aNeDmODyu6pz3tgFxPGRTj7JRRfz3
nulng4GPP+jN6DuaMF/U
=gxsH
-----END PGP SIGNATURE-----

--F+GrfnmevXhaz2Un--
