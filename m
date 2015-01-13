From: Felipe Balbi <balbi@ti.com>
Subject: Re: [PATCH 3/6] net: davinci_emac: Free clock after checking the
 frequency
Date: Tue, 13 Jan 2015 13:50:35 -0600
Message-ID: <20150113195035.GS16533@saruman>
References: <1421177368-19756-1-git-send-email-tony@atomide.com>
 <1421177368-19756-4-git-send-email-tony@atomide.com>
 <54B57688.6000908@amd.com>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="2wYUONsACSj9OMJp"
Cc: Tony Lindgren <tony@atomide.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-omap@vger.kernel.org>,
	Brian Hutchinson <b.hutchman@gmail.com>,
	Felipe Balbi <balbi@ti.com>
To: Tom Lendacky <thomas.lendacky@amd.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:42935 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751193AbbAMTvW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jan 2015 14:51:22 -0500
Content-Disposition: inline
In-Reply-To: <54B57688.6000908@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--2wYUONsACSj9OMJp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Jan 13, 2015 at 01:48:24PM -0600, Tom Lendacky wrote:
> On 01/13/2015 01:29 PM, Tony Lindgren wrote:
> >We only use clk_get() to get the frequency, the rest is done by
> >the runtime PM calls. Let's free the clock too.
> >
> >Cc: Brian Hutchinson <b.hutchman@gmail.com>
> >Cc: Felipe Balbi <balbi@ti.com>
> >Signed-off-by: Tony Lindgren <tony@atomide.com>
> >---
> >  drivers/net/ethernet/ti/davinci_emac.c | 1 +
> >  1 file changed, 1 insertion(+)
> >
> >diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethern=
et/ti/davinci_emac.c
> >index deb43b3..e9efc74 100644
> >--- a/drivers/net/ethernet/ti/davinci_emac.c
> >+++ b/drivers/net/ethernet/ti/davinci_emac.c
> >@@ -1881,6 +1881,7 @@ static int davinci_emac_probe(struct platform_devi=
ce *pdev)
> >  		return -EBUSY;
> >  	}
> >  	emac_bus_frequency =3D clk_get_rate(emac_clk);
> >+	clk_put(emac_clk);
>=20
> The devm_clk_get call is used to get the clock so either a devm_clk_put
> needs to be used here or just let the devm_ call do its thing and
> automatically do the put when the module is unloaded.

instead, if you really don't need the clock for anything other than
getting its rate, why don't you just remove devm_ prefix from clk_get()?

--=20
balbi

--2wYUONsACSj9OMJp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUtXcLAAoJEIaOsuA1yqRE5REP+wQ6G4QhTT48LaAdYvkmbW2s
LVGww5/TP08EhlVW7TfMHSAaW5gK5SVJ1Y23Uw7rh02ZRon4Tn/k6xDTOvA7cQ/C
IUsxmKF/2DVy9QHvQ85gLFOBpkUUqXSgw1pdOE3rerfx/f2PJdUweKb1IaeX2CDd
XrXJfFrr8CeLwQXvVb33m7pCXQpDGXsaoQkHPwbwkTS0L6Z4cwGbwM4r+AHru2nf
9j9ABXkP6tttjtDzD3nRSOfrrXHl8jgRYOGn2ZdrKKq935L+AY4/mVKmGrPk5maL
/08Bm9jkEDqZOApqzaYM1z64uT0zFTYbFVlnKS1G9Ig5cuVP4CHGfWnl5JgMbz1G
d0AEq8bA43WuJbBdnqO9jsc6goMC23ARB8VwSDwFegdVPKxc1bjVDGaVvYao58AD
y3f/x454LtJZAhMI2gijeN3buUF1sLmgQQoHo2U6ZAR+JB87iQD29zTv9XZwy0Ts
//qqNAk/1na59puVvqizVSwSn8y1lfcGnoPfawHArgVwq+A3o/deTgQN0PMAyx5Q
sFN/R+Mu0Huxe2zK3GWI8pBD6aZp4wWI6/6Hzr880AGFoweI1ORj0X68Jv/fIF9c
DZtnu0/xxqp+3Tw6m1Ntn5DVXcLM4Q8ru56DKA2Nhwye8n/TqTstvfzPBUHI7V6d
lGK/DNBKwi97LAPXne1z
=+Bgq
-----END PGP SIGNATURE-----

--2wYUONsACSj9OMJp--
