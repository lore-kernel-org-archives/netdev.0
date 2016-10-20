From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net] tipc: Guard against tiny MTU in tipc_msg_build()
Date: Thu, 20 Oct 2016 13:46:25 +0100
Message-ID: <1476967585.2709.52.camel@decadent.org.uk>
References: <20161019021654.GD2773@decadent.org.uk>
         <6a69780d-0797-b5af-fc90-04960bbb21c6@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
        protocol="application/pgp-signature"; boundary="=-RJeYYi5O1FBvVIh1MTfo"
Cc: netdev@vger.kernel.org, Qian Zhang <zhangqian-c@360.cn>,
        Eric Dumazet <edumazet@google.com>
To: Ying Xue <ying.xue0@gmail.com>, Jon Maloy <jon.maloy@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:41467 "EHLO
        shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932939AbcJTMqf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 08:46:35 -0400
In-Reply-To: <6a69780d-0797-b5af-fc90-04960bbb21c6@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-RJeYYi5O1FBvVIh1MTfo
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2016-10-20 at 17:30 +0800, Ying Xue wrote:
> On 10/19/2016 10:16 AM, Ben Hutchings wrote:
> > Qian Zhang (=E5=BC=A0=E8=B0=A6) reported a potential socket buffer over=
flow in
> > tipc_msg_build().=C2=A0=C2=A0The minimum fragment length needs to be ch=
ecked
> > against the maximum packet size, which is based on the link MTU.
[...]
> > =C2=A0
> > --- a/net/tipc/msg.c
> > +++ b/net/tipc/msg.c
> > @@ -274,6 +274,10 @@ int tipc_msg_build(struct tipc_msg *mhdr, struct m=
sghdr *m,
> > > > =C2=A0		goto error;
> > > > =C2=A0	}
> > =C2=A0
> > > > +	/* Check that fragment and message header will fit */
> > > > +	if (INT_H_SIZE + mhsz > pktmax)
> > +		return -EMSGSIZE;
>=20
>=20
> The "mhsz" represents the size of tipc packet header for current socket,
> INT_H_SIZE indicates the size of tipc internal message header. So it
> seems unreasonable to identify whether the sum of both header sizes is
> bigger than MTU size. In my opinion, it's better to use MAX_H_SIZE to
> compare it with pktmax. If MAX_H_SIZE is bigger than pktmax, we should
> return EMSGSIZE error code.

At this point we're about to copy INT_H_SIZE + mhsz bytes into the
first fragment. =C2=A0If that's already limited to be less than or equal to
MAX_H_SIZE, comparing with MAX_H_SIZE would be fine. =C2=A0But if MAX_H_SIZ=
E
is the maximum value of mhsz, that won't be good enough.

Ben.

> > +
> > > > =C2=A0	/* Prepare reusable fragment header */
> > > > =C2=A0	tipc_msg_init(msg_prevnode(mhdr), &pkthdr, MSG_FRAGMENTER,
> > > > =C2=A0		=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0FIRST_FRAGMENT, INT_H_S=
IZE, msg_destnode(mhdr));
> >=20
>=20
>=20
>=20
--=20
Ben Hutchings
Never put off till tomorrow what you can avoid all together.


--=-RJeYYi5O1FBvVIh1MTfo
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABCgAGBQJYCLyhAAoJEOe/yOyVhhEJbDUP+gM9Fpd+T1y2hgLLXamyJx4s
6GvTH+RRy+Ne+Rwrnx9UEhGHM0s/3ghCze+TWymkoEv5a5vmKNNky8LV7K1WaCJo
Ds1R7IvSrBuDYJjd15zF3H5zwU/yVkd+HhtRScC0wQJnusqSe26YSe7vUWgnD/id
lduNAv59iqiv1m5/8GtFj/W5ldLnOpxU7bVmL0RgkVFwCApkKT7epeWbfu8Xt1gv
IFqu54TCbwlF35u4TF9++2NE4LPI44BRbFTRVQMW1YahU3hsHZ37dufOFAjQk3Ay
/78Gy26cMEEAubmYQQpHKNjryOBnaH5PrWUHMk8TMX2pU44QsxG1SGtS5rYmg8/m
7r5KqZWc4jBPwiEvEDABQ18IC3LS1F9iUr+wn/rPejaX2AALvcGjVCpFg2NU/ex4
wfZmx5A6d4voS8rv8BuLAjL5Lq2MuMkBt8LE+RJDJpbODDkYUj4/WPxL0NYX6TWs
g9tLOwejV3/0Dth87ZnmBhbA1uBi3od8c2uc42vDRXMZ02EajSeXxxA89K7fFZ+y
KS5BRF8W82TMk5OcQ1JDN6oLbvaDjhhNxnuZoVWNedovY3Rb4pPKaionCvWMDm+q
JuXqXsB2qSQuAPXsuLnKcUE2QZAze5IX/+6gp4k9RGFpPCZ3e1ZYHyx5mp/veRNd
V3Q2EFdjK+Ycp+iWjGe7
=Q813
-----END PGP SIGNATURE-----

--=-RJeYYi5O1FBvVIh1MTfo--
