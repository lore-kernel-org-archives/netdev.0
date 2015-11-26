From: Mark Brown <broonie@kernel.org>
Subject: Re: next-20151126 build: 3 failures 15 warnings (next-20151126)
Date: Thu, 26 Nov 2015 12:15:51 +0000
Message-ID: <20151126121551.GE1929@sirena.org.uk>
References: <E1a1sVV-00079q-My@optimist>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5716140196955500273=="
Cc: linaro-kernel@lists.linaro.org, kernel-build-reports@lists.linaro.org,
 netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
 ath10k@lists.infradead.org, linux-next@vger.kernel.org
To: Kalle Valo <kvalo@qca.qualcomm.com>
Return-path: <ath10k-bounces+gldad-ath10k=m.gmane.org@lists.infradead.org>
In-Reply-To: <E1a1sVV-00079q-My@optimist>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/ath10k>,
 <mailto:ath10k-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/ath10k/>
List-Post: <mailto:ath10k@lists.infradead.org>
List-Help: <mailto:ath10k-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/ath10k>,
 <mailto:ath10k-request@lists.infradead.org?subject=subscribe>
Sender: "ath10k" <ath10k-bounces@lists.infradead.org>
Errors-To: ath10k-bounces+gldad-ath10k=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org


--===============5716140196955500273==
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="m4E4Spob7u7JiHeu"
Content-Disposition: inline


--m4E4Spob7u7JiHeu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Nov 26, 2015 at 09:06:25AM +0000, Build bot for Mark Brown wrote:

Today's -next fails to build an arm64 allmodconfig due to:

> 	arm64-allmodconfig
> ../drivers/net/wireless/ath/ath10k/thermal.c:119:6: error: redefinition of 'ath10k_thermal_event_temperature'
> ../drivers/net/wireless/ath/ath10k/thermal.c:136:6: error: redefinition of 'ath10k_thermal_set_throttling'
> ../drivers/net/wireless/ath/ath10k/thermal.c:162:5: error: redefinition of 'ath10k_thermal_register'
> ../drivers/net/wireless/ath/ath10k/thermal.c:216:6: error: redefinition of 'ath10k_thermal_unregister'

This is happening because there are stub functions provided in the
driver's thermal.h for !THERMAL cases but these are guarded by an #ifdef
not an #if and so fails to do the right thing if the thermal code is
built as a module.  It looks like this was somehow triggered as part of
the reorganisation of the WiFi directory structure.

--m4E4Spob7u7JiHeu
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJWVvf2AAoJECTWi3JdVIfQuiYH/23woji0tzwwjNpKGq5bC2ey
9rl97Fivok7v2kwAx0FvEOgMySjQRhD9YwkYQNeYx/o4C5Tgh94R3kIyDjZD/Aec
I7iYgjtmbp8zuGA1BQO9nAss+6GInScz08YW3Al6eUOM2dT4/3TeEK/BAiX+MqVZ
Fnt3d9OMpDJppjgI3cZRF0Px3WYwtVhwRVKm+YpNAgbYodR5S2uRq/6IjQzeuPZI
0l8X3jhN1KpYth3Yr4aGKQuEbHqkoBYQbMN5iO5AYRcS2QbRGVtTMjxmpBDQAt+D
lKJavV6kA/1kCf/ba8A3Aduvz45+Ka/H1T3kim/F7rBwQb4t8aSu1J1J6eYKBmQ=
=bf0c
-----END PGP SIGNATURE-----

--m4E4Spob7u7JiHeu--


--===============5716140196955500273==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
ath10k mailing list
ath10k@lists.infradead.org
http://lists.infradead.org/mailman/listinfo/ath10k

--===============5716140196955500273==--
