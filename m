From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [RESENT PATCH] net: tuntap: Fix tun_net_fix_features()
Date: Mon, 20 Jun 2011 21:14:55 +0200 (CEST)
Message-ID: <d66c8380b6c50fdcfe2dce344b39bb470a75ba3f.1308595725.git.mirq-linux@rere.qmqm.pl>
References: <20110517081954.A227013A6A@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Shan Wei <shanwei@cn.fujitsu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:41922 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754216Ab1FTTPB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jun 2011 15:15:01 -0400
In-Reply-To: <20110517081954.A227013A6A@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tun->set_features are meant to limit not force the features.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
Acked-by: Michael S. Tsirkin <mst@redhat.com>

---
 drivers/net/tun.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 4dab85e..56981c2 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -458,7 +458,7 @@ static u32 tun_net_fix_features(struct net_device *=
dev, u32 features)
 {
 	struct tun_struct *tun =3D netdev_priv(dev);
=20
-	return (features & tun->set_features) | (features & ~TUN_USER_FEATURE=
S);
+	return features & (tun->set_features | ~TUN_USER_FEATURES);
 }
=20
 static const struct net_device_ops tun_netdev_ops =3D {
--=20
1.7.2.5

