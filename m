From: frank.blaschka@de.ibm.com
Subject: [patch 3/3] [PATCH] qeth: repair crash in qeth_l3_vlan_rx_kill_vid()
Date: Wed, 25 Jul 2012 10:34:29 +0200
Message-ID: <20120725083446.358537432@de.ibm.com>
References: <20120725083426.704834478@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	stable@vger.kernel.org, Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp17.uk.ibm.com ([195.75.94.113]:55112 "EHLO
	e06smtp17.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932753Ab2GYIey (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2012 04:34:54 -0400
Received: from /spool/local
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Wed, 25 Jul 2012 09:34:52 +0100
Content-Disposition: inline; filename=602-qeth-vlan-rx-kill.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit efc73f4b "net: Fix memory leak - vlan_info struct" adds deletion of
VLAN 0 for devices with feature NETIF_F_HW_VLAN_FILTER. For driver
qeth these are the layer 3 devices. Usually there exists no
separate vlan net_device for VLAN 0. Thus the qeth functions
qeth_l3_free_vlan_addresses4() and qeth_l3_free_vlan_addresses6()
require an extra checking if function __vlan_find_dev_deep()
returns with a net_device.

Cc: stable@vger.kernel.org
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---
 drivers/s390/net/qeth_l3_main.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index f0045ca..d01a617 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -1758,6 +1758,8 @@ static void qeth_l3_free_vlan_addresses4(struct qeth_card *card,
 	QETH_CARD_TEXT(card, 4, "frvaddr4");
 
 	netdev = __vlan_find_dev_deep(card->dev, vid);
+	if (!netdev)
+		return;
 	in_dev = in_dev_get(netdev);
 	if (!in_dev)
 		return;
@@ -1786,6 +1788,8 @@ static void qeth_l3_free_vlan_addresses6(struct qeth_card *card,
 	QETH_CARD_TEXT(card, 4, "frvaddr6");
 
 	netdev = __vlan_find_dev_deep(card->dev, vid);
+	if (!netdev)
+		return;
 	in6_dev = in6_dev_get(netdev);
 	if (!in6_dev)
 		return;
-- 
1.7.11.3
