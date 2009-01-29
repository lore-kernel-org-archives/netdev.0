From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH] netxen: revert jumbo ringsize
Date: Thu, 29 Jan 2009 12:30:28 -0800
Message-ID: <1233261028-27584-1-git-send-email-dhananjay@netxen.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:58750 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752269AbZA2Uaa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jan 2009 15:30:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reducing jumbo ring size below 1024 reduces throughput for old
firmwares (3.4.216 and older) running on older (NX2031) chip,
so restore it back to 1024.

This was reduced in commit 32ec803348b4d5f1353e1d7feae30880b8b3e342.

Raising jumbo ring size from 512 to 1024, adds ~4MB per port, but
there's still big saving because of original patch (~20MB per port).

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index a75a310..9c78c96 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -210,7 +210,7 @@
 #define MAX_CMD_DESCRIPTORS_HOST	1024
 #define MAX_RCV_DESCRIPTORS_1G		2048
 #define MAX_RCV_DESCRIPTORS_10G		4096
-#define MAX_JUMBO_RCV_DESCRIPTORS	512
+#define MAX_JUMBO_RCV_DESCRIPTORS	1024
 #define MAX_LRO_RCV_DESCRIPTORS		8
 #define MAX_RCVSTATUS_DESCRIPTORS	MAX_RCV_DESCRIPTORS
 #define MAX_JUMBO_RCV_DESC	MAX_JUMBO_RCV_DESCRIPTORS
-- 
1.6.0.2

