From: Netanel Belgazal <netanel@annapurnalabs.com>
Subject: [PATCH net 06/18] net/ena: fix ethtool RSS flow configuration
Date: Sun, 20 Nov 2016 10:45:35 +0200
Message-ID: <1479631547-29354-7-git-send-email-netanel@annapurnalabs.com>
References: <1479631547-29354-1-git-send-email-netanel@annapurnalabs.com>
Cc: Netanel Belgazal <netanel@annapurnalabs.com>, dwmw@amazon.com,
        zorik@annapurnalabs.com, alex@annapurnalabs.com,
        saeed@annapurnalabs.com, msw@amazon.com, aliguori@amazon.com,
        nafea@annapurnalabs.com
To: linux-kernel@vger.kernel.org, davem@davemloft.net,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:36954 "EHLO
        mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753343AbcKTIqL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 20 Nov 2016 03:46:11 -0500
Received: by mail-wm0-f53.google.com with SMTP id t79so98339917wmt.0
        for <netdev@vger.kernel.org>; Sun, 20 Nov 2016 00:46:11 -0800 (PST)
In-Reply-To: <1479631547-29354-1-git-send-email-netanel@annapurnalabs.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ena_flow_data_to_flow_hash and ena_flow_hash_to_flow_type
treat the ena_flow_hash_to_flow_type enum as power of two values.

Change the values of ena_admin_flow_hash_fields to be power of two values.

Signed-off-by: Netanel Belgazal <netanel@annapurnalabs.com>
---
 drivers/net/ethernet/amazon/ena/ena_admin_defs.h | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/amazon/ena/ena_admin_defs.h b/drivers/net/ethernet/amazon/ena/ena_admin_defs.h
index 51b2a92..c78f0b2 100644
--- a/drivers/net/ethernet/amazon/ena/ena_admin_defs.h
+++ b/drivers/net/ethernet/amazon/ena/ena_admin_defs.h
@@ -633,22 +633,22 @@ enum ena_admin_flow_hash_proto {
 /* RSS flow hash fields */
 enum ena_admin_flow_hash_fields {
 	/* Ethernet Dest Addr */
-	ENA_ADMIN_RSS_L2_DA	= 0,
+	ENA_ADMIN_RSS_L2_DA	= 0x1,
 
 	/* Ethernet Src Addr */
-	ENA_ADMIN_RSS_L2_SA	= 1,
+	ENA_ADMIN_RSS_L2_SA	= 0x2,
 
 	/* ipv4/6 Dest Addr */
-	ENA_ADMIN_RSS_L3_DA	= 2,
+	ENA_ADMIN_RSS_L3_DA	= 0x4,
 
 	/* ipv4/6 Src Addr */
-	ENA_ADMIN_RSS_L3_SA	= 5,
+	ENA_ADMIN_RSS_L3_SA	= 0x8,
 
 	/* tcp/udp Dest Port */
-	ENA_ADMIN_RSS_L4_DP	= 6,
+	ENA_ADMIN_RSS_L4_DP	= 0x10,
 
 	/* tcp/udp Src Port */
-	ENA_ADMIN_RSS_L4_SP	= 7,
+	ENA_ADMIN_RSS_L4_SP	= 0x20,
 };
 
 struct ena_admin_proto_input {
-- 
1.9.1
