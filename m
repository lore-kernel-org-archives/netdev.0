From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH] virtio_net: rename driver struct to please modpost
Date: Thu,  5 Nov 2009 09:17:17 +0100
Message-ID: <1257409037-29916-1-git-send-email-u.kleine-koenig@pengutronix.de>
References: <200911051510.54163.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: rusty@rustcorp.com.au, Sam Ravnborg <sam@ravnborg.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alex Williamson <alex.williamson@hp.com>,
	Mark McLoughlin <markmc@redhat.com>, netdev@vger.kernel.org
To: mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:46377 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750793AbZKEIRv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2009 03:17:51 -0500
In-Reply-To: <200911051510.54163.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit

	3d1285b (move virtnet_remove to .devexit.text)

introduced the first reference to __devexit in struct virtio_driver
virtio_net which upset modpost ("Section mismatch in reference from the
variable virtio_net to the function .devexit.text:virtnet_remove()").

=46ix this by renaming virtio_net to virtio_net_driver.

Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
Reported-by: Michael S. Tsirkin <mst@redhat.com>
Blame-taken-by: Rusty Russell <rusty@rustcorp.com.au>
Cc: Sam Ravnborg <sam@ravnborg.org>
Cc: David S. Miller <davem@davemloft.net>
Cc: Alex Williamson <alex.williamson@hp.com>
Cc: Mark McLoughlin <markmc@redhat.com>
Cc: netdev@vger.kernel.org
---
Hello,

@Rusty: IMHO there's no need to apologize.  The driver was enhanced by
3d1285b and I consider it OK not to notice the (false) section warning.
(But if you think it was you who took my first patch, then you forgot t=
o
add you S-o-b which is a worse trespass :-)

Best regards
Uwe

 drivers/net/virtio_net.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 05630f2..b9e002f 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -998,7 +998,7 @@ static unsigned int features[] =3D {
 	VIRTIO_NET_F_CTRL_RX, VIRTIO_NET_F_CTRL_VLAN,
 };
=20
-static struct virtio_driver virtio_net =3D {
+static struct virtio_driver virtio_net_driver =3D {
 	.feature_table =3D features,
 	.feature_table_size =3D ARRAY_SIZE(features),
 	.driver.name =3D	KBUILD_MODNAME,
@@ -1011,12 +1011,12 @@ static struct virtio_driver virtio_net =3D {
=20
 static int __init init(void)
 {
-	return register_virtio_driver(&virtio_net);
+	return register_virtio_driver(&virtio_net_driver);
 }
=20
 static void __exit fini(void)
 {
-	unregister_virtio_driver(&virtio_net);
+	unregister_virtio_driver(&virtio_net_driver);
 }
 module_init(init);
 module_exit(fini);
--=20
1.6.5.2

