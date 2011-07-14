From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 4/6] cnic: Return proper error code if we fail
 to send netlink message
Date: Wed, 13 Jul 2011 20:24:20 -0700
Message-ID: <1310613862-27497-4-git-send-email-mchan@broadcom.com>
References: <1310613862-27497-1-git-send-email-mchan@broadcom.com>
 <1310613862-27497-2-git-send-email-mchan@broadcom.com>
 <1310613862-27497-3-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2711 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750873Ab1GNEQs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jul 2011 00:16:48 -0400
In-Reply-To: <1310613862-27497-3-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

to allow iSCSI connection to fail faster instead of waiting for the
long timeout.

Update version to 2.5.6.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/cnic.c    |    2 +-
 drivers/net/cnic_if.h |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index bdfe155..ea75f65 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -328,7 +328,7 @@ static int cnic_send_nlmsg(struct cnic_local *cp, u32 type,
 		msleep(100);
 		retry++;
 	}
-	return 0;
+	return rc;
 }
 
 static void cnic_cm_upcall(struct cnic_local *, struct cnic_sock *, u8);
diff --git a/drivers/net/cnic_if.h b/drivers/net/cnic_if.h
index bc7000a..642b9d5 100644
--- a/drivers/net/cnic_if.h
+++ b/drivers/net/cnic_if.h
@@ -12,8 +12,8 @@
 #ifndef CNIC_IF_H
 #define CNIC_IF_H
 
-#define CNIC_MODULE_VERSION	"2.5.3"
-#define CNIC_MODULE_RELDATE	"June 6, 2011"
+#define CNIC_MODULE_VERSION	"2.5.6"
+#define CNIC_MODULE_RELDATE	"July 12, 2011"
 
 #define CNIC_ULP_RDMA		0
 #define CNIC_ULP_ISCSI		1
-- 
1.6.4.GIT


