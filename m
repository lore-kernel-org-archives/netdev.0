From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2/2 net-next] cnic: Update VLAN ID during
 ISCSI_UEVENT_PATH_UPDATE
Date: Wed, 8 Feb 2012 19:33:57 -0800
Message-ID: <1328758437-18306-2-git-send-email-mchan@broadcom.com>
References: <1328758437-18306-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1816 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757753Ab2BID0n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Feb 2012 22:26:43 -0500
In-Reply-To: <1328758437-18306-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eddie Wai <eddie.wai@broadcom.com>

This will support the new VLAN attribute in the iSCSI iface file.

Signed-off-by: Eddie Wai <eddie.wai@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/cnic.c    |    2 ++
 drivers/net/ethernet/broadcom/cnic_if.h |    4 ++--
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index e236560..df42995 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -380,6 +380,8 @@ static int cnic_iscsi_nl_msg_recv(struct cnic_dev *dev, u32 msg_type,
 		if (cnic_in_use(csk) &&
 		    test_bit(SK_F_CONNECT_START, &csk->flags)) {
 
+			csk->vlan_id = path_resp->vlan_id;
+
 			memcpy(csk->ha, path_resp->mac_addr, 6);
 			if (test_bit(SK_F_IPV6, &csk->flags))
 				memcpy(&csk->src_ip[0], &path_resp->src.v6_addr,
diff --git a/drivers/net/ethernet/broadcom/cnic_if.h b/drivers/net/ethernet/broadcom/cnic_if.h
index 1517763..60deb84 100644
--- a/drivers/net/ethernet/broadcom/cnic_if.h
+++ b/drivers/net/ethernet/broadcom/cnic_if.h
@@ -12,8 +12,8 @@
 #ifndef CNIC_IF_H
 #define CNIC_IF_H
 
-#define CNIC_MODULE_VERSION	"2.5.8"
-#define CNIC_MODULE_RELDATE	"Jan 3, 2012"
+#define CNIC_MODULE_VERSION	"2.5.9"
+#define CNIC_MODULE_RELDATE	"Feb 8, 2012"
 
 #define CNIC_ULP_RDMA		0
 #define CNIC_ULP_ISCSI		1
-- 
1.6.4.GIT
