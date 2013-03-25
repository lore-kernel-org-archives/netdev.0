From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the kvm tree with the  tree
Date: Mon, 25 Mar 2013 13:32:33 +1100
Message-ID: <20130325133233.0ae2af5bf7e25dca9c3999ba@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__25_Mar_2013_13_32_33_+1100_1gdbcvePjnMfTsyV"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Cornelia Huck <cornelia.huck@de.ibm.com>
To: Marcelo Tosatti <mtosatti@redhat.com>,
	Gleb Natapov <gleb@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__25_Mar_2013_13_32_33_+1100_1gdbcvePjnMfTsyV
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the kvm tree got a conflict in
drivers/s390/kvm/virtio_ccw.c between commit 9d0ca6ed6f2f ("virtio:
remove obsolete virtqueue_get_queue_index()") from the net-next tree and
commit 07e169335ff0 ("virtio_ccw: pass a cookie value to kvm hypercall")
from the kvm tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/s390/kvm/virtio_ccw.c
index fb877b59,42d507c..0000000
--- a/drivers/s390/kvm/virtio_ccw.c
+++ b/drivers/s390/kvm/virtio_ccw.c
@@@ -166,7 -167,8 +167,7 @@@ static void virtio_ccw_kvm_notify(struc
 =20
  	vcdev =3D to_vc_device(info->vq->vdev);
  	ccw_device_get_schid(vcdev->cdev, &schid);
- 	do_kvm_notify(schid, vq->index);
 -	info->cookie =3D do_kvm_notify(schid, virtqueue_get_queue_index(vq),
 -				     info->cookie);
++	info->cookie =3D do_kvm_notify(schid, vq->index, info->cookie);
  }
 =20
  static int virtio_ccw_read_vq_conf(struct virtio_ccw_device *vcdev,

--Signature=_Mon__25_Mar_2013_13_32_33_+1100_1gdbcvePjnMfTsyV
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJRT7dBAAoJEECxmPOUX5FEP+cP/1nKRZrmAQdVUwZZjUg4HrfO
89FViPfO1YI3RYYCoyGLyj8Krx/KBvyKggBKB5CIevdc3BY0igUgXrdoNptaXQg2
iR+46Ea9vj2AGKrZV40qFHEN4xIX6SVmRvpnLXb44boyVLtoylheTYt7+avvtc14
UrcL+nAQeL8DczRzJjQ/9FSDfYjisC1M/4Qc1Z8YAqD1spziROdpvLTsX5Yci2pr
0rkMoi6FVQENZFbzUtWqovbBeN6mkLiW8oqPahw/IcJkDk+WfNo3h9xt1se4c5oN
tyS9C9/X7m3c+vtpoJy5F1YryyJwO4CvNO/RLUPpclq9kLKM3rE6k/hUIIw2r82o
lDBKxhvr4FtZHHz8rYrH/bkpi/IHbXKDD61aiNMKEFBGsDSg6Je8uYnKq8rIpRW7
nTycS+4vEzSbz1kT/BM0RHfv4ggvG1EueCv4rYoIlKo5lQV16uykRiCDaTtRqcRt
xJfgPt3zQxaiIe0xlZTddPeeadI2EFTDIGDBwL/3tsRX9q43sa+LseyhgomY+RmL
paVivi/C0/29dlnbn4l8x0ABMhF4yQDkfzL9jilr4H/Ydji7KdnIZsqH12pT1HM/
1nLJ5osT5o5ociAzN6WMEwdOSxqF/MnDbCJA7s0MzHdQHZbzZY5443O3xLpZ8Zv+
QzNatC67sKuV4Vmu5dI2
=y4WA
-----END PGP SIGNATURE-----

--Signature=_Mon__25_Mar_2013_13_32_33_+1100_1gdbcvePjnMfTsyV--
