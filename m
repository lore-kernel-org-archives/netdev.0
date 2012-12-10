From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the virtio tree
Date: Mon, 10 Dec 2012 13:37:25 +1100
Message-ID: <20121210133725.cb4a76545691b099c73c40ea@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__10_Dec_2012_13_37_25_+1100_sLYgq6CDm6GwUtGc"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jason Wang <jasowang@redhat.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__10_Dec_2012_13_37_25_+1100_sLYgq6CDm6GwUtGc
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Rusty,

After merging the virtio tree, today's linux-next build (x86_64
allmodconfig) failed like this:

drivers/net/virtio_net.c: In function 'vq2txq':
drivers/net/virtio_net.c:150:2: error: implicit declaration of function 'vi=
rtqueue_get_queue_index' [-Werror=3Dimplicit-function-declaration]

Caused by commit 986a4f4d452d ("virtio_net: multiqueue support") from the
net-next tree interacting with commit 105e892960e1 ("virtio: move
queue_index and num_free fields into core struct virtqueue") from the
virtio tree.

I applied the patch below and can carry it as necessary.

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 10 Dec 2012 13:33:57 +1100
Subject: [PATCH] virtnet: for up for virtqueue_get_queue_index removal

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/net/virtio_net.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 33d6f6f..8afe32d 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -147,7 +147,7 @@ struct padded_vnet_hdr {
  */
 static int vq2txq(struct virtqueue *vq)
 {
-	return (virtqueue_get_queue_index(vq) - 1) / 2;
+	return (vq->index - 1) / 2;
 }
=20
 static int txq2vq(int txq)
@@ -157,7 +157,7 @@ static int txq2vq(int txq)
=20
 static int vq2rxq(struct virtqueue *vq)
 {
-	return virtqueue_get_queue_index(vq) / 2;
+	return vq->index / 2;
 }
=20
 static int rxq2vq(int rxq)
--=20
1.7.10.280.gaa39

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Mon__10_Dec_2012_13_37_25_+1100_sLYgq6CDm6GwUtGc
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJQxUrlAAoJEECxmPOUX5FE0NcP/jam3FNQUg5eP16QfLtGxSjt
wndm7PKtGMM0dpXx64tfJXQ1Ms45UdGmZyk9l5K80CvepsXtwTEdLbAbgu+m0dVD
0DRhF8E30Wm1yvqO83/rG3fl4xFoP8W3sNwABzLZdNgIABOBKwxA/zfvSigg22xb
R3iouvQ6t+3NvN76GeVW8w/sTqzTkItPnwDdtCRrlPXEpGtdRdbl1UFbY+adBcoc
AmzaqkX0LEJ6RYuFEApc1zX4sNTVg/szbAvndNfheExVMVID79Qq9H5T6in+5LOx
ZB7QPM35V4Pg0R/NYCsVdnH0OeSBt+fOfHZOarir8Z8JEOf4sJiTg9+3LI/A4iyX
iPXsoB5kmM+tBVHdZLdSeD4Rax6BltG1F251t7hodgB43+ZOr6mbGy+BWsatydbw
8sagLKN2WrahzzztPY5euBvVJfslw6wtPFJgChZR5fSNXRbYV+XErBuiB5zdENUv
ZhygEk1q6pnav3Kxv6iqIsIgH2J59z2qk/GnaZoYtVZ27KpKAEFgda4PRqsJUspg
Wy1MNhiRgt8ebDiuIOLIKXBZEAhbl0ATWWtFDC8toYUSM4noeidUt0QllDOxnxia
dlYkJzSkjPzeXzN0UL3AFSkU75g53qvItPIMj2POxJYXfTZPokn8fe3se6gdJgtz
1D+T88/ZfGabRfrbiXAJ
=NJHK
-----END PGP SIGNATURE-----

--Signature=_Mon__10_Dec_2012_13_37_25_+1100_sLYgq6CDm6GwUtGc--
