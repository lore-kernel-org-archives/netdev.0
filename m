From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: Re: [PATCH v4 1/3] VSOCK: Add vsockmon tap functions
Date: Thu, 20 Apr 2017 15:24:27 +0100
Message-ID: <20170420142427.GB28450@stefanha-x1.localdomain>
References: <20170413161811.8953-1-stefanha@redhat.com>
 <20170413161811.8953-2-stefanha@redhat.com>
 <F612F48C-8072-4588-B38A-2F366F53040A@vmware.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="QTprm0S8XgL7H0Dt"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Zhu Yanjun <zyjzyj2000@gmail.com>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Gerard Garcia <ggarcia@abra.uab.cat>
To: "Jorgen S. Hansen" <jhansen@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55322 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1032136AbdDTOYb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Apr 2017 10:24:31 -0400
Content-Disposition: inline
In-Reply-To: <F612F48C-8072-4588-B38A-2F366F53040A@vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--QTprm0S8XgL7H0Dt
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Apr 20, 2017 at 12:27:37PM +0000, Jorgen S. Hansen wrote:
>=20
> > On Apr 13, 2017, at 6:18 PM, Stefan Hajnoczi <stefanha@redhat.com> wrot=
e:
> >=20
> > +
> > +static void __vsock_deliver_tap(struct sk_buff *skb)
> > +{
> > +	int ret;
> > +	struct vsock_tap *tmp;
> > +
> > +	list_for_each_entry_rcu(tmp, &vsock_tap_all, list) {
> > +		ret =3D __vsock_deliver_tap_skb(skb, tmp->dev);
> > +		if (unlikely(ret))
> > +			break;
> > +	}
> > +
> > +	consume_skb(skb);
>=20
> It looks like the caller will allocate the skb regardless of whether vsoc=
k_tap_all is empty, so shouldn=E2=80=99t the skb be consumed in vsock_deliv=
er_tap?

You are right.  Thanks!

--QTprm0S8XgL7H0Dt
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEcBAEBAgAGBQJY+MSbAAoJEJykq7OBq3PIIHAIAJcaNqc6tdRirwGSftoUPxWo
sPQFpBvfk0nfG8bsZ/D0RtTyFmG7F6XqOCPb7fZPOrPfTecNq3yKNP8tukG0g24C
ywN7R4GtxH/tOOl0p3rR0N38Lc0/p9t22yy+I/fEZq/hqesWgDOOjsodz/mef4AS
OiLvwAEDIKbpYcqtwJ0MzwI8eWWPG+nMnWmTMWJWLbGTEyj0zKt5fwlC5wQj78W6
mB+1DG93Py0r0m27PqPJMKlLLD4gaSZlEgYrYGeP+QACY229dsV3Gy3bcx+bUqF/
im75i4+5++yVVsU7P2W6QxH0UTzqTt6rJrAMQijj8OxhM7Gc2gUXIz+OpUes6Ck=
=yW9k
-----END PGP SIGNATURE-----

--QTprm0S8XgL7H0Dt--
