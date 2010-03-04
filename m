From: leitao@linux.vnet.ibm.com
Subject: [PATCH] s2io: Fixing debug message
Date: Thu,  4 Mar 2010 15:40:44 -0500
Message-ID: <1267735244-8367-1-git-send-email-leitao@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, Breno Leitao <leitao@linux.vnet.ibm.com>
To: sreenivasa.honnur@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp02.br.ibm.com ([32.104.18.86]:54607 "EHLO
	e24smtp02.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756453Ab0CDUrF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Mar 2010 15:47:05 -0500
Received: from d24relay01.br.ibm.com (d24relay01.br.ibm.com [9.8.31.16])
	by e24smtp02.br.ibm.com (8.14.3/8.13.1) with ESMTP id o24L1Rx1026820
	for <netdev@vger.kernel.org>; Thu, 4 Mar 2010 18:01:27 -0300
Received: from d24av05.br.ibm.com (d24av05.br.ibm.com [9.18.232.44])
	by d24relay01.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o24Kku3q3649584
	for <netdev@vger.kernel.org>; Thu, 4 Mar 2010 17:46:56 -0300
Received: from d24av05.br.ibm.com (loopback [127.0.0.1])
	by d24av05.br.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o24KktKs017031
	for <netdev@vger.kernel.org>; Thu, 4 Mar 2010 17:46:55 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently s2io is dumping debug messages using the interface name
before it was allocated, showing a message like the following:

s2io: eth%d: Ring Mem PHY: 0x7ef80000
s2io: s2io_reset: Resetting XFrame card eth%d

This patch just fixes it, printing the pci bus information for
the card instead of the interface name.

Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>
---
 drivers/net/s2io.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 3c4836d..2a913be 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -923,8 +923,8 @@ static int init_shared_mem(struct s2io_nic *nic)
 	tmp_v_addr = mac_control->stats_mem;
 	mac_control->stats_info = (struct stat_block *)tmp_v_addr;
 	memset(tmp_v_addr, 0, size);
-	DBG_PRINT(INIT_DBG, "%s: Ring Mem PHY: 0x%llx\n", dev->name,
-		  (unsigned long long)tmp_p_addr);
+	DBG_PRINT(INIT_DBG, "%s: Ring Mem PHY: 0x%llx\n",
+		dev_name(&nic->pdev->dev), (unsigned long long)tmp_p_addr);
 	mac_control->stats_info->sw_stat.mem_allocated += mem_allocated;
 	return SUCCESS;
 }
@@ -3480,7 +3480,7 @@ static void s2io_reset(struct s2io_nic *sp)
 	struct swStat *swstats;
 
 	DBG_PRINT(INIT_DBG, "%s: Resetting XFrame card %s\n",
-		  __func__, sp->dev->name);
+		  __func__, pci_name(sp->pdev));
 
 	/* Back up  the PCI-X CMD reg, dont want to lose MMRBC, OST settings */
 	pci_read_config_word(sp->pdev, PCIX_COMMAND_REGISTER, &(pci_cmd));
-- 
1.6.0.2

