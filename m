From: Mark Brown <broonie@kernel.org>
Subject: Re: [PATCH] net: rds: Don't allocate rds_sock on stack
Date: Tue, 26 Aug 2014 07:54:09 +0100
Message-ID: <20140826065409.GT17528@sirena.org.uk>
References: <1408926755-12277-1-git-send-email-broonie@kernel.org>
 <20140825.125740.214306460002405867.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="+W8KylOsjP6K5S9y"
Cc: chien.yen@oracle.com, rds-devel@oss.oracle.com,
	netdev@vger.kernel.org, linaro-kernel@lists.linaro.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mezzanine.sirena.org.uk ([106.187.55.193]:33403 "EHLO
	mezzanine.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933794AbaHZGyW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2014 02:54:22 -0400
Content-Disposition: inline
In-Reply-To: <20140825.125740.214306460002405867.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--+W8KylOsjP6K5S9y
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Aug 25, 2014 at 12:57:40PM -0700, David Miller wrote:
> From: Mark Brown <broonie@kernel.org>

> > From: Mark Brown <broonie@linaro.org>

> > struct rds_sock is rather large ausing the following warning in an ARM
> > allmodconfig:

> > net/rds/iw_rdma.c:200:1: warning: the frame size of 1056 bytes is larger than 1024 bytes [-Wframe-larger-than=]

> > Fix this by dynamically allocating struct rds_sock in rds_iw_update_cm_id
> > instead of allocating it on the stack.

> > Signed-off-by: Mark Brown <broonie@linaro.org>

> I'd like you to fix this differently.  Creating pseudo instances of
> objects, and partially initializing it, just to satisfy an interface
> is always a really bad sign.

> Create a key structure argument for rds_iw_get_device() and initialize that
> and pass it in instead, update the other caller similarly.

I agree that the existing code looks like it could be improved even more
but please bear in mind that I'm just looking for a clean build (we've
got less than 20 warnings in allmodconfig including staging at the
minute) rather than actively working on this code in particular - I've
no ability to do more than build testing here.

--+W8KylOsjP6K5S9y
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBAgAGBQJT/C8NAAoJELSic+t+oim9HzUP/2eQRuB6+SxIGUcoS3K4VnfY
u13ZXFSTbVS8iWUhfGli8WAHvYeLG6wDf4YTYCJswU1COlTj9ckEyqPmehjiRRIj
8ehzu1O69DeUa1eQTrlN5V1uOTrKIHTGCavQBfI48nd0K/ERJbYhIpdjTvOyDIc1
MMMa/P5M6vajp/8yIe5DKLMIHumN9EvqE/0qqBRWSTjr9a0DZwvkIi/4AdGbGC+b
Z4Ys2Wo6S66IfvGrUA8ip2OzBkqkaWkVpLfjM5QbutG2AZpvhTOR2z9pyw+64uk9
xbD/D1arlPBGqb2l8WAGu8tykNeK1SU0vaU9Sk0Ha3cKbHgodhwXldQ7tOo58FAU
tci+BzPEwehQ9Ea15wGcBw4ZqCMUVcI7QnZN9a4uOKQAfgOERpbBwkCUOmCrzF7U
DtoEEDiiukB6ujxFMjDcUY+QiaajcbIiRa3n0xzMoTT9uYUlPUJPS1Xk03tX2Qrr
7t2HGDfUID5Lc9Ix1CxpL63NnhLbPWnhPhWA/iRd2Um0Yk+EMwl09sLtBS3rjUMF
akrRlwc1uknm0fBtIBqUu8wWQSCHYrPOv2fUpHhlBy+tAl/PFSkfP+B3V4Szah9m
/Vt0HxBg+lL9mYLRvJZmR3jTGlUWMfaaO1wlDig4T1GQiEcTgw7Ge50jj7vJQg/g
372MWximo96yNqYw5mQ2
=Cfnp
-----END PGP SIGNATURE-----

--+W8KylOsjP6K5S9y--
