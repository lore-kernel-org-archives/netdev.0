From: frank.blaschka@de.ibm.com
Subject: [patch 3/4] [PATCH] qeth: l3 add vlan hdr in passthru frames
Date: Wed, 08 Dec 2010 13:58:00 +0100
Message-ID: <20101208125844.654432859@de.ibm.com>
References: <20101208125757.726629855@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.uk.ibm.com ([194.196.100.166]:51180 "EHLO
	mtagate6.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754863Ab0LHM6q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 07:58:46 -0500
Content-Disposition: inline; filename=606-qeth-vlan-passthru.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Blaschka <frank.blaschka@de.ibm.com>

OSA l3 mode is hw accelerated VLAN only for IPv4. Take care we
add the vlan hdr to a passthru frame in the device driver.

Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_l3_main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -3115,7 +3115,7 @@ static int qeth_l3_hard_start_xmit(struc
 				skb_pull(new_skb, ETH_HLEN);
 		}
 
-		if (ipv == 6 && card->vlangrp &&
+		if (ipv != 4 && card->vlangrp &&
 				vlan_tx_tag_present(new_skb)) {
 			skb_push(new_skb, VLAN_HLEN);
 			skb_copy_to_linear_data(new_skb, new_skb->data + 4, 4);

