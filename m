From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] net: tuntap: Fix tun_net_fix_features()
Date: Tue, 17 May 2011 10:19:54 +0200 (CEST)
Message-ID: <20110517081954.A227013A6A@rere.qmqm.pl>
References: <BANLkTimeRLQ0FLASsLE+ZxiXOk4gHt5XFQ@mail.gmail.com>
	<20110505100506.GA20111@gondor.apana.org.au> <20110516073210.GB6610@redhat.com>
        <20110516080702.GA1857@gondor.apana.org.au> <20110516081841.GA8073@redhat.com>
        <20110516093822.GA2779@gondor.apana.org.au> <20110516094821.GA9427@redhat.com>
        <20110516104309.GA3534@gondor.apana.org.au> <20110516112133.GA11274@redhat.com>
        <20110516121857.GA4495@gondor.apana.org.au> <BANLkTi=7i=AQfPNBEGcLFieaO9wXgBk6rg@mail.gmail.com>
        <20110516224658.GA11157@gondor.apana.org.au>
        <BANLkTimeRLQ0FLASsLE+ZxiXOk4gHt5XFQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Shan Wei <shanwei@cn.fujitsu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:49833 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751188Ab1EQIT5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 May 2011 04:19:57 -0400
In-Reply-To: <BANLkTimeRLQ0FLASsLE+ZxiXOk4gHt5XFQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tun->set_features are meant to limit not force the features.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/tun.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 74e9405..f77c6d0 100644
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

