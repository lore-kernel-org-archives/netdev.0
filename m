From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?= <remi@remlab.net>
Subject: [PATCH] Phonet: Netlink event for autoconfigured addresses
Date: Mon, 14 Sep 2009 16:10:27 +0300
Message-ID: <1252933829-12442-1-git-send-email-remi@remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:57625 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753778AbZINNK0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Sep 2009 09:10:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 net/phonet/pn_dev.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/net/phonet/pn_dev.c b/net/phonet/pn_dev.c
index 2f65dca..5f42f30 100644
--- a/net/phonet/pn_dev.c
+++ b/net/phonet/pn_dev.c
@@ -209,7 +209,14 @@ static int phonet_device_autoconf(struct net_devic=
e *dev)
 						SIOCPNGAUTOCONF);
 	if (ret < 0)
 		return ret;
-	return phonet_address_add(dev, req.ifr_phonet_autoconf.device);
+
+	ASSERT_RTNL();
+	ret =3D phonet_address_add(dev, req.ifr_phonet_autoconf.device);
+	if (ret)
+		return ret;
+	phonet_address_notify(RTM_NEWADDR, dev,
+				req.ifr_phonet_autoconf.device);
+	return 0;
 }
=20
 /* notify Phonet of device events */
--=20
1.6.0.4

