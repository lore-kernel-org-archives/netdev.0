From: Antonio Quartulli <antonio@meshcoding.com>
Subject: Re: [PATCH net] bridge: clean the nf_bridge status when forwarding
 the skb
Date: Fri, 18 Oct 2013 16:46:18 +0200
Message-ID: <20131018144618.GL2596@neomailbox.net>
References: <1381791096-3561-1-git-send-email-antonio@meshcoding.com>
 <20131017112857.GA11318@localhost>
 <20131017113735.GB2699@open-mesh.com>
 <20131018111041.GA10964@localhost>
 <20131018113555.GK2596@neomailbox.net>
 <52614669.5040301@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="SLauP2uySp+9cKYP"
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Antonio Quartulli <antonio@open-mesh.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:11231 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755597Ab3JROrC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 10:47:02 -0400
Content-Disposition: inline
In-Reply-To: <52614669.5040301@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--SLauP2uySp+9cKYP
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Oct 18, 2013 at 10:32:09AM -0400, Vlad Yasevich wrote:
> On 10/18/2013 07:35 AM, Antonio Quartulli wrote:
> > On Fri, Oct 18, 2013 at 01:10:41PM +0200, Pablo Neira Ayuso wrote:
> >> On Thu, Oct 17, 2013 at 01:37:35PM +0200, Antonio Quartulli wrote:
> >>> On Thu, Oct 17, 2013 at 04:28:57AM -0700, Pablo Neira Ayuso wrote:

[...]

> >
> > The problem I was having was due to an skb entering br0 first and br1 l=
ater.
> > When reaching br1 skb->nf_bridge was !=3D NULL because of the previous =
processing
> > in br0.
> >
>=20
> Doesn't br_nf_pre_routing already take care of this for you?  It will=20
> drop the ref on the current nf_bridge and allocate a new one.  Is that
> not sufficient?

In my case that line is not reached because

 700         if (!IS_IP(skb) && !IS_VLAN_IP(skb) && !IS_PPPOE_IP(skb))

is always true: the packet getting analysed is a batman-adv encapsulated pa=
cket,
which does not match any of the three above.

Cheers,

--=20
Antonio Quartulli

--SLauP2uySp+9cKYP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJSYUm6AAoJEADl0hg6qKeO/ZQP/jKu2gtvY/yl0n0PLJ9wcyeG
alvE8Kub/fBzFqmT/befmglHpLp3S4Vg3TBT4WpuEkgoxuN10l3AMoXKpOK4MLI+
FRk2Te6vXQdI9x1wPjOCVFxbUNcVDzu+IEvuVtlFSuLYgmOkH0EZwE1Tvdj3ccFE
ehdqbIxrXN5CkS5ClcXeR3gjhEUAfGrV21f7DPJcnev76rXjSWsbD6cEGmTBGpqz
kX6UBt1GgyV+498qw5flZZIhAK9zwYdZJWz7MxJMqDieoO+C+gKf38WSVZOPaV25
JJQxQ1OXQOfb4Hh/I+KHOd5n+AAAonEgb+QhBOMiHfkHTvawvegoBRHq4eLMr84G
TELSyOJIFjL4RrG2nfdD1+YSUNxTuP/p+XCh7pcnGJ65Ty2ikJvdzTIXGxGMO3HS
5j8+KJ/U1CDsp7Ns+qrYQi0j9R0f1rhzOwLZPzPXKfZaA+nZNFeqvOmGgM9YSKyH
qLXe0DyGQmi9PB2Bd4KrSk6qNDTUPNZA6VNyhl7DFmvn8uMS36MAEKBnzxPx826t
Uyk5HBJsac4qaBWG5D++DAHv1SGCWK24jV1hPaWRVRkS3RvAuX/9Sb6PoV55lDrs
e/j7M6SpLSLgEfH+iu/A7vTzWCnwMrfklmBtl1Yu8ZKikp8tdGg+E6cStLBhus+F
gnMrnZoAA6X5BHF5ezGA
=B3gA
-----END PGP SIGNATURE-----

--SLauP2uySp+9cKYP--
