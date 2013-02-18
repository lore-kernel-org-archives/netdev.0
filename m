From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCHv2 vringh 3/3] caif_virtio: Introduce caif over virtio
Date: Tue, 19 Feb 2013 10:07:18 +1030
Message-ID: <87k3q5i47l.fsf@rustcorp.com.au>
References: <1360669793-6921-1-git-send-email-sjur.brandeland@stericsson.com> <1360669793-6921-4-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sjur@brendeland.net, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org,
	Dmitry Tarnyagin <dmitry.tarnyagin@stericsson.com>,
	Linus Walleij <linus.walleij@linaro.org>,
	Erwan Yvin <erwan.yvin@stericsson.com>,
	Vikram ARV <vikram.arv@stericsson.com>,
	Sjur =?utf-8?Q?Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>,
	Ido Yariv <ido@wizery.com>
To: sjur.brandeland@stericsson.com,
	"David S. Miller" <davem@davemloft.net>,
	Ohad Ben-Cohen <ohad@wizery.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1360669793-6921-4-git-send-email-sjur.brandeland@stericsson.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

sjur.brandeland@stericsson.com writes:
> From: Vikram ARV <vikram.arv@stericsson.com>
>
> Add the the Virtio shared memory driver for STE Modems.
> caif_virtio is implemented utilizing the virtio framework
> for data transport and is managed with the remoteproc frameworks.
>
> The Virtio queue is used for transmitting data to the modem, and
> the new vringh implementation is receiving data over the vring.
>
> Signed-off-by: Vikram ARV <vikram.arv@stericsson.com>
> Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>

I have applied 1 and 3 (2 is already in virtio-next); they're in my
pending-rebases branch behind the vringh patches which are pending
a final review.

Here's the warning fix patch I applied:

diff --git a/drivers/net/caif/caif_virtio.c b/drivers/net/caif/caif_vir=
tio.c
index d4f339c..df832e7 100644
--- a/drivers/net/caif/caif_virtio.c
+++ b/drivers/net/caif/caif_virtio.c
@@ -483,7 +483,7 @@ static int cfv_probe(struct virtio_device *vdev)
=20
 	vdev->priv =3D cfv;
=20
-	vringh_iov_init(&cfv->ctx.riov, NULL, 0);
+	vringh_kiov_init(&cfv->ctx.riov, NULL, 0);
 	cfv->ctx.head =3D USHRT_MAX;
=20
 	netif_napi_add(netdev, &cfv->napi, cfv_rx_poll, CFV_DEFAULT_QUOTA);
@@ -517,7 +517,7 @@ static void cfv_remove(struct virtio_device *vdev)
 	struct cfv_info *cfv =3D vdev->priv;
=20
 	tasklet_kill(&cfv->tx_release_tasklet);
-	vringh_iov_cleanup(&cfv->ctx.riov);
+	vringh_kiov_cleanup(&cfv->ctx.riov);
 	vdev->config->reset(vdev);
 	rproc_virtio_del_vringh(vdev, RX_RING_INDEX);
 	cfv->vr_rx =3D NULL;

Cheers,
Rusty.
