From: Thierry Reding <thierry.reding@avionic-design.de>
Subject: Re: [PATCH 00/33] devm improvement series, part 1, take 2
Date: Thu, 23 May 2013 22:32:43 +0200
Message-ID: <20130523203243.GA18069@avionic-0098.adnet.avionic-design.de>
References: <1368702961-4325-1-git-send-email-wsa@the-dreams.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1637291975=="
Cc: linux-mips@linux-mips.org, alsa-devel@alsa-project.org,
 linux-usb@vger.kernel.org, Liam Girdwood <lgirdwood@gmail.com>,
 Alexander Shishkin <alexander.shishkin@linux.intel.com>,
 Viresh Kumar <viresh.kumar@linaro.org>,
 Linus Walleij <linus.walleij@linaro.org>, Matt Mackall <mpm@selenic.com>,
 linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org,
 Jaroslav Kysela <perex@perex.cz>, linux-ide@vger.kernel.org,
 netdev@vger.kernel.org, linux-mtd@lists.infradead.org,
 linux-i2c@vger.kernel.org, Evgeniy Polyakov <zbr@ioremap.net>,
 Wan ZongShun <mcuos.com@gmail.com>, ac100@lists.launchpad.net,
 devel@driverdev.osuosl.org, Kukjin Kim <kgene.kim@samsung.com>,
 Russell King <linux@arm.linux.org.uk>,
 Herbert Xu <herbert@gondor.apana.org.au>,
 Florian Tobias Schandinat <FlorianSchandinat@gmx.de>,
 Stephen Warren <swarren@wwwdotorg.org>, "Rafael J. Wysocki" <rjw@sisk.pl>,
 cpufreq@vger
To: Wolfram Sang <wsa@the-dreams.de>
Return-path: <devel-bounces@linuxdriverproject.org>
In-Reply-To: <1368702961-4325-1-git-send-email-wsa@the-dreams.de>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/devel>,
 <mailto:devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/devel/>
List-Post: <mailto:devel@linuxdriverproject.org>
List-Help: <mailto:devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/devel>,
 <mailto:devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: devel-bounces@linuxdriverproject.org
Sender: "devel" <devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org


--===============1637291975==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="cWoXeonUoKmBZSoM"
Content-Disposition: inline


--cWoXeonUoKmBZSoM
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, May 16, 2013 at 01:15:28PM +0200, Wolfram Sang wrote:
> Lately, I have been experimenting how to improve the devm interface to ma=
ke
> writing device drivers easier and less error prone while also getting rid=
 of
> its subtle issues. I think it has more potential but still needs work and
> definately conistency, especiall in its usage.
>=20
> The first thing I come up with is a low hanging fruit regarding
> devm_ioremap_resouce(). This function already checks if the passed resour=
ce is
> valid and gives an error message if not. So, we can remove similar checks=
 from
> the drivers and get rid of a bit of code and a number of inconsistent err=
or
> strings.

Sorry for jumping in so late. I generally like the idea. One small
inconvenience is that devm_ioremap_resource() returns -EINVAL if
res =3D=3D NULL, which means that drivers will now also return -EINVAL
in cases where no resource was returned. Typically drivers handle
this by returning something like -ENODEV, -ENXIO, -ENOENT. Some do
return -EINVAL but perhaps having a separate error code (and maybe
error message as well) for a missing resource would be helpful.

Doing this would be rather easy now that you've paved the way by
making devm_ioremap_resource() usage consistent across drivers.

Thierry

--cWoXeonUoKmBZSoM
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIcBAEBAgAGBQJRnnzqAAoJEN0jrNd/PrOh7SQP/0805wibt2DFxkTSFnZBxDGZ
hU1p6eTzQ5Nh3uDq449RqWs8GsB+f2osxomSH71KMqGJmlKi0jc0gtcINotD6FH+
F8ABG95AKXi5TmG9hEcdIv6eAzfI0AUAgx1izHLxQWLHIcVoca5GpptWPrkOlW6U
NujE+Lz3rYYtbNMoK8jexasO9uQzo/V6fB3IMVdnEx80CE5o6TbTYBQz5fInVcs8
QlA0w37qFEcmOq1BsEJNdlcm0JUJ+3sXoFUdnN9jPGcrTgiOg8jXx6GpKLMRJyA3
cToFc9kVXqgOOtYPw08CUkrzkqF/E0i11IaBOtlvXG489AbvlUOeF95JQEZvLgu9
ScBNy/PqNN9Z3jZhoiqsTd//QGBb5kNUKEs5v30o4zHpy+3buWpOSiUgJLvX18la
o8Krom/w4KEH01JRqLSCJLHwZXvyOj6DWW/ogPPMpirX+TTdyDLt4XbGP5GU6iVh
um0drkT9bUruG2pQVDeNkVwpTMedd5xa96kTXLu0D3MB7Lvfp43mVDVAuYG/FjhU
m4NkG0SY8N07Upidbb2LZSvAEydzHVJcF7kobEMRnQwH99VYyRUmviKHhoP469T0
VyKKbTxfTlSWkLQqvgS3eVraylffA8O6eV4RHpAYZyZlsoa+5JulahO69B0yebx2
atBr1eUuDOTwTR9IUz59
=pYVl
-----END PGP SIGNATURE-----

--cWoXeonUoKmBZSoM--

--===============1637291975==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
devel mailing list
devel@linuxdriverproject.org
http://driverdev.linuxdriverproject.org/mailman/listinfo/devel

--===============1637291975==--
