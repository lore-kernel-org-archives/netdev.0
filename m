From: Ursula Braun <braunu@de.ibm.com>
Subject: [patch 5/5] From: Ursula Braun <braunu@de.ibm.com>
Date: Fri, 05 Oct 2007 09:38:21 +0200
Message-ID: <20071005074045.557807000@linux.vnet.ibm.com>
References: <20071005073816.996932000@linux.vnet.ibm.com>
To: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.29.150]:36678 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752143AbXJEHks (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2007 03:40:48 -0400
Content-Disposition: inline; filename=qeth-inbound.diff
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

qeth: discard inbound packets with unknown header id

Signed-off-by: Ursula Braun <braunu@de.ibm.com>

Debugging statements are added for inbound packets with unknown
header id. Those packets are discarded and no longer processed as
osn-packets.
---

 drivers/s390/net/qeth_main.c |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

Index: linux-2.6-uschi/drivers/s390/net/qeth_main.c
===================================================================
--- linux-2.6-uschi.orig/drivers/s390/net/qeth_main.c
+++ linux-2.6-uschi/drivers/s390/net/qeth_main.c
@@ -2699,10 +2699,15 @@ qeth_process_inbound_buffer(struct qeth_
 			qeth_layer2_rebuild_skb(card, skb, hdr);
 		else if (hdr->hdr.l3.id == QETH_HEADER_TYPE_LAYER3)
 			vlan_tag = qeth_rebuild_skb(card, skb, hdr);
-		else { /*in case of OSN*/
+		else if (hdr->hdr.osn.id == QETH_HEADER_TYPE_OSN) {
 			skb_push(skb, sizeof(struct qeth_hdr));
 			skb_copy_to_linear_data(skb, hdr,
 						sizeof(struct qeth_hdr));
+		} else { /* unknown header type */
+			dev_kfree_skb_any(skb);
+			QETH_DBF_TEXT(trace, 3, "inbunkno");
+			QETH_DBF_HEX(control, 3, hdr, QETH_DBF_CONTROL_LEN);
+			continue;
 		}
 		/* is device UP ? */
 		if (!(card->dev->flags & IFF_UP)){

-- 
