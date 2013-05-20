From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: [PATCH 1/4] e1000e: Remove duplicate assignment of default rx/tx ring size
Date: Mon, 20 May 2013 16:15:04 +0800
Message-ID: <1369037707-27026-2-git-send-email-weiyang@linux.vnet.ibm.com>
References: <1369037707-27026-1-git-send-email-weiyang@linux.vnet.ibm.com>
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Wei Yang <weiyang@linux.vnet.ibm.com>
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp07.in.ibm.com ([122.248.162.7]:55706 "EHLO
	e28smtp07.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755278Ab3ETIPZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 May 2013 04:15:25 -0400
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <weiyang@linux.vnet.ibm.com>;
	Mon, 20 May 2013 13:39:31 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 6D6673940058
	for <netdev@vger.kernel.org>; Mon, 20 May 2013 13:45:21 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4K8FFh611731264
	for <netdev@vger.kernel.org>; Mon, 20 May 2013 13:45:15 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4K8FHqJ012247
	for <netdev@vger.kernel.org>; Mon, 20 May 2013 08:15:20 GMT
In-Reply-To: <1369037707-27026-1-git-send-email-weiyang@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tx_ring/rx_ring size is assigned in function e1000_alloc_queues(), which is
called by e1000_sw_init() in the early stage of e1000_probe().

This patch just remove the duplicate assignment of this default ring size
value.

Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
Reviewed-by: Gavin Shan <shangw@linux.vnet.ibm.com>
Reviewed-by: Da Yu Qiu <qiudayu@cn.ibm.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 7e615e2..5cb8321 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -6707,10 +6707,6 @@ static int e1000_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	adapter->hw.fc.current_mode = e1000_fc_default;
 	adapter->hw.phy.autoneg_advertised = 0x2f;
 
-	/* ring size defaults */
-	adapter->rx_ring->count = E1000_DEFAULT_RXD;
-	adapter->tx_ring->count = E1000_DEFAULT_TXD;
-
 	/* Initial Wake on LAN setting - If APM wake is enabled in
 	 * the EEPROM, enable the ACPI Magic Packet filter
 	 */
-- 
1.7.5.4
