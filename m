From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH 1/2] Phonet: publicize the Netlink notification function
Date: Wed, 24 Jun 2009 14:07:44 +0300
Message-ID: <1245841665-14213-1-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.105.134]:55617 "EHLO
	mgw-mx09.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751489AbZFXLHx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2009 07:07:53 -0400
Received: from vaebh106.NOE.Nokia.com (vaebh106.europe.nokia.com [10.160.244.32])
	by mgw-mx09.nokia.com (Switch-3.3.3/Switch-3.3.3) with ESMTP id n5OB7OZI014630
	for <netdev@vger.kernel.org>; Wed, 24 Jun 2009 06:07:56 -0500
Received: from localhost.localdomain (esdhcp035213.research.nokia.com [172.21.35.213])
	by mgw-da01.ext.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id n5OB7ipi001750
	for <netdev@vger.kernel.org>; Wed, 24 Jun 2009 14:07:45 +0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 include/net/phonet/pn_dev.h |    1 +
 net/phonet/pn_netlink.c     |    4 ++--
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/net/phonet/pn_dev.h b/include/net/phonet/pn_dev.h
index 5054dc5..29d1267 100644
--- a/include/net/phonet/pn_dev.h
+++ b/include/net/phonet/pn_dev.h
@@ -45,6 +45,7 @@ int phonet_address_add(struct net_device *dev, u8 add=
r);
 int phonet_address_del(struct net_device *dev, u8 addr);
 u8 phonet_address_get(struct net_device *dev, u8 addr);
 int phonet_address_lookup(struct net *net, u8 addr);
+void phonet_address_notify(int event, struct net_device *dev, u8 addr)=
;
=20
 #define PN_NO_ADDR	0xff
=20
diff --git a/net/phonet/pn_netlink.c b/net/phonet/pn_netlink.c
index cec4e59..f8b4cee 100644
--- a/net/phonet/pn_netlink.c
+++ b/net/phonet/pn_netlink.c
@@ -32,7 +32,7 @@
 static int fill_addr(struct sk_buff *skb, struct net_device *dev, u8 a=
ddr,
 		     u32 pid, u32 seq, int event);
=20
-static void rtmsg_notify(int event, struct net_device *dev, u8 addr)
+void phonet_address_notify(int event, struct net_device *dev, u8 addr)
 {
 	struct sk_buff *skb;
 	int err =3D -ENOBUFS;
@@ -94,7 +94,7 @@ static int addr_doit(struct sk_buff *skb, struct nlms=
ghdr *nlh, void *attr)
 	else
 		err =3D phonet_address_del(dev, pnaddr);
 	if (!err)
-		rtmsg_notify(nlh->nlmsg_type, dev, pnaddr);
+		phonet_address_notify(nlh->nlmsg_type, dev, pnaddr);
 	return err;
 }
=20
--=20
1.6.0.4

