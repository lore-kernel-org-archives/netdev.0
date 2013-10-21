From: Antonio Quartulli <antonio@meshcoding.com>
Subject: Re: [PATCH net] bridge: clean the nf_bridge status when forwarding
 the skb
Date: Mon, 21 Oct 2013 17:06:39 +0200
Message-ID: <20131021150639.GC1544@neomailbox.net>
References: <1381791096-3561-1-git-send-email-antonio@meshcoding.com>
 <20131017112857.GA11318@localhost>
 <20131017113735.GB2699@open-mesh.com>
 <20131018111041.GA10964@localhost>
 <20131018113555.GK2596@neomailbox.net>
 <52614669.5040301@redhat.com>
 <20131018144618.GL2596@neomailbox.net>
 <526154B2.2060900@redhat.com>
 <20131018154123.GM2596@neomailbox.net>
 <526541A0.4000504@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="1ccMZA6j1vT5UqiK"
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Antonio Quartulli <antonio@open-mesh.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:4607 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752893Ab3JUPHX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Oct 2013 11:07:23 -0400
Content-Disposition: inline
In-Reply-To: <526541A0.4000504@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--1ccMZA6j1vT5UqiK
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Oct 21, 2013 at 11:00:48AM -0400, Vlad Yasevich wrote:
> >>
> >> Looking at other encapsulators (PPP, iptunnel, VXLAN), they do
> >> nf_reset() on input.  Would that be appropriate for batman as well?
> >
> > I thought that too.
> >
> > But at this point, wouldn't it be better to do a reset here and remove =
the other
> > resets from any other encapsulation module?
> >
> > Maybe this operation is supposed to not happen if no encapsulation is i=
nvolved?
>=20
> This is exactly right.  The reset happens much later if there is no=20
> encapsulation.  However, if there is an encapsuation that changes the=20
> hader values that are used to filter, then nf_reset has to happen.
> That is why nf_reset happens input to the encapsulation layer instead
> of always on output from bridge.

I see.

Then I think that this patch can be dropped.
I will provide another patch to batman-adv so that it can reset the nf state
before extracting the payload packet.


Thanks a lot for your feedback!

Regards,

--=20
Antonio Quartulli

--1ccMZA6j1vT5UqiK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJSZUL/AAoJEADl0hg6qKeODbcQAJ+doEdOhUyOiM8RTEmCGkbM
7nzamJ47k39UjgIxw+6TC7G9a2c+XcFrAVTwQ/FQn+NojQxqdMbpwohku5LoTmDu
ne2El4Xv8TE8pX9r1msjwRwQ/gKch/Qdy0NM3+eZ5m1CoDfJEJQryuZxXT5qfZq1
Dwz4zaesM8ctY2gWRdTBAir49NEEfXY264KTj0GQgvbkhkvCDpR/Pul7Mlz7wVY5
eT15WU4EesbAeAWXg8KRGD+cveqOp2GxtnNWX4+dKZgOUGKPDjhO6YeY07cWCpp4
UbrY2qccQ0oVw7cStHCnjdZg+sWvwvWXKFxhk1rOWj3akwhJRo6PdkzrTZLZu+CK
HclsOc6exQjXodmZUo414JjO3lFBb9061xX7EpKm+LpqzCIwnTq77fhjnQVRExBF
1wxs7dq1JzJUR6uADnTrZ6Tnv3wk5L2DkDkKg7uQWQ4SQqmmj+U8yDEufO+SY7yS
xZnLsT3835FLhF6rgOtCsSIowUWvXptTmmw36ejOteCHUxEMIWgFjEPXhOe859a7
nD5hgCWjD1FZSk+7fGPsbtBvxkt+/y8WUzZuPzsY9tXlwWxi0Y+fIfIvxZEoaXTZ
kyu+lNODOm24gwFPhMInAEU1SrVF0xhxVYwITaZ5sErHq7IogphefqzxKeeOwL+w
xNBCk5/ArGDlZ6/9o8T9
=+Htk
-----END PGP SIGNATURE-----

--1ccMZA6j1vT5UqiK--
