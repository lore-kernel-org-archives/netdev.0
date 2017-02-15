From: Doug Ledford <dledford@redhat.com>
Subject: Re: linux-next: build failure after merge of the rdma tree
Date: Tue, 14 Feb 2017 20:05:55 -0500
Message-ID: <ad8c1dc5-9d96-b45f-fe89-115ea4d0174c@redhat.com>
References: <20170215113003.4c730d86@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="PEvLKDgDnoafWWLPc7HrTa9ojistMn8C8"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
        Michael Chan <michael.chan@broadcom.com>,
        Selvin Xavier <selvin.xavier@broadcom.com>,
        Eddie Wai <eddie.wai@broadcom.com>,
        Devesh Sharma <devesh.sharma@broadcom.com>,
        Somnath Kotur <somnath.kotur@broadcom.com>,
        Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20170215113003.4c730d86@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--PEvLKDgDnoafWWLPc7HrTa9ojistMn8C8
Content-Type: multipart/mixed; boundary="52fNafmgIQGt6daKaeEkgkCCh3M6eP15p";
 protected-headers="v1"
From: Doug Ledford <dledford@redhat.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
 David Miller <davem@davemloft.net>, Networking <netdev@vger.kernel.org>
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
 Michael Chan <michael.chan@broadcom.com>,
 Selvin Xavier <selvin.xavier@broadcom.com>,
 Eddie Wai <eddie.wai@broadcom.com>,
 Devesh Sharma <devesh.sharma@broadcom.com>,
 Somnath Kotur <somnath.kotur@broadcom.com>,
 Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Message-ID: <ad8c1dc5-9d96-b45f-fe89-115ea4d0174c@redhat.com>
Subject: Re: linux-next: build failure after merge of the rdma tree
References: <20170215113003.4c730d86@canb.auug.org.au>
In-Reply-To: <20170215113003.4c730d86@canb.auug.org.au>

--52fNafmgIQGt6daKaeEkgkCCh3M6eP15p
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 2/14/2017 7:30 PM, Stephen Rothwell wrote:
> Hi Doug,
>=20
> After merging the rdma tree, today's linux-next build (x86_64
> allmodconfig) failed like this:
>=20
> drivers/infiniband/hw/bnxt_re/main.c: In function 'bnxt_re_net_ring_fre=
e':
> drivers/infiniband/hw/bnxt_re/main.c:231:18: error: 'RING_ALLOC_REQ_RIN=
G_TYPE_CMPL' undeclared (first use in this function)
>   req.ring_type =3D RING_ALLOC_REQ_RING_TYPE_CMPL;
>                   ^
> drivers/infiniband/hw/bnxt_re/main.c:231:18: note: each undeclared iden=
tifier is reported only once for each function it appears in
> drivers/infiniband/hw/bnxt_re/main.c: In function 'bnxt_re_net_ring_all=
oc':
> drivers/infiniband/hw/bnxt_re/main.c:271:18: error: 'RING_ALLOC_REQ_RIN=
G_TYPE_CMPL' undeclared (first use in this function)
>   req.ring_type =3D RING_ALLOC_REQ_RING_TYPE_CMPL;
>                   ^
>=20
> Caused by commit
>=20
>   1ac5a4047975 ("RDMA/bnxt_re: Add bnxt_re RoCE driver")
>=20
> interacting with commit
>=20
>   bac9a7e0f5d6 ("bnxt_en: Update to firmware interface spec 1.7.0.")
>=20
> from the net-next tree.
>=20
> I added this merge fix patch:
>=20
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Wed, 15 Feb 2017 11:23:25 +1100
> Subject: [PATCH] RDMA/bnxt_re: fix for "bnxt_en: Update to firmware int=
erface spec 1.7.0."
>=20
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>

Thanks Stephen.  I had been forewarned about this by Selvin and I
instructed him to send me a fixup patch that would resolve the issue.  I
would apply it to my tree before merging with Linus.  He just hadn't
time to send it yet.  Your patch is sufficient as well, so I may just
pull it in.  Thanks again.

> ---
>  drivers/infiniband/hw/bnxt_re/main.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/infiniband/hw/bnxt_re/main.c b/drivers/infiniband/=
hw/bnxt_re/main.c
> index 6b9f1178050f..bd452a92b386 100644
> --- a/drivers/infiniband/hw/bnxt_re/main.c
> +++ b/drivers/infiniband/hw/bnxt_re/main.c
> @@ -228,7 +228,7 @@ static int bnxt_re_net_ring_free(struct bnxt_re_dev=
 *rdev, u16 fw_ring_id,
>  	}
> =20
>  	bnxt_re_init_hwrm_hdr(rdev, (void *)&req, HWRM_RING_FREE, -1, -1);
> -	req.ring_type =3D RING_ALLOC_REQ_RING_TYPE_CMPL;
> +	req.ring_type =3D RING_ALLOC_REQ_RING_TYPE_L2_CMPL;
>  	req.ring_id =3D cpu_to_le16(fw_ring_id);
>  	bnxt_re_fill_fw_msg(&fw_msg, (void *)&req, sizeof(req), (void *)&resp=
,
>  			    sizeof(resp), DFLT_HWRM_CMD_TIMEOUT);
> @@ -268,7 +268,7 @@ static int bnxt_re_net_ring_alloc(struct bnxt_re_de=
v *rdev, dma_addr_t *dma_arr,
>  	/* Association of ring index with doorbell index and MSIX number */
>  	req.logical_id =3D cpu_to_le16(map_index);
>  	req.length =3D cpu_to_le32(ring_mask + 1);
> -	req.ring_type =3D RING_ALLOC_REQ_RING_TYPE_CMPL;
> +	req.ring_type =3D RING_ALLOC_REQ_RING_TYPE_L2_CMPL;
>  	req.int_mode =3D RING_ALLOC_REQ_INT_MODE_MSIX;
>  	bnxt_re_fill_fw_msg(&fw_msg, (void *)&req, sizeof(req), (void *)&resp=
,
>  			    sizeof(resp), DFLT_HWRM_CMD_TIMEOUT);
>=20


--=20
Doug Ledford <dledford@redhat.com>
    GPG Key ID: B826A3330E572FDD
    Key fingerprint =3D AE6B 1BDA 122B 23B4 265B  1274 B826 A333 0E57 2FD=
D


--52fNafmgIQGt6daKaeEkgkCCh3M6eP15p--

--PEvLKDgDnoafWWLPc7HrTa9ojistMn8C8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJYo6l0AAoJELgmozMOVy/dFr8P/2M9+a14Pw/ItpFSr7hC0slx
ABjLk06slY0iQyp+mSFZ2qjNetsMBQOmvt15fEHMjH4Nlk/97rDLnD/v66N4vFSn
nFZxeYXWIWIvX5GcbfQjlXU8Q9X5BL5IBglg6t41+n5t3yoEM2aJWdz+zFGvP7Eq
htSV/ekMYKu5OjWiZSv6X2U2uTmDNxf2AOkPItqwRFTd6bDzoKqAN16qdXQbmYm1
8Bri8eSRMK4N1FfoWCZD9j4UKW4Bb9J7mHTuAs0qfA73l+G16LqN+VhNSk52WX48
Xhi2byPJOZ2BLf/E0+jQgmP9t1OohscYwLjwRby0s87+6gJvo9uaRHjPDh4EilGZ
8GAnj7LeLvoGOLPS726IqO319cJSf/E/C2LK2Oi2uESnx9Ap+LVPHxppGF23pwVC
1c6BnUidIAwBbYQhHqiaXTOEDziWj8bcU6bXSZCzrSjgx5MLUqOe4hOC92ieBaPG
6JN3N/EUSrGHDNAgsYVvzav5Amf5PNrDWi45xwZZFu9dbzVIIbKym6QZjcuu+F+H
nwhbnBlqOLBHW6NYIiF9ps3cEPOIHmtvrbdGwSy43ICy26h9sOi20g94VDi0GhML
+O1AG914rLF7SIs3yBEL3v8ztE3Gm7DE3yJAXZCq1Jgl0So74ex3Rk6GOkUCmRy/
JHq/JWU/xYnA15lAcSu4
=CPRs
-----END PGP SIGNATURE-----

--PEvLKDgDnoafWWLPc7HrTa9ojistMn8C8--
