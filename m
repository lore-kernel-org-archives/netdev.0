From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 05/15] mlxsw: pci: Remove MLXSW_PCI_RDQS/SDQS defines and checks
Date: Thu, 15 Oct 2015 17:43:19 +0200
Message-ID: <1444923809-20785-6-git-send-email-jiri@resnulli.us>
References: <1444923809-20785-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f181.google.com ([209.85.220.181]:32960 "EHLO
	mail-qk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753593AbbJOPni (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 11:43:38 -0400
Received: by qkas79 with SMTP id s79so40755817qka.0
        for <netdev@vger.kernel.org>; Thu, 15 Oct 2015 08:43:37 -0700 (PDT)
In-Reply-To: <1444923809-20785-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Remove strict number check of queues count as various ASICs have
different counts.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/pci.c | 3 +--
 drivers/net/ethernet/mellanox/mlxsw/pci.h | 2 --
 2 files changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/pci.c b/drivers/net/ethernet/mellanox/mlxsw/pci.c
index 946341e..870d443 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/pci.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/pci.c
@@ -1069,8 +1069,7 @@ static int mlxsw_pci_aqs_init(struct mlxsw_pci *mlxsw_pci, char *mbox)
 	num_eqs = mlxsw_cmd_mbox_query_aq_cap_max_num_eqs_get(mbox);
 	eq_log2sz = mlxsw_cmd_mbox_query_aq_cap_log_max_eq_sz_get(mbox);
 
-	if ((num_sdqs != MLXSW_PCI_SDQS_COUNT) ||
-	    (num_rdqs != MLXSW_PCI_RDQS_COUNT) ||
+	if (num_sdqs + num_rdqs > num_cqs ||
 	    num_cqs > MLXSW_PCI_CQS_MAX || num_eqs != MLXSW_PCI_EQS_COUNT) {
 		dev_err(&pdev->dev, "Unsupported number of queues\n");
 		return -EINVAL;
diff --git a/drivers/net/ethernet/mellanox/mlxsw/pci.h b/drivers/net/ethernet/mellanox/mlxsw/pci.h
index efe1b4b..5b3453b 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/pci.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/pci.h
@@ -71,8 +71,6 @@
 #define MLXSW_PCI_DOORBELL(offset, type_offset, num)	\
 	((offset) + (type_offset) + (num) * 4)
 
-#define MLXSW_PCI_RDQS_COUNT	24
-#define MLXSW_PCI_SDQS_COUNT	24
 #define MLXSW_PCI_CQS_MAX	96
 #define MLXSW_PCI_EQS_COUNT	2
 #define MLXSW_PCI_EQ_ASYNC_NUM	0
-- 
1.9.3
