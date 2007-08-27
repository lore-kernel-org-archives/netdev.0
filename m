From: Ursula Braun <braunu@de.ibm.com>
Subject: [patch 3/7] qeth: dont return the return values of void functions.
Date: Mon, 27 Aug 2007 19:27:34 +0200
Message-ID: <20070827173100.459007000@linux.vnet.ibm.com>
References: <20070827172731.370533000@linux.vnet.ibm.com>
Cc: frank.blaschka@de.ibm.com,
	Heiko Carstens <heiko.carstens@de.ibm.com>
To: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.29.155]:54736 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761696AbXH0RbF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Aug 2007 13:31:05 -0400
Content-Disposition: inline; filename=705-qeth-return.diff
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Heiko Carstens <heiko.carstens@de.ibm.com>

Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
Signed-off-by: Ursula Braun <braunu@de.ibm.com>
---

 drivers/s390/net/qeth.h     |    4 ++--
 drivers/s390/net/qeth_sys.c |    8 ++++----
 2 files changed, 6 insertions(+), 6 deletions(-)

Index: linux-2.6-uschi/drivers/s390/net/qeth.h
===================================================================
--- linux-2.6-uschi.orig/drivers/s390/net/qeth.h
+++ linux-2.6-uschi/drivers/s390/net/qeth.h
@@ -1178,9 +1178,9 @@ qeth_ipaddr_to_string(enum qeth_prot_ver
 		      char *buf)
 {
 	if (proto == QETH_PROT_IPV4)
-		return qeth_ipaddr4_to_string(addr, buf);
+		qeth_ipaddr4_to_string(addr, buf);
 	else if (proto == QETH_PROT_IPV6)
-		return qeth_ipaddr6_to_string(addr, buf);
+		qeth_ipaddr6_to_string(addr, buf);
 }
 
 static inline int
Index: linux-2.6-uschi/drivers/s390/net/qeth_sys.c
===================================================================
--- linux-2.6-uschi.orig/drivers/s390/net/qeth_sys.c
+++ linux-2.6-uschi/drivers/s390/net/qeth_sys.c
@@ -1760,10 +1760,10 @@ qeth_remove_device_attributes(struct dev
 {
 	struct qeth_card *card = dev->driver_data;
 
-	if (card->info.type == QETH_CARD_TYPE_OSN)
-		return sysfs_remove_group(&dev->kobj,
-					  &qeth_osn_device_attr_group);
-
+	if (card->info.type == QETH_CARD_TYPE_OSN) {
+		sysfs_remove_group(&dev->kobj, &qeth_osn_device_attr_group);
+		return;
+	}
 	sysfs_remove_group(&dev->kobj, &qeth_device_attr_group);
 	sysfs_remove_group(&dev->kobj, &qeth_device_ipato_group);
 	sysfs_remove_group(&dev->kobj, &qeth_device_vipa_group);

-- 
