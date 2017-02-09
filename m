From: Netanel Belgazal <netanel@annapurnalabs.com>
Subject: [PATCH V4 net-next 04/13] net/ena: fix RSS default hash configuration
Date: Thu,  9 Feb 2017 15:21:30 +0200
Message-ID: <1486646499-13682-5-git-send-email-netanel@annapurnalabs.com>
References: <1486646499-13682-1-git-send-email-netanel@annapurnalabs.com>
Cc: Netanel Belgazal <netanel@annapurnalabs.com>, dwmw@amazon.com,
        zorik@annapurnalabs.com, alex@annapurnalabs.com,
        saeed@annapurnalabs.com, msw@amazon.com, aliguori@amazon.com,
        nafea@annapurnalabs.com, eric.dumazet@gmail.com,
        evgenys@annapurnalabs.com
To: linux-kernel@vger.kernel.org, davem@davemloft.net,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:33707 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751964AbdBIN3D (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 08:29:03 -0500
Received: by mail-wm0-f47.google.com with SMTP id t18so57764835wmt.0
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 05:28:52 -0800 (PST)
In-Reply-To: <1486646499-13682-1-git-send-email-netanel@annapurnalabs.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ENA default hash configures IPv4_frag hash twice instead of
configure non-IP packets.

The bug caused IPv4 fragmented packets to be calculated based on
L2 source and destination address instead of L3 source and destination.
IPv4 packets can reach to the wrong Rx queue.

Signed-off-by: Netanel Belgazal <netanel@annapurnalabs.com>
---
 drivers/net/ethernet/amazon/ena/ena_com.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/amazon/ena/ena_com.c b/drivers/net/ethernet/amazon/ena/ena_com.c
index 3066d9c..46aad3a 100644
--- a/drivers/net/ethernet/amazon/ena/ena_com.c
+++ b/drivers/net/ethernet/amazon/ena/ena_com.c
@@ -2184,7 +2184,7 @@ int ena_com_set_default_hash_ctrl(struct ena_com_dev *ena_dev)
 	hash_ctrl->selected_fields[ENA_ADMIN_RSS_IP4_FRAG].fields =
 		ENA_ADMIN_RSS_L3_SA | ENA_ADMIN_RSS_L3_DA;
 
-	hash_ctrl->selected_fields[ENA_ADMIN_RSS_IP4_FRAG].fields =
+	hash_ctrl->selected_fields[ENA_ADMIN_RSS_NOT_IP].fields =
 		ENA_ADMIN_RSS_L2_DA | ENA_ADMIN_RSS_L2_SA;
 
 	for (i = 0; i < ENA_ADMIN_RSS_PROTO_NUM; i++) {
-- 
2.7.4
