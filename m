From: David Lebrun <david.lebrun@uclouvain.be>
Subject: Re: [RFC PATCH net-next v2] ipv6: implement consistent hashing for
 equal-cost multipath routing
Date: Wed, 30 Nov 2016 08:56:54 +0100
Message-ID: <583E8646.2010402@uclouvain.be>
References: <1480439718-18019-1-git-send-email-david.lebrun@uclouvain.be> <1480477952.3702850.803295033.367FD66D@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature";
        boundary="HXKduma5JbO7bfcxOtEuxCraiKIaTG4fN"
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
        <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:36949 "EHLO
        smtp1.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751492AbcK3H4y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 02:56:54 -0500
In-Reply-To: <1480477952.3702850.803295033.367FD66D@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--HXKduma5JbO7bfcxOtEuxCraiKIaTG4fN
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 11/30/2016 04:52 AM, Hannes Frederic Sowa wrote:
> In the worst case this causes 2GB (order 19) allocations (x =3D=3D 31) =
to
> happen in GFP_ATOMIC (due to write lock) context and could cause update=

> failures to the routing table due to fragmentation. Are you sure the
> upper limit of 31 is reasonable? I would very much prefer an upper limi=
t
> of below or equal 25 for x to stay within the bounds of the slab
> allocators (which is still a lot and probably causes errors!).
> Unfortunately because of the nature of the sysctl you can't really
> create its own cache for it. :/
>=20

Agreed. I think that even something like 16 would be excessively
sufficient, that would enable 65K slices, which is way more than enough
to have sufficient balancing with a reasonable amount of nexthops (I
wonder whether there are actual deployments with more than 32 nexthops
for a route).

> Also by design, one day this should all be RCU and having that much dat=
a
> outstanding worries me a bit during routing table mutation.
>=20
> I am a fan of consistent hashing but I am not so sure if it belongs int=
o
> a generic ECMP implementation or into its own ipvs or netfilter module
> where you specifically know how much memory to burn for it.
>=20

The complexity of the consistent hashing code might warrant something
like that, but I am ot sure of the implications.

> Also please convert the sysctl to a netlink attribute if you pursue thi=
s
> because if I change the sysctl while my quagga is hammering the routing=

> table I would like to know which nodes allocate what amount of memory.

Yes, that was the idea.

Thanks for the feedback

David


--HXKduma5JbO7bfcxOtEuxCraiKIaTG4fN
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iEYEARECAAYFAlg+hkkACgkQjbzn67sZ6AOSUwCeOmrUsgzdcIRcbbTlPZvSXPA5
JL0AnjHAqw90edkmoUqc6C7SwvOmkhzV
=Yztq
-----END PGP SIGNATURE-----

--HXKduma5JbO7bfcxOtEuxCraiKIaTG4fN--
