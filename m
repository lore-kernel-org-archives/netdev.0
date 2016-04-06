From: Debabrata Banerjee <dbanerje@akamai.com>
Subject: [PATCH 1/3] bonding: do not allow rlb updates to invalid mac
Date: Wed,  6 Apr 2016 16:24:33 -0400
Message-ID: <1459974275-24944-1-git-send-email-dbanerje@akamai.com>
Cc: linux-kernel@vger.kernel.org,
	Debabrata Banerjee <dbanerje@akamai.com>
To: Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay05.akamai.com ([23.79.238.179]:32530 "EHLO
	prod-mail-xrelay05.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751892AbcDFUY6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 16:24:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make sure multicast, broadcast, and zero mac's cannot be the output of rlb
updates, which should all be directed arps. Receive load balancing will be
collapsed if any of these happen, as the switch will broadcast.

Signed-off-by: Debabrata Banerjee <dbanerje@akamai.com>

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index c5ac160..1b45378 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -453,7 +453,7 @@ static void rlb_update_client(struct rlb_client_info *client_info)
 {
 	int i;
 
-	if (!client_info->slave)
+	if (!client_info->slave || !is_valid_ether_addr(client_info->mac_dst))
 		return;
 
 	for (i = 0; i < RLB_ARP_BURST_SIZE; i++) {
-- 
2.8.0
