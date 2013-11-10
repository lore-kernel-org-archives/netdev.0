From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next FIX] RDMA/cma: Fix build breakage when infiniband is built-in
Date: Sun, 10 Nov 2013 15:28:00 +0200
Message-ID: <1384090080-1862-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com,
	Eyal Perry <eyalpe@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:50197 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751326Ab3KJN2I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Nov 2013 08:28:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eyal Perry <eyalpe@mellanox.com>

Commit eb072c4 ("RDMA/cma: Set IBoE SL (user-priority) by egress map when using
vlans"), broke the build when CONFIG_VLAN_8021Q=m and CONFIG_INFINIBAND=y,
because the rdma_cm module attempted to call vlan_dev_get_egress_qos_mask()
which in that case is a modular code being called from built-in kernel code.

Fix this by adding a Kconfig dependency to prevent the rdma_cm code from being
built in when 8021Q is built modular, in a similar manner we do with IPv6.

Signed-off-by: Eyal Perry <eyalpe@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---

Dave, this fixes an issue with the mentioned commit which is in net-next

 drivers/infiniband/Kconfig |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/infiniband/Kconfig b/drivers/infiniband/Kconfig
index b84791f..079dfe4 100644
--- a/drivers/infiniband/Kconfig
+++ b/drivers/infiniband/Kconfig
@@ -51,6 +51,7 @@ config INFINIBAND_ADDR_TRANS
 	bool
 	depends on INET
 	depends on !(INFINIBAND = y && IPV6 = m)
+	depends on !(INFINIBAND = y && VLAN_8021Q = m)
 	default y
 
 source "drivers/infiniband/hw/mthca/Kconfig"
-- 
1.7.1
