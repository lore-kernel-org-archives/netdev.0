From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH 1/7] bfin_mac: fix build error due to net_device_ops convert
Date: Tue, 26 May 2009 05:29:09 -0400
Message-ID: <1243330149-15300-1-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: uclinux-dist-devel@blackfin.uclinux.org,
	Alexander Beregalov <a.beregalov@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:42809 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754208AbZEZJ3K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 May 2009 05:29:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The previous commit "convert to net_device_ops" broke the Blackfin MAC
driver as it declared the new structure before the function it used:
  CC      drivers/net/bfin_mac.o
drivers/net/bfin_mac.c:984: error: =E2=80=98bfin_mac_close=E2=80=99 und=
eclared here (not in a function)
make[1]: *** [drivers/net/bfin_mac.o] Error 1

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
CC: Alexander Beregalov <a.beregalov@gmail.com>
CC: David S. Miller <davem@davemloft.net>
---
 drivers/net/bfin_mac.c |   29 ++++++++++++++---------------
 1 files changed, 14 insertions(+), 15 deletions(-)

diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index 9f971ed..b4da182 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -979,22 +979,7 @@ static int bfin_mac_open(struct net_device *dev)
 	return 0;
 }
=20
-static const struct net_device_ops bfin_mac_netdev_ops =3D {
-	.ndo_open		=3D bfin_mac_open,
-	.ndo_stop		=3D bfin_mac_close,
-	.ndo_start_xmit		=3D bfin_mac_hard_start_xmit,
-	.ndo_set_mac_address	=3D bfin_mac_set_mac_address,
-	.ndo_tx_timeout		=3D bfin_mac_timeout,
-	.ndo_set_multicast_list	=3D bfin_mac_set_multicast_list,
-	.ndo_validate_addr	=3D eth_validate_addr,
-	.ndo_change_mtu		=3D eth_change_mtu,
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	.ndo_poll_controller	=3D bfin_mac_poll,
-#endif
-};
-
 /*
- *
  * this makes the board clean up everything that it can
  * and not talk to the outside world.   Caused by
  * an 'ifconfig ethX down'
@@ -1019,6 +1004,20 @@ static int bfin_mac_close(struct net_device *dev=
)
 	return 0;
 }
=20
+static const struct net_device_ops bfin_mac_netdev_ops =3D {
+	.ndo_open		=3D bfin_mac_open,
+	.ndo_stop		=3D bfin_mac_close,
+	.ndo_start_xmit		=3D bfin_mac_hard_start_xmit,
+	.ndo_set_mac_address	=3D bfin_mac_set_mac_address,
+	.ndo_tx_timeout		=3D bfin_mac_timeout,
+	.ndo_set_multicast_list	=3D bfin_mac_set_multicast_list,
+	.ndo_validate_addr	=3D eth_validate_addr,
+	.ndo_change_mtu		=3D eth_change_mtu,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	=3D bfin_mac_poll,
+#endif
+};
+
 static int __devinit bfin_mac_probe(struct platform_device *pdev)
 {
 	struct net_device *ndev;
--=20
1.6.3.1

