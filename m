From: igorm@etf.rs
Subject: [PATCH 2/4 net-next] net:x25: use IS_ENABLED
Date: Mon, 12 Dec 2011 04:58:23 -0800
Message-ID: <1323694705-2793-2-git-send-email-igorm@etf.rs>
References: <igorm@etf.rs>
 <1323694705-2793-1-git-send-email-igorm@etf.rs>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, =?UTF-8?q?Igor=20Maravi=C4=87?= <igorm@etf.rs>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.etf.rs ([147.91.14.170]:55192 "EHLO mx2.etf.bg.ac.rs"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753157Ab1LLM7D convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2011 07:59:03 -0500
In-Reply-To: <1323694705-2793-1-git-send-email-igorm@etf.rs>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Igor Maravi=C4=87 <igorm@etf.rs>

Use IS_ENABLED(CONFIG_FOO)
instead of defined(CONFIG_FOO) || defined (CONFIG_FOO_MODULE)

Signed-off-by: Igor Maravi=C4=87 <igorm@etf.rs>
---
 net/x25/af_x25.c    |    2 +-
 net/x25/x25_dev.c   |    6 +++---
 net/x25/x25_route.c |    2 +-
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index 3e16c6a..a306bc6 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -232,7 +232,7 @@ static int x25_device_event(struct notifier_block *=
this, unsigned long event,
 		return NOTIFY_DONE;
=20
 	if (dev->type =3D=3D ARPHRD_X25
-#if defined(CONFIG_LLC) || defined(CONFIG_LLC_MODULE)
+#if IS_ENABLED(CONFIG_LLC)
 	 || dev->type =3D=3D ARPHRD_ETHER
 #endif
 	 ) {
diff --git a/net/x25/x25_dev.c b/net/x25/x25_dev.c
index fa2b418..f0ce862 100644
--- a/net/x25/x25_dev.c
+++ b/net/x25/x25_dev.c
@@ -161,7 +161,7 @@ void x25_establish_link(struct x25_neigh *nb)
 		*ptr =3D X25_IFACE_CONNECT;
 		break;
=20
-#if defined(CONFIG_LLC) || defined(CONFIG_LLC_MODULE)
+#if IS_ENABLED(CONFIG_LLC)
 	case ARPHRD_ETHER:
 		return;
 #endif
@@ -180,7 +180,7 @@ void x25_terminate_link(struct x25_neigh *nb)
 	struct sk_buff *skb;
 	unsigned char *ptr;
=20
-#if defined(CONFIG_LLC) || defined(CONFIG_LLC_MODULE)
+#if IS_ENABLED(CONFIG_LLC)
 	if (nb->dev->type =3D=3D ARPHRD_ETHER)
 		return;
 #endif
@@ -213,7 +213,7 @@ void x25_send_frame(struct sk_buff *skb, struct x25=
_neigh *nb)
 		*dptr =3D X25_IFACE_DATA;
 		break;
=20
-#if defined(CONFIG_LLC) || defined(CONFIG_LLC_MODULE)
+#if IS_ENABLED(CONFIG_LLC)
 	case ARPHRD_ETHER:
 		kfree_skb(skb);
 		return;
diff --git a/net/x25/x25_route.c b/net/x25/x25_route.c
index 97d77c5..cf63662 100644
--- a/net/x25/x25_route.c
+++ b/net/x25/x25_route.c
@@ -134,7 +134,7 @@ struct net_device *x25_dev_get(char *devname)
=20
 	if (dev &&
 	    (!(dev->flags & IFF_UP) || (dev->type !=3D ARPHRD_X25
-#if defined(CONFIG_LLC) || defined(CONFIG_LLC_MODULE)
+#if IS_ENABLED(CONFIG_LLC)
 					&& dev->type !=3D ARPHRD_ETHER
 #endif
 					))){
--=20
1.7.5.4
