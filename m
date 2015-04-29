From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: [PATCH net-next v3 1/4] ibmveth: change rx buffer default allocation for CMO
Date: Wed, 29 Apr 2015 16:25:44 -0500
Message-ID: <1430342747-16774-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, nfont@linux.vnet.ibm.com,
	eric.dumazet@gmail.com, Brian King <brking@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:47867 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750857AbbD2VZy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 17:25:54 -0400
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
	Wed, 29 Apr 2015 15:25:54 -0600
Received: from b03cxnp08028.gho.boulder.ibm.com (b03cxnp08028.gho.boulder.ibm.com [9.17.130.20])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id A728D19D8041
	for <netdev@vger.kernel.org>; Wed, 29 Apr 2015 15:16:54 -0600 (MDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by b03cxnp08028.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t3TLPTIs34930850
	for <netdev@vger.kernel.org>; Wed, 29 Apr 2015 14:25:29 -0700
Received: from d03av01.boulder.ibm.com (localhost [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t3TLPnKf021477
	for <netdev@vger.kernel.org>; Wed, 29 Apr 2015 15:25:50 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables 64k rx buffer pools by default.  If Cooperative
Memory Overcommitment (CMO) is enabled, the number of 64k buffers
is reduced to save memory.

Cc: Brian King <brking@linux.vnet.ibm.com>
Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ibmveth.c | 3 +++
 drivers/net/ethernet/ibm/ibmveth.h | 3 ++-
 2 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ibm/ibmveth.c b/drivers/net/ethernet/ibm/ibmveth.c
index cd7675a..0210622 100644
--- a/drivers/net/ethernet/ibm/ibmveth.c
+++ b/drivers/net/ethernet/ibm/ibmveth.c
@@ -1424,6 +1424,9 @@ static int ibmveth_probe(struct vio_dev *dev, const struct vio_device_id *id)
 
 	memcpy(netdev->dev_addr, mac_addr_p, ETH_ALEN);
 
+	if (firmware_has_feature(FW_FEATURE_CMO))
+		memcpy(pool_count, pool_count_cmo, sizeof(pool_count));
+
 	for (i = 0; i < IBMVETH_NUM_BUFF_POOLS; i++) {
 		struct kobject *kobj = &adapter->rx_buff_pool[i].kobj;
 		int error;
diff --git a/drivers/net/ethernet/ibm/ibmveth.h b/drivers/net/ethernet/ibm/ibmveth.h
index 1f37499..0dc664b 100644
--- a/drivers/net/ethernet/ibm/ibmveth.h
+++ b/drivers/net/ethernet/ibm/ibmveth.h
@@ -104,7 +104,8 @@ static inline long h_illan_attributes(unsigned long unit_address,
 
 static int pool_size[] = { 512, 1024 * 2, 1024 * 16, 1024 * 32, 1024 * 64 };
 static int pool_count[] = { 256, 512, 256, 256, 256 };
-static int pool_active[] = { 1, 1, 0, 0, 0};
+static int pool_count_cmo[] = { 256, 512, 256, 256, 64 };
+static int pool_active[] = { 1, 1, 0, 0, 1};
 
 #define IBM_VETH_INVALID_MAP ((u16)0xffff)
 
-- 
1.9.3
