From: Ramkrishna Vepa <ram.vepa@neterion.com>
Subject: [PATCH 2.6.24 1/2]S2io: Change kmalloc+memset to k[zc]alloc
Date: 15 Aug 2007 17:13:24 -0700
Message-ID: <1187223204.23940.343.camel@flash>
Reply-To: ram.vepa@neterion.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, support@neterion.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:49074 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752122AbXHOWV4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Aug 2007 18:21:56 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

- Changed kmalloc+memset to k[zc]alloc as per Mariusz's patch
  <m.kozlowski@tuxland.pl>

Signed-off-by: Sivakumar Subramani <sivakumar.subramani@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -urpN org/drivers/net/s2io.c patch1/drivers/net/s2io.c
--- org/drivers/net/s2io.c	2007-08-09 17:28:19.000000000 +0530
+++ patch1/drivers/net/s2io.c	2007-08-10 11:53:46.000000000 +0530
@@ -556,7 +556,7 @@ static int init_shared_mem(struct s2io_n
 	for (i = 0; i < config->tx_fifo_num; i++) {
 		int fifo_len = config->tx_cfg[i].fifo_len;
 		int list_holder_size = fifo_len * sizeof(struct list_info_hold);
-		mac_control->fifos[i].list_info = kmalloc(list_holder_size,
+		mac_control->fifos[i].list_info = kzalloc(list_holder_size,
 							  GFP_KERNEL);
 		if (!mac_control->fifos[i].list_info) {
 			DBG_PRINT(INFO_DBG,
@@ -564,7 +564,6 @@ static int init_shared_mem(struct s2io_n
 			return -ENOMEM;
 		}
 		mem_allocated += list_holder_size;
-		memset(mac_control->fifos[i].list_info, 0, list_holder_size);
 	}
 	for (i = 0; i < config->tx_fifo_num; i++) {
 		int page_num = TXD_MEM_PAGE_CNT(config->tx_cfg[i].fifo_len,
@@ -3883,9 +3882,9 @@ static int s2io_enable_msi_x(struct s2io
 	u16 msi_control; /* Temp variable */
 	int ret, i, j, msix_indx = 1;
 
-	nic->entries = kmalloc(MAX_REQUESTED_MSI_X * sizeof(struct msix_entry),
+	nic->entries = kcalloc(MAX_REQUESTED_MSI_X, sizeof(struct msix_entry),
 			       GFP_KERNEL);
-	if (nic->entries == NULL) {
+	if (!nic->entries) {
 		DBG_PRINT(INFO_DBG, "%s: Memory allocation failed\n", \
 			__FUNCTION__);
 		nic->mac_control.stats_info->sw_stat.mem_alloc_fail_cnt++;
@@ -3893,12 +3892,11 @@ static int s2io_enable_msi_x(struct s2io
 	}
 	nic->mac_control.stats_info->sw_stat.mem_allocated 
 		+= (MAX_REQUESTED_MSI_X * sizeof(struct msix_entry));
-	memset(nic->entries, 0,MAX_REQUESTED_MSI_X * sizeof(struct msix_entry));
 
 	nic->s2io_entries =
-		kmalloc(MAX_REQUESTED_MSI_X * sizeof(struct s2io_msix_entry),
+		kcalloc(MAX_REQUESTED_MSI_X, sizeof(struct s2io_msix_entry),
 				   GFP_KERNEL);
-	if (nic->s2io_entries == NULL) {
+	if (!nic->s2io_entries) {
 		DBG_PRINT(INFO_DBG, "%s: Memory allocation failed\n", 
 			__FUNCTION__);
 		nic->mac_control.stats_info->sw_stat.mem_alloc_fail_cnt++;
@@ -3909,8 +3907,6 @@ static int s2io_enable_msi_x(struct s2io
 	}
 	 nic->mac_control.stats_info->sw_stat.mem_allocated 
 		+= (MAX_REQUESTED_MSI_X * sizeof(struct s2io_msix_entry));
-	memset(nic->s2io_entries, 0,
-	       MAX_REQUESTED_MSI_X * sizeof(struct s2io_msix_entry));
 
 	for (i=0; i< MAX_REQUESTED_MSI_X; i++) {
 		nic->entries[i].entry = i;



