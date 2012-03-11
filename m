From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [PATCH net-next 2/2] caif: make zero a legal caif connetion id.
Date: Sun, 11 Mar 2012 21:28:32 +0100
Message-ID: <1331497712-13534-2-git-send-email-sjur.brandeland@stericsson.com>
References: <1331497712-13534-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sjurbren@gmail.com,
	=?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:64089 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751725Ab2CKU2s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Mar 2012 16:28:48 -0400
Received: by lahj13 with SMTP id j13so3064319lah.19
        for <netdev@vger.kernel.org>; Sun, 11 Mar 2012 13:28:47 -0700 (PDT)
In-Reply-To: <1331497712-13534-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Connection ID configured through RTNL must allow zero as
connection id. If connection-id is not given when creating the
interface, configure a loopback interface using ifindex as
connection-id.

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
 net/caif/chnl_net.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/caif/chnl_net.c b/net/caif/chnl_net.c
index e866234..20618dd 100644
--- a/net/caif/chnl_net.c
+++ b/net/caif/chnl_net.c
@@ -28,6 +28,7 @@
 /* 5 sec. connect timeout */
 #define CONNECT_TIMEOUT (5 * HZ)
 #define CAIF_NET_DEFAULT_QUEUE_LEN 500
+#define UNDEF_CONNID 0xffffffff
=20
 /*This list is protected by the rtnl lock. */
 static LIST_HEAD(chnl_net_list);
@@ -408,7 +409,7 @@ static void ipcaif_net_setup(struct net_device *dev=
)
 	priv->conn_req.link_selector =3D CAIF_LINK_HIGH_BANDW;
 	priv->conn_req.priority =3D CAIF_PRIO_LOW;
 	/* Insert illegal value */
-	priv->conn_req.sockaddr.u.dgm.connection_id =3D 0;
+	priv->conn_req.sockaddr.u.dgm.connection_id =3D UNDEF_CONNID;
 	priv->flowenabled =3D false;
=20
 	init_waitqueue_head(&priv->netmgmt_wq);
@@ -471,9 +472,11 @@ static int ipcaif_newlink(struct net *src_net, str=
uct net_device *dev,
 	else
 		list_add(&caifdev->list_field, &chnl_net_list);
=20
-	/* Take ifindex as connection-id if null */
-	if (caifdev->conn_req.sockaddr.u.dgm.connection_id =3D=3D 0)
+	/* Use ifindex as connection id, and use loopback channel default. */
+	if (caifdev->conn_req.sockaddr.u.dgm.connection_id =3D=3D UNDEF_CONNI=
D) {
 		caifdev->conn_req.sockaddr.u.dgm.connection_id =3D dev->ifindex;
+		caifdev->conn_req.protocol =3D CAIFPROTO_DATAGRAM_LOOP;
+	}
 	return ret;
 }
=20
--=20
1.7.0.4
