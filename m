From: Vasanthy Kolluri <vkolluri@cisco.com>
Subject: [net-next-2.6 PATCH] enic: Fix build warnings
Date: Mon, 15 Nov 2010 10:09:55 -0800
Message-ID: <20101115180955.5779.32244.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roprabhu@cisco.com, dwang2@cisco.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:49729 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756654Ab0KOSJ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Nov 2010 13:09:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasanthy Kolluri <vkolluri@cisco.com>

Fix data type of argument passed to pci_alloc_consistent and pci_free_consistent routines.

Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: David Wang <dwang2@cisco.com>
---
 drivers/net/enic/enic.h      |    2 +-
 drivers/net/enic/enic_main.c |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)


diff --git a/drivers/net/enic/enic.h b/drivers/net/enic/enic.h
index c91d364..7067254 100644
--- a/drivers/net/enic/enic.h
+++ b/drivers/net/enic/enic.h
@@ -32,7 +32,7 @@
 
 #define DRV_NAME		"enic"
 #define DRV_DESCRIPTION		"Cisco VIC Ethernet NIC Driver"
-#define DRV_VERSION		"1.4.1.6"
+#define DRV_VERSION		"1.4.1.7"
 #define DRV_COPYRIGHT		"Copyright 2008-2010 Cisco Systems, Inc"
 
 #define ENIC_BARS_MAX		6
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index a466ef9..9f293fa 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -2042,7 +2042,7 @@ static int enic_dev_hang_reset(struct enic *enic)
 
 static int enic_set_rsskey(struct enic *enic)
 {
-	u64 rss_key_buf_pa;
+	dma_addr_t rss_key_buf_pa;
 	union vnic_rss_key *rss_key_buf_va = NULL;
 	union vnic_rss_key rss_key = {
 		.key[0].b = {85, 67, 83, 97, 119, 101, 115, 111, 109, 101},
@@ -2073,7 +2073,7 @@ static int enic_set_rsskey(struct enic *enic)
 
 static int enic_set_rsscpu(struct enic *enic, u8 rss_hash_bits)
 {
-	u64 rss_cpu_buf_pa;
+	dma_addr_t rss_cpu_buf_pa;
 	union vnic_rss_cpu *rss_cpu_buf_va = NULL;
 	unsigned int i;
 	int err;

