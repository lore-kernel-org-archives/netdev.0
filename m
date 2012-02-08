From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Subject: Re: Regulator support for smsc911x
Date: Wed, 8 Feb 2012 11:35:25 +0000
Message-ID: <20120208113524.GE3120@opensource.wolfsonmicro.com>
References: <CAOMZO5Bn4jMYjcBC87uD99qYgzXdiH6YxD5xakjftH-U6bbzMQ@mail.gmail.com>
 <CAOMZO5Be_0W6E7Vj7YDLwFUhrqt_7Q748rpj=J2Tbyh9+MP7gQ@mail.gmail.com>
 <20120203074408.GD1990@pengutronix.de>
 <20120203111133.GD3151@opensource.wolfsonmicro.com>
 <CAOMZO5B2_yq=m8Mer=iV-HsXvF-MZJ-BV2=LTg1CZN+O=yepSQ@mail.gmail.com>
 <20120207193914.GA31557@opensource.wolfsonmicro.com>
 <20120208083141.GM3852@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="n+lFg1Zro7sl44OB"
Cc: Fabio Estevam <festevam@gmail.com>, robert.marklund@stericsson.com,
	netdev@vger.kernel.org, Sascha Hauer <kernel@pengutronix.de>
To: Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from opensource.wolfsonmicro.com ([80.75.67.52]:37792 "EHLO
	opensource.wolfsonmicro.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756022Ab2BHLf1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2012 06:35:27 -0500
Content-Disposition: inline
In-Reply-To: <20120208083141.GM3852@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--n+lFg1Zro7sl44OB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Feb 08, 2012 at 09:31:41AM +0100, Sascha Hauer wrote:

> There is also option e), something I've been thinking about for a while.
> Implement a list of resources which can be attached to a device. By
> resources I mean regulators, clocks and pinmux for example. A device
> would then just call a make_me_work(state) function which iterates over
> this list and enables/disables all resources as necessary. This way we
> could attach everything we need to a device without cluttering the
> driver code like we do today.

That gets tricky where you have resources that are only needed some of
the time (for example, many of the CODECs I work with can happily have
some of the supplies disabled while they are operational - some systems
may never enable certain supplies) and there are fun interactions with
things like runtime PM and system suspend to consider (wake on LAN would
be one for an ethernet driver).  Once you start hitting low power states
and pursuing optimisations there you start to find that the driver needs
to make decisions about what's going on that can't easily be completely
removed from it.

I have been meaning to do something like that which devices can
request if they happen to have trivial or common usage patterns (of
which there's a few) so all they need to do is set flags but I'm really
not sure it's a good idea by default.  Gets fiddly with the device core
though.

--n+lFg1Zro7sl44OB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJPMl32AAoJEBus8iNuMP3dBwkP/jIIBCtXXFEBcIcDmOfxGbae
jKXNdGwEmkResVyglLM2w+YHOtECkvV8nkv8nAReq6YAJWzZxxeUc5bGPqcVlGvN
ZD2EyWGtyHU7fadyvVXcUc/nfPkRy7MNRyuA6r+1bgivtGO9ZDrYn+iFfh02aJMP
2taY1AQybc1Rj2zyTU2+hI+zYYKUREJ7L91GpjcCRzNNCWyTwOVN6i1USnlyv/Tt
pc3nDChMms5HJN47/aSavHR5VxHFX62rRztyVG0m2/qkal1QhraNKfqsytJ/vLfX
8z7oTCmIYFCf2C5JNdxB3JHJ/TBcwpXrRFTx9wyRjzTa1OptqneoBCHD2S7gP9Ms
fNFunazyAQmxqjmuYiFYD+Wl82rmNylTQWXdKGdla1jKniylfxWJivUU1AmylOaU
1iyQrJvsnnO+Q0sWDQ52MmDplNzPV07vSnToVFJ13dCs9bazGIbzD1NBfa8A4emM
VkcK45hleN8515yldkLb5/c2m+JdJcSeneVJaTFB5NMuE7D/1TBVqobAqa/YrvOb
934hVsmFr4BQQXxbjRqFdTFedipqddW9kS+Vf63WbDqHagNIyYChAhMuLLEvcI45
MQEqQAb6M6AIVoIp6He6RA1E8tjPtA9QBjJ8fiRt5u2lwjSVXNgcEZxycTEyl/UW
tWCDfyXZCvHvFQuBYC3u
=MgWa
-----END PGP SIGNATURE-----

--n+lFg1Zro7sl44OB--
