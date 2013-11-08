From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the tip tree with the net-next tree
Date: Fri, 8 Nov 2013 15:58:33 +1100
Message-ID: <20131108155833.873fd4dcd27a56e0ff8f6df0@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Fri__8_Nov_2013_15_58_33_+1100_H=8xqEuf.VyzzWFE"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	John Stultz <john.stultz@linaro.org>,
	Jason Wang <jasowang@redhat.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__8_Nov_2013_15_58_33_+1100_H=8xqEuf.VyzzWFE
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the tip tree got a conflict in
drivers/net/virtio_net.c between commit 9bb8ca86075f ("virtio-net: switch
to use XPS to choose txq") from the net-next tree and commit 827da44c6141
("net: Explicitly initialize u64_stats_sync structures for lockdep") from
the tip tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/virtio_net.c
index 7d0eff710913,ee384f3d612b..000000000000
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@@ -1584,6 -1569,18 +1584,14 @@@ static int virtnet_probe(struct virtio_
  	if (vi->stats =3D=3D NULL)
  		goto free;
 =20
+ 	for_each_possible_cpu(i) {
+ 		struct virtnet_stats *virtnet_stats;
+ 		virtnet_stats =3D per_cpu_ptr(vi->stats, i);
+ 		u64_stats_init(&virtnet_stats->tx_syncp);
+ 		u64_stats_init(&virtnet_stats->rx_syncp);
+ 	}
+=20
+=20
 -	vi->vq_index =3D alloc_percpu(int);
 -	if (vi->vq_index =3D=3D NULL)
 -		goto free_stats;
 -
  	mutex_init(&vi->config_lock);
  	vi->config_enable =3D true;
  	INIT_WORK(&vi->config_work, virtnet_config_changed_work);

--Signature=_Fri__8_Nov_2013_15_58_33_+1100_H=8xqEuf.VyzzWFE
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJSfG99AAoJEMDTa8Ir7ZwV2QMP/2RR4y4YwTc0bvFOlEGSNfzT
bLVbCx8HpqOavx6pxgNteOsIsPPGPuZH1cJAVzaSohmnHHTBbt0ZrjsxUDATpIhX
VyfaFmKUN7YgZRXYjyM8GNxBdMGrL4dGM4v5SNIL5IwXvoUA+FrE3mwvvZC0IuUf
kGE/QQL6Jky8kk6irJsAHHPuVkDFMCym2FQTjHdX2/XR3X3mPSnAyiMBEXmtDw1s
FYMz0f8vdHO4pOo/TZmy74g5uo3wnr/nXfpChFxpIlgfGFZDMhiGzhzEVkgEllbl
DCY/hgTTBZioDlIc79KPistTtB3kcbCqVcXKdB3fHTCB4bj0VZCL/sy+PxbBKhnV
PDzbUmKzRtRL9G83JKTY5OgjjdJ9i5eCgh1fiiuNe1LCkn8XWRZnl9yQUIdh7DcI
JFKSwEPCNsQYebkrblgFeLhLqIKSNapaesoAFML0Dra3ZYWK0Fd879NfSirSy3/m
fDZ6sOupoOFbZafkEC1Mb14ukLh+J/uwFEpiUpE1SlL9rvPZY8qsMJJcXbdQcDyD
2ZVS/KKiiB6b1kCNeaJmu+tT/JZONWryMO4DoJZY/DOzI0HQ40QC2YhLx54qiQs1
r5qPR+YNIgeQDTZ2aCBPIBonnJxN86uwbGF4M2kFB0ZSmE9MPITUc7WAk7IaJYRP
6K7aqxdtudyPTSW2AM6o
=JEKM
-----END PGP SIGNATURE-----

--Signature=_Fri__8_Nov_2013_15_58_33_+1100_H=8xqEuf.VyzzWFE--
