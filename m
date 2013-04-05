From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH net-next 1/4] netxen_nic: Fix mismatched board type error
Date: Fri,  5 Apr 2013 08:36:40 -0400
Message-ID: <1365165403-18348-2-git-send-email-manish.chopra@qlogic.com>
References: <1365165403-18348-1-git-send-email-manish.chopra@qlogic.com>
Cc: netdev@vger.kernel.org, rajesh.borundia@qlogic.com,
	Dept_NX_Linux_NIC_Driver@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:17625 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1161622Ab3DEM76 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Apr 2013 08:59:58 -0400
In-Reply-To: <1365165403-18348-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o Display unknown board name and serial number
  in case of mismatched board type

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
---
 drivers/net/ethernet/qlogic/netxen/netxen_nic.h    |   10 +++++++---
 .../net/ethernet/qlogic/netxen/netxen_nic_main.c   |    4 +++-
 2 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic.h b/drivers/net/ethernet/qlogic/netxen/netxen_nic.h
index 322a36b..e5ab1ec 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic.h
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic.h
@@ -1855,7 +1855,7 @@ static const struct netxen_brdinfo netxen_boards[] = {
 
 #define NUM_SUPPORTED_BOARDS ARRAY_SIZE(netxen_boards)
 
-static inline void get_brd_name_by_type(u32 type, char *name)
+static inline int netxen_nic_get_brd_name_by_type(u32 type, char *name)
 {
 	int i, found = 0;
 	for (i = 0; i < NUM_SUPPORTED_BOARDS; ++i) {
@@ -1864,10 +1864,14 @@ static inline void get_brd_name_by_type(u32 type, char *name)
 			found = 1;
 			break;
 		}
+	}
 
+	if (!found) {
+		strcpy(name, "Unknown");
+		return -EINVAL;
 	}
-	if (!found)
-		name = "Unknown";
+
+	return 0;
 }
 
 static inline u32 netxen_tx_avail(struct nx_host_tx_ring *tx_ring)
diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
index 7867aeb..6049637 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
@@ -841,7 +841,9 @@ netxen_check_options(struct netxen_adapter *adapter)
 	}
 
 	if (adapter->portnum == 0) {
-		get_brd_name_by_type(adapter->ahw.board_type, brd_name);
+		if (netxen_nic_get_brd_name_by_type(adapter->ahw.board_type,
+						    brd_name))
+			strcpy(serial_num, "Unknown");
 
 		pr_info("%s: %s Board S/N %s  Chip rev 0x%x\n",
 				module_name(THIS_MODULE),
-- 
1.5.6
