From: "Hefty, Sean" <sean.hefty@intel.com>
Subject: [PATCH 12/26 v3] rdma/cm: Add support for AF_IB to
 cma_get_service_id
Date: Mon, 24 Sep 2012 23:55:32 +0000
Message-ID: <1828884A29C6694DAF28B7E6B8A8237346A8F0FA@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "linux-rdma (linux-rdma@vger.kernel.org)"
	<linux-rdma@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:7502 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751736Ab2IXXzf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 19:55:35 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

cma_get_service_id forms the service ID based on the port space
and port number of the rdma_cm_id.  Extend the call to support
AF_IB, which contains the service ID directly.  This will
be needed to support any arbitrary SID.

Signed-off-by: Sean Hefty <sean.hefty@intel.com>
---
resending with netdev copied

 drivers/infiniband/core/cma.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index cd4e197..4e205db 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -1374,6 +1374,9 @@ err1:
 
 static __be64 cma_get_service_id(enum rdma_port_space ps, struct sockaddr *addr)
 {
+	if (addr->sa_family == AF_IB)
+		return ((struct sockaddr_ib *) addr)->sib_sid;
+
 	return cpu_to_be64(((u64)ps << 16) + be16_to_cpu(cma_port(addr)));
 }
 
