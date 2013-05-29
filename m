From: sean.hefty@intel.com
Subject: [PATCH v5 13/28] rdma/cm: Add support for AF_IB to cma_get_service_id
Date: Wed, 29 May 2013 10:09:19 -0700
Message-ID: <1369847374-12176-14-git-send-email-sean.hefty@intel.com>
References: <1369847374-12176-1-git-send-email-sean.hefty@intel.com>
Cc: Sean Hefty <sean.hefty@intel.com>
To: roland@purestorage.com, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:6764 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759598Ab3E2RJv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 May 2013 13:09:51 -0400
In-Reply-To: <1369847374-12176-1-git-send-email-sean.hefty@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sean Hefty <sean.hefty@intel.com>

cma_get_service_id forms the service ID based on the port space
and port number of the rdma_cm_id.  Extend the call to support
AF_IB, which contains the service ID directly.  This will
be needed to support any arbitrary SID.

Signed-off-by: Sean Hefty <sean.hefty@intel.com>
---
 drivers/infiniband/core/cma.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index f54169b..d307c94 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -1379,6 +1379,9 @@ err1:
 
 static __be64 cma_get_service_id(enum rdma_port_space ps, struct sockaddr *addr)
 {
+	if (addr->sa_family == AF_IB)
+		return ((struct sockaddr_ib *) addr)->sib_sid;
+
 	return cpu_to_be64(((u64)ps << 16) + be16_to_cpu(cma_port(addr)));
 }
 
-- 
1.7.3
