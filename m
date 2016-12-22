From: Doug Ledford <dledford@redhat.com>
Subject: Re: [PATCH] RDS: use rb_entry()
Date: Wed, 21 Dec 2016 22:33:32 -0500
Message-ID: <58ac50d1-0c5e-4dc3-435a-bbd0d4183a4a@redhat.com>
References: <ddabc96c798df194791134d8e070d728e2a7b59f.1482203698.git.geliangtang@gmail.com>
 <2cd84448fe04ffb7023be892c5ed04bbfc759c87.1482204342.git.geliangtang@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="ueTXPMJ88ARsKg0prkt3A8WQ61iK3S1lD"
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        rds-devel@oss.oracle.com, linux-kernel@vger.kernel.org
To: Geliang Tang <geliangtang@gmail.com>,
        Santosh Shilimkar <santosh.shilimkar@oracle.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2cd84448fe04ffb7023be892c5ed04bbfc759c87.1482204342.git.geliangtang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--ueTXPMJ88ARsKg0prkt3A8WQ61iK3S1lD
Content-Type: multipart/mixed; boundary="6pe0LxMgSnp5T7x3pw4Ivr21beV4TfHPk";
 protected-headers="v1"
From: Doug Ledford <dledford@redhat.com>
To: Geliang Tang <geliangtang@gmail.com>,
 Santosh Shilimkar <santosh.shilimkar@oracle.com>,
 "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
 rds-devel@oss.oracle.com, linux-kernel@vger.kernel.org
Message-ID: <58ac50d1-0c5e-4dc3-435a-bbd0d4183a4a@redhat.com>
Subject: Re: [PATCH] RDS: use rb_entry()
References: <ddabc96c798df194791134d8e070d728e2a7b59f.1482203698.git.geliangtang@gmail.com>
 <2cd84448fe04ffb7023be892c5ed04bbfc759c87.1482204342.git.geliangtang@gmail.com>
In-Reply-To: <2cd84448fe04ffb7023be892c5ed04bbfc759c87.1482204342.git.geliangtang@gmail.com>

--6pe0LxMgSnp5T7x3pw4Ivr21beV4TfHPk
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 12/20/2016 9:02 AM, Geliang Tang wrote:
> To make the code clearer, use rb_entry() instead of container_of() to
> deal with rbtree.
>=20
> Signed-off-by: Geliang Tang <geliangtang@gmail.com>
> ---
>  net/rds/rdma.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/net/rds/rdma.c b/net/rds/rdma.c
> index 4c93bad..ea96114 100644
> --- a/net/rds/rdma.c
> +++ b/net/rds/rdma.c
> @@ -135,7 +135,7 @@ void rds_rdma_drop_keys(struct rds_sock *rs)
>  	/* Release any MRs associated with this socket */
>  	spin_lock_irqsave(&rs->rs_rdma_lock, flags);
>  	while ((node =3D rb_first(&rs->rs_rdma_keys))) {
> -		mr =3D container_of(node, struct rds_mr, r_rb_node);
> +		mr =3D rb_entry(node, struct rds_mr, r_rb_node);
>  		if (mr->r_trans =3D=3D rs->rs_transport)
>  			mr->r_invalidate =3D 0;
>  		rb_erase(&mr->r_rb_node, &rs->rs_rdma_keys);
>=20

Dave, I know you already took this, but am I the only one that thinks
these patches are a step backwards?  They claim to promote readability,
but I disagree that they actually do so.  The original code used the
container_of() API with three specific arguments that made sense in the
context of a function named container_of().  The new API uses the exact
same three arguments, but they no longer make the same sense just
comparing the arguments to the function name.  The relationship has been
lost.  And on top of that, if you do this for all of the standard things
in the kernel (rb_entry, list_item, etc.), then you've created a myriad
of APIs that all duplicate one functional API that made sense.  Is it
really an improvement to go from one generic function that makes sense
and works everywhere to multiple implementations of basically just name
wrappers that mean you now need to know many aliases for the same
function?  How do we justify API bloat like this as better or easier to
read when it requires useless API memorization?

--=20
Doug Ledford <dledford@redhat.com>
    GPG Key ID: B826A3330E572FDD
    Key fingerprint =3D AE6B 1BDA 122B 23B4 265B  1274 B826 A333 0E57 2FD=
D


--6pe0LxMgSnp5T7x3pw4Ivr21beV4TfHPk--

--ueTXPMJ88ARsKg0prkt3A8WQ61iK3S1lD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJYW0mMAAoJELgmozMOVy/dGb0P/RK33E9+V/BaGehlynFU3EJv
u1SBiamAIpCyl+p3CtwUEupdumobvJoY9UsZuSaYAQHqS8b+anZSYAVMkOi7EHD/
nvUBmQO/3Gr8pqKv0FHEzUtUdGzsz/7u6E87FQ6E0l89G3LDBHrHBVQa2+zKNJjN
11zPrznYSUh6YIYuQUL9GbhNjXVARMmjQxpFCwz7QyFZAd/UvGnOCy3x/m0X/FfK
e+gzPApcTpj+Yxn3Jti00bKWSy2HfA0iM/7su3Ncg5QNSEbJICF0BDTGYUyeeMSm
ZiIMFx9WwdpaLL195GVmL1nTWMhjq/k1jC62F1zMggO5ojCNsPQF75FCerqbeotC
6M9TAjuv7kB+ELWtFw+UzEA7H5Xd2fLPR5k6DCaZGreMDEAZm0j5Fz2actnszCxm
rgZWcRsBVJlDkOU/GUbq6LEOEiZP5UNKgcQHwZLGScTHLqYU58P7IDMqGJXcqUO6
j6h9ZtvXceveyEfZ+HEdsmyxg6XYqwPwgLz9Z7yfN4ui8iU+11FhqSTks2BQCrI0
cil/IeEPdrzkL9Kzd4zM67doRUXW2jmeX1xl22IDxcbzGfUs2KI8QLAN5qaKq1F7
iTH5QT8Xm8hX1eHsld33qKsn7T7K+pVNIHdBYprxGtTf50RChlWbQ6d3d7E2EjIZ
kZOn9rLAGDMHWEBhrUst
=1zcz
-----END PGP SIGNATURE-----

--ueTXPMJ88ARsKg0prkt3A8WQ61iK3S1lD--
