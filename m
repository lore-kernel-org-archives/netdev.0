From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] net/smc: mark as BROKEN due to remote memory exposure
Date: Wed, 10 May 2017 09:26:27 +0200
Message-ID: <20170510072627.12060-1-hch@lst.de>
Cc: ubraun@linux.vnet.ibm.com, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, stable@vger.kernel.org
To: davem@davemloft.net
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The driver has a lot of quality issues due to the lack of RDMA-side
review, and explicitly bypasses APIs to register all memory once a
connection is made, and thus allows remote access to memoery.

Mark it as broken until at least that part is fixed.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Cc: stable@vger.kernel.org

---
 net/smc/Kconfig | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/smc/Kconfig b/net/smc/Kconfig
index c717ef0896aa..fe6b78bc515f 100644
--- a/net/smc/Kconfig
+++ b/net/smc/Kconfig
@@ -1,6 +1,6 @@
 config SMC
 	tristate "SMC socket protocol family"
-	depends on INET && INFINIBAND
+	depends on INET && INFINIBAND && BROKEN
 	---help---
 	  SMC-R provides a "sockets over RDMA" solution making use of
 	  RDMA over Converged Ethernet (RoCE) technology to upgrade
@@ -8,6 +8,10 @@ config SMC
 	  The Linux implementation of the SMC-R solution is designed as
 	  a separate socket family SMC.
 
+	  Warning: SMC will expose all memory for remote reads and writes
+	  once a connection is established.  Don't enable this option except
+	  for tightly controlled lab environment.
+
 	  Select this option if you want to run SMC socket applications
 
 config SMC_DIAG
-- 
2.11.0
