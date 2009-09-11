From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH 3/5] netxen: fix file firmware leak
Date: Fri, 11 Sep 2009 14:28:13 -0700
Message-ID: <1252704495-16118-4-git-send-email-dhananjay@netxen.com>
References: <1252704495-16118-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:43923 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1756915AbZIKV2N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Sep 2009 17:28:13 -0400
In-Reply-To: <1252704495-16118-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Release file firmware when no firmware reset is required.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_main.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index c6f32e5..4668a72 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -817,7 +817,7 @@ netxen_start_firmware(struct netxen_adapter *adapter)
 	if (err < 0)
 		goto err_out;
 	if (err == 0)
-		goto wait_init;
+		goto ready;
 
 	if (first_boot != 0x55555555) {
 		NXWR32(adapter, CRB_CMDPEG_STATE, 0);
@@ -860,6 +860,7 @@ netxen_start_firmware(struct netxen_adapter *adapter)
 		| (_NETXEN_NIC_LINUX_SUBVERSION);
 	NXWR32(adapter, CRB_DRIVER_VERSION, val);
 
+ready:
 	NXWR32(adapter, NX_CRB_DEV_STATE, NX_DEV_READY);
 
 wait_init:
@@ -874,7 +875,7 @@ wait_init:
 
 	netxen_check_options(adapter);
 
-	return 0;
+	/* fall through and release firmware */
 
 err_out:
 	netxen_release_firmware(adapter);
-- 
1.6.0.2

