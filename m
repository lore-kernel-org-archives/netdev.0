From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH] cnic: Fix NETDEV_UP event processing.
Date: Thu, 1 Oct 2009 23:17:34 -0700
Message-ID: <1254464254-32005-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, michaelc@cs.wisc.edu,
	"Michael Chan" <mchan@broadcom.com>,
	"Benjamin Li" <benli@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2254 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756731AbZJBGJU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Oct 2009 02:09:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes the problem of not handling the NETDEV_UP event properly
during hot-plug or modprobe of bnx2 after cnic.  The handling was
skipped by mistakenly using "else if" to check for the event.

Also update version to 2.0.1.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/cnic.c    |    3 ++-
 drivers/net/cnic_if.h |    4 ++--
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 211c8e9..46c87ec 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -2733,7 +2733,8 @@ static int cnic_netdev_event(struct notifier_block *this, unsigned long event,
 			cnic_ulp_init(dev);
 		else if (event == NETDEV_UNREGISTER)
 			cnic_ulp_exit(dev);
-		else if (event == NETDEV_UP) {
+
+		if (event == NETDEV_UP) {
 			if (cnic_register_netdev(dev) != 0) {
 				cnic_put(dev);
 				goto done;
diff --git a/drivers/net/cnic_if.h b/drivers/net/cnic_if.h
index a492357..d8b09ef 100644
--- a/drivers/net/cnic_if.h
+++ b/drivers/net/cnic_if.h
@@ -12,8 +12,8 @@
 #ifndef CNIC_IF_H
 #define CNIC_IF_H
 
-#define CNIC_MODULE_VERSION	"2.0.0"
-#define CNIC_MODULE_RELDATE	"May 21, 2009"
+#define CNIC_MODULE_VERSION	"2.0.1"
+#define CNIC_MODULE_RELDATE	"Oct 01, 2009"
 
 #define CNIC_ULP_RDMA		0
 #define CNIC_ULP_ISCSI		1
-- 
1.6.4.GIT


