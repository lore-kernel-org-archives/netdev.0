From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] wireless extensions: play with netns
Date: Wed, 17 Jun 2009 22:50:54 +0200
Message-ID: <1245271854.31588.44.camel@johannes.local>
References: <1245263058.31588.38.camel@johannes.local>
	 <m1y6rqwpur.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-i+vqvb8oWSzhodAPGO/4"
Cc: John Linville <linville@tuxdriver.com>,
	Netdev <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@aristanetworks.com>,
	Alexey Dobriyan <adobriyan@gmail.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:60865 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752235AbZFQUvZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2009 16:51:25 -0400
In-Reply-To: <m1y6rqwpur.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-i+vqvb8oWSzhodAPGO/4
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2009-06-17 at 13:46 -0700, Eric W. Biederman wrote:
> Johannes Berg <johannes@sipsolutions.net> writes:
>=20
> > This makes wireless extensions netns aware.
> >
> > Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
> > ---
> > Is this ok, or is this racy? I guess what I'm asking is -- will
> > for_each_net() stop iterating over a netns that is going away before th=
e
> > pernet exit op is called? If yes, this should be fine.
>=20
> for_each_net requires the rtnl_lock or the net_mutex to be safe.
> You aren't taking either so your code is racy.

Ah ok!

> A dying network namespace will be removed from the net_namespace_list
> (aka for_each_net) before the per net exit methods are called.
>=20
> Is grabbing the rtnl_lock safe in your workqueue and is that something
> we want to do?

Ok, thanks. Well, it's a tasklet currently, but can easily be converted
to a work struct and then take the rtnl.

johannes

--=-i+vqvb8oWSzhodAPGO/4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJKOVcqAAoJEODzc/N7+QmaIysQALIRH7ilmjqP4lCFy2dAnmJY
9VGIWRadwpPunBQ2zsXPhLzzcLuzmpd6dQ92d2yIpmUIXWtJOjjl3KCx+zpSMuWv
/oRP8gmMm1gDzXmGU4UKLYgW1ptn5mDbtVBFqMWEABCczoYkafT612/lac5GfNV/
J4YDMV4vRNwoB7sit56+fVYL2vw0xw4MOsznx6BpsxluUr73jGq9JDeiemSPQkSt
sqs0sOcxWBvfe3Vocy248LyXBUg4iYKHdJfovtHTPSXrvptV3/VWe2GynaMx1Q0U
Hx9gtTm2ffXr+WxTQ3euA+5AbaF5oxv58wf1crOky4wZ72BExQyldRI7kO714sr1
wT4uce9rp0AcGm7V59WIedsZCxm9dB4TwsKO/tS6FcpjuIfLnBkHm6odRVdExCfP
t3ep0s+53SEIhlfJl5rRKRonNGm3Hk5S5iX1N+4DBfz+fBKh5MD2bGhK9NTouXvI
/xmOMJvvBVbG5n/ncpwvVChEQ3FrPYyvjmy7YFkut7HyRCHE8QymL99b+708G2lR
2QSR+SlpsAijrbEo/CAUnRvMFKJWx/GXFwbmoK6sqbxr1JZRr4tMhTuuHdil+LhV
d8H+ZTqabwPseA6N/OqQxG5PHaGA+OF3lSOthTMO9FmBQRSdqBDKokBU+nNzaVrK
LXQPfXXRBNofFTVAHVmk
=HAN8
-----END PGP SIGNATURE-----

--=-i+vqvb8oWSzhodAPGO/4--

