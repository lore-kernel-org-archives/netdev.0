From: Leon Romanovsky <leonro@mellanox.com>
Subject: Re: [PATCH net-next V2 3/4] net/mlx4_core: Use RCU to perform radix
 tree lookup for SRQ
Date: Tue, 20 Sep 2016 16:05:41 +0300
Message-ID: <20160920130541.GN26673@leon.nu>
References: <1474371582-998-1-git-send-email-tariqt@mellanox.com>
 <1474371582-998-4-git-send-email-tariqt@mellanox.com>
 <33b95e3f-ae37-4635-1810-c8e65d075e4d@cogentembedded.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="muT+E17Lr9urPYYJ"
Cc: Tariq Toukan <tariqt@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Eran Ben Elisha <eranbe@mellanox.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35983 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753586AbcITNFp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 09:05:45 -0400
Received: by mail-wm0-f68.google.com with SMTP id b184so3346410wma.3
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 06:05:44 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <33b95e3f-ae37-4635-1810-c8e65d075e4d@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--muT+E17Lr9urPYYJ
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Sep 20, 2016 at 03:47:49PM +0300, Sergei Shtylyov wrote:
> Hello.
>
> On 9/20/2016 2:39 PM, Tariq Toukan wrote:
>
> >From: Leon Romanovsky <leonro@mellanox.com>
> >
> >Radix tree lookup can be performed without locking.
> >
> >Fixes: 225c7b1feef1 ("IB/mlx4: Add a driver Mellanox ConnectX InfiniBand=
 adapters")
> >Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
> >Suggested-by: Sagi Grimberg <sagi@grimberg.me>
> >Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
> >---
> > drivers/net/ethernet/mellanox/mlx4/srq.c | 14 +++++---------
> > 1 file changed, 5 insertions(+), 9 deletions(-)
> >
> >diff --git a/drivers/net/ethernet/mellanox/mlx4/srq.c b/drivers/net/ethe=
rnet/mellanox/mlx4/srq.c
> >index 67146624eb58..f44d089e2ca6 100644
> >--- a/drivers/net/ethernet/mellanox/mlx4/srq.c
> >+++ b/drivers/net/ethernet/mellanox/mlx4/srq.c
> >@@ -45,15 +45,12 @@ void mlx4_srq_event(struct mlx4_dev *dev, u32 srqn, =
int event_type)
> > 	struct mlx4_srq_table *srq_table =3D &mlx4_priv(dev)->srq_table;
> > 	struct mlx4_srq *srq;
> >
> >-	spin_lock(&srq_table->lock);
> >-
> >+	rcu_read_lock();
> > 	srq =3D radix_tree_lookup(&srq_table->tree, srqn & (dev->caps.num_srqs=
 - 1));
> >+	rcu_read_unlock();
> > 	if (srq)
> > 		atomic_inc(&srq->refcount);
> >-
> >-	spin_unlock(&srq_table->lock);
> >-
> >-	if (!srq) {
> >+	else {
> > 		mlx4_warn(dev, "Async event for bogus SRQ %08x\n", srqn);
> > 		return;
> > 	}
>
>    CodingStyle: all branches of the *if* statement should have {} if at
> least one has.

I'm not arguing, but wanted to raise attention that checkpatch.pl
doesn't warn about it.

=E2=9E=9C  /tmp wget https://patchwork.ozlabs.org/patch/672216/mbox/
=E2=9E=9C  linux-rdma git:(master) ./scripts/checkpatch.pl /tmp/index.html
total: 0 errors, 0 warnings, 0 checks, 32 lines checked

/tmp/index.html has no obvious style problems and is ready for
submission.

And CodingStyle presents a little bit different case
----
This does not apply if only one branch of a conditional statement is a
single statement; in the latter case use braces in both branches:

        if (condition) {
                do_this();
                do_that();
        } else {
                otherwise();
        }

and not

        if (condition)
                do_that();
        else {
                otherwise();
		otherwise();
        }

Thanks

--muT+E17Lr9urPYYJ
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJX4TQkAAoJEORje4g2clineX4P/RFKW866Gxp0SovNntOV435T
yAm9kqag3YHScMl3vA6NRsfJH9vXRmNJkwVa8FaO8v7O3nm1iISJhoNCn4scNRB8
S+EXafmbwFduYvtnRYdy8HAbxlVLAJBncmKhJT8yukR9jAPYELAwMtcu/p8bp1PD
A4JhJL7Abwo7uZJB5B2DVjBzYPloThEII0jCtoQoV1fhBP48NKyYq4RCYHX/TjyZ
SjdcTXG2F8gOruD6dxPs5J/gjaVfX7t1qBWC7S9H9aoermDpfx29AEyI3ZoOiMgl
Z2C6+Pk0VwZaiKyeMIiv1wul+rylw92WPymdMKCeIK7JnbhqpQQizuH40Wu4hdiZ
wGiDlZ87myEc9DHTECL+wnRSYETCIokooD5cE1RDWn/3sLVz81LCx0tsmD6bU7Wt
gmGJcZgiuVe7xEb1bmr6uVgRTnbGro130SkAMMrgKlLRJKgnz5GiIJfmMnA40cfB
lswMFnYdbtajhW0kJrKuQ6QDzYFBCfKxZGtGlmN+4ImNhjrFA5m7jG+k1c6VZ5Xu
ymoA2JV8w55FUCj2pTstNEnIQzKBt5EkQ/FqHRjnyU3htYeI/nTJLkhghfonvTDq
V4QqIWnWKOcceXk+3//iV/evZkGYmPvR5fj/Z7by3P9dMoac7vlX3Nj6xG8P6Ir6
4cSXpK3l2PHpbLyXlwAK
=XDEL
-----END PGP SIGNATURE-----

--muT+E17Lr9urPYYJ--
