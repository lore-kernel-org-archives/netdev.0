From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net] tipc: check minimum bearer MTU
Date: Thu, 01 Dec 2016 00:05:09 +0000
Message-ID: <1480550709.16599.81.camel@decadent.org.uk>
References: <20161130095702.DD033A0F14@unicorn.suse.cz>
         <20161130102424.GC19119@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
        protocol="application/pgp-signature"; boundary="=-HTDLkKgFoe0YqGMbEQgj"
Cc: "David S. Miller" <davem@davemloft.net>,
        tipc-discussion@lists.sourceforge.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Qian Zhang <zhangqian-c@360.cn>
To: Michal Kubecek <mkubecek@suse.cz>,
        Jon Maloy <jon.maloy@ericsson.com>,
        Ying Xue <ying.xue@windriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161130102424.GC19119@unicorn.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-HTDLkKgFoe0YqGMbEQgj
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2016-11-30 at 11:24 +0100, Michal Kubecek wrote:
> On Wed, Nov 30, 2016 at 10:57:02AM +0100, Michal Kubecek wrote:
> > Qian Zhang (=E5=BC=A0=E8=B0=A6) reported a potential socket buffer over=
flow in
> > tipc_msg_build() which is also known as CVE-2016-8632: due to
> > insufficient checks, a buffer overflow can occur if MTU is too short fo=
r
> > even tipc headers. As anyone can set device MTU in a user/net namespace=
,
> > this issue can be abused by a regular user.
> >=20
> > As agreed in the discussion on Ben Hutchings' original patch, we should
> > check the MTU at the moment a bearer is attached rather than for each
> > processed packet. We also need to repeat the check when bearer MTU is
> > adjusted to new device MTU. UDP case also needs a check to avoid
> > overflow when calculating bearer MTU.
> >=20
> > Fixes: b97bf3fd8f6a ("[TIPC] Initial merge")
> > Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
> > Reported-by: Qian Zhang (=E5=BC=A0=E8=B0=A6) <zhangqian-c@360.cn>
>=20
> Self-NACK.
>=20
> Im sorry, while testing this, I overlooked that an attempt to change
> MTU of an underlying device to low value issues a warning but it
> succeeds anyway.
[...]

I'm not sure that TIPC should block the MTU change, anyway. =C2=A0For IPv4
and IPv6 we disable the protocol on a device if its MTU is reduced
below the minimum.  I think TIPC should behave the same way.

Ben.

--=20
Ben Hutchings
Never attribute to conspiracy what can adequately be explained by
stupidity.


--=-HTDLkKgFoe0YqGMbEQgj
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEErCspvTSmr92z9o8157/I7JWGEQkFAlg/aTUACgkQ57/I7JWG
EQlGjQ/+MO8eCxmOXeyNq46shQ5L/eRO+DcazrhIYKwevUIbw6uQ0ItGnFV0m9aM
o4mWABfvZlS6Z1DvhHO5sNFkzI2FQaovWTGBXgu25Trd2SkZIULwQlSWtgxoXzqY
OonF7dulCUNxBX1txJlE7d7lNrGBxYKYTZHWrP6B8Xzt7qKYoZNUwKBnaqjoDU/b
ctFP0V1R2ktf0wHcNGo/Mi05I1yVjVvP95zuz2e60TyNKQ23tfk8Hi6ZdSgHjvqm
85+ETbJJ9CPDQSCULTpPD/FE7+Unn77k3J+6EY9ACPGm5ZWng5XctysWUPnxunRz
4k19w7bxLIMWMeyACFSXS5D55W8GYli5ugsiiLAStZVanibue0ZI0WdtTBjSaVon
bWduSklSeuf5uxfI/AjxlQflV7L1YBz14DqUjRzR1iiovtaO/6W/TBCeZqy77mu9
PojbmLqYt3JfUYBLn6DFNpX+l2Q5HdtKRh97tRIfqCeCHHQ1L6EDgR9MuFSA4BqV
jhdvTy4O+ezPpn4PqFROGElb0f6medXezbQrFv42xNDdowKDLbfdvIT0kBQqSmrK
KZ3bflw4mCYpHS0y5C5m8tOb/yrGf+Qp703nO0oUqIiEPDfJkseoJEdpCBiazmj1
1938muTPqttLP/Sauq+FMyJtOaRlLV5vWzbHZbufyABM+5e7R14=
=8hC5
-----END PGP SIGNATURE-----

--=-HTDLkKgFoe0YqGMbEQgj--
