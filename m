From: Ursula Braun <braunu@de.ibm.com>
Subject: [patch 1/1] qeth: remove header_ops bug
Date: Fri, 19 Oct 2007 22:02:31 +0000 (UTC)
Message-ID: <20071019220007.791059000__23060.1309020587$1192831358$gmane$org@linux.vnet.ibm.com>
References: <20071019215538.395133000@linux.vnet.ibm.com>
Cc: mschwid2@linux.vnet.ibm.com, apw@shadowen.org,
	linux-kernel@vger.kernel.org, kamalesh@linux.vnet.ibm.com,
	kaber@trash.net
To: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S968160AbXJSWCS@vger.kernel.org>
Date: Thu, 01 Jan 1970 01:00:01 +0100
Content-Disposition: inline; filename=qeth.patch
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ursula Braun <braunu@de.ibm.com>

Remove qeth bug caused by commit:
[NET]: Move hardware header operations out of netdevice.

Signed-off-by: Ursula Braun <braunu@de.ibm.com>
---
 drivers/s390/net/qeth_main.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Index: linux-2.6-uschi/drivers/s390/net/qeth_main.c
===================================================================
--- linux-2.6-uschi.orig/drivers/s390/net/qeth_main.c
+++ linux-2.6-uschi/drivers/s390/net/qeth_main.c
@@ -6643,7 +6643,8 @@ qeth_netdev_init(struct net_device *dev)
 	dev->vlan_rx_kill_vid = qeth_vlan_rx_kill_vid;
 	dev->vlan_rx_add_vid = qeth_vlan_rx_add_vid;
 #endif
-	dev->header_ops = &qeth_null_ops;
+	if (qeth_get_netdev_flags(card) & IFF_NOARP)
+		dev->header_ops = &qeth_null_ops;
 
 #ifdef CONFIG_QETH_IPV6
 	/*IPv6 address autoconfiguration stuff*/

-- 
