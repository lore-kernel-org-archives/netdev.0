From: frank.blaschka@de.ibm.com
Subject: [patch 05/11] qeth: layer 3 support vlan IPv6 on hiper socket
Date: Thu, 24 Apr 2008 10:15:22 +0200
Message-ID: <20080424081904.927728000@de.ibm.com>
References: <20080424081517.987104000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.29.154]:41686 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751314AbYDXITH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 04:19:07 -0400
Content-Disposition: inline; filename=704-qeth-vlanipv6.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Blaschka <frank.blaschka@de.ibm.com>

hiper socket require the QETH_HDR_EXT_VLAN_FRAME flag in the
qdio header to handle vlan tagged frames.

Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_l3_main.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff -urpN linux-2.6/drivers/s390/net/qeth_l3_main.c linux-2.6-patched/drivers/s390/net/qeth_l3_main.c
--- linux-2.6/drivers/s390/net/qeth_l3_main.c	2008-04-23 17:55:50.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_l3_main.c	2008-04-23 17:55:50.000000000 +0200
@@ -2568,9 +2568,10 @@ static void qeth_l3_fill_header(struct q
 	 * v6 uses passthrough, v4 sets the tag in the QDIO header.
 	 */
 	if (card->vlangrp && vlan_tx_tag_present(skb)) {
-		hdr->hdr.l3.ext_flags = (ipv == 4) ?
-			QETH_HDR_EXT_VLAN_FRAME :
-			QETH_HDR_EXT_INCLUDE_VLAN_TAG;
+		if ((ipv == 4) || (card->info.type == QETH_CARD_TYPE_IQD))
+			hdr->hdr.l3.ext_flags = QETH_HDR_EXT_VLAN_FRAME;
+		else
+			hdr->hdr.l3.ext_flags = QETH_HDR_EXT_INCLUDE_VLAN_TAG;
 		hdr->hdr.l3.vlan_id = vlan_tx_tag_get(skb);
 	}
 

-- 
