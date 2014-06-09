From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 01/13] i40e: add checks for AQ error status bits
Date: Mon, 09 Jun 2014 14:10:38 -0700
Message-ID: <1402348238.2183.10.camel@jtkirshe-mobl.jf.intel.com>
References: <1402303758-1429-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1402303758-1429-2-git-send-email-jeffrey.t.kirsher@intel.com>
	 <5395B4C1.7070004@cogentembedded.com>
	 <1402346114.2183.5.camel@jtkirshe-mobl.jf.intel.com>
	 <1402347725.3142.19.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Qz1u9c/CoSuEpjUMeCgN"
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	davem@davemloft.net, Shannon Nelson <shannon.nelson@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:26522 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753900AbaFIVLP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Jun 2014 17:11:15 -0400
In-Reply-To: <1402347725.3142.19.camel@joe-AO725>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Qz1u9c/CoSuEpjUMeCgN
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-06-09 at 14:02 -0700, Joe Perches wrote:
> On Mon, 2014-06-09 at 13:35 -0700, Jeff Kirsher wrote:
> > On Mon, 2014-06-09 at 17:21 +0400, Sergei Shtylyov wrote:
> > > On 06/09/2014 12:49 PM, Jeff Kirsher wrote:
> > > > From: Shannon Nelson <shannon.nelson@intel.com>
>=20
> > > > If the Firmware sets these bits, it will trigger an AdminQ
> > > > interrupt to get the driver's attention to process the ARQ, which w=
ill
> > > > likely be enough to clear the actual issue.
> =20
> > >     Hm, why not dev_err() here and below?
>=20
> > The thought was that these should be more of "FYI..." type of messages
> > not "Oh Crap!..." messages.  So that is why dev_err() was not used,
> > although we are not opposed to changing it if you feel it warrants it i=
n
> > a follow-up patch.
> []
> > > > +	if (val & I40E_PF_ATQLEN_ATQCRIT_MASK) {
> > > > +		dev_info(&pf->pdev->dev, "ASQ Critical Error detected\n");
> > > > +		val &=3D ~I40E_PF_ATQLEN_ATQCRIT_MASK;
> > > > +	}
>=20
> I thought it was odd to have a "critical error"
> emitted at KERN_INFO
>=20
> Maybe adding something like
> 	"ARQ should fix this automatically"
> would be enough.
>=20
> Should any/all of these be ratelimited or maybe even
> changed to dev_dbg?
>=20
>=20

Well, as Shannon noted in the patch description:
"If the Firmware sets these bits, it will trigger an AdminQ
interrupt to get the driver's attention to process the ARQ, which will
likely be enough to clear the actual issue."

To me that means the log messages should not be filling up with these
types of messages and if they do occur, it should be transient and
resolve itself.  So does that warrant dev_dbg?=20

--=-Qz1u9c/CoSuEpjUMeCgN
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABCgAGBQJTliLOAAoJEOVv75VaS+3OnM8P/RBbmvtJaeBPEeZbT/0gOjtM
L0oGwRR2YOheW18apcInE9OM0UOapKssU2c4oQK4vNvRsL5kp70eQE/449wceO5p
KjXfdPM+EivuEf2XoN8y0MEH0KLosRgwaO28yp8xpUVqp3sVzqYB9mpu45Dd39RK
VxKfNvED23UgDBEWsMXFyHdNGai0IYgLwRPDwusXwpnRYwTdMtJwRtdrOtFlao8u
HvZafdXpU0P8m1rFX7QabHlXMAu/EsO5aHdY4uucx8MHi31WyR1q17hxwOJIQraX
zX6j8jO7DaO98Id57J9o5O8BhU4BfcGBRLFt8KXFUg2kn3v1ODDRCM3uMG2HR7L5
+eyFARiOBsG3TzxhPh7Erray1TW0Tyv+IDguMcV0+2zBDbfqBYCPJ2O+aRagiPfq
Tq+poNzXvUKeOAY6EIu9sYS4BWAF3qg6IziOJ5HvG3k8wvw7gQPwCLUQg1zOt9nk
MK9eNFB+YarWhCGTTgY7ujcwYb+2YR8o+ZvvxIMqtf5hYyHPpQcnaBQbCM6eLn6b
ycPwioTI/WeVaUbC/ZNgxrTLw50UNdR6oqVqcQ8xJxhO0RSZHqDDS/Cwv5i7MErn
yW7xXDLeNvGsrOSHHmvkAQU6iwleOQzRDvEfw/vGMIoYq8KVJ8wD2eh8sFnepO04
dBCSU8vTYJtKNRGHfKfX
=QqXx
-----END PGP SIGNATURE-----

--=-Qz1u9c/CoSuEpjUMeCgN--
