From: Leon Romanovsky <leon@kernel.org>
Subject: [PATCH net v1] net/smc: Add warning about remote memory exposure
Date: Tue, 16 May 2017 09:51:38 +0300
Message-ID: <20170516065138.24789-1-leon@kernel.org>
Cc: ubraun@linux.vnet.ibm.com, netdev@vger.kernel.org,
        iinux-rdma@vger.kernel.org, Christoph Hellwig <hch@lst.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:34996 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750759AbdEPGvm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 16 May 2017 02:51:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Hellwig <hch@lst.de>

The driver explicitly bypasses APIs to register all memory once a
connection is made, and thus allows remote access to memory.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Leon Romanovsky <leon@kernel.org>
---
Dave,
Can you please forward this patch to stable?
Thanks
---
 Changes from v0:
  * Remove BROKEN Kconfig option as a followup of this discussion
    https://patchwork.ozlabs.org/patch/760454/
  * Refine commit message
---
 net/smc/Kconfig | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/smc/Kconfig b/net/smc/Kconfig
index c717ef0896aa..33954852f3f8 100644
--- a/net/smc/Kconfig
+++ b/net/smc/Kconfig
@@ -8,6 +8,10 @@ config SMC
 	  The Linux implementation of the SMC-R solution is designed as
 	  a separate socket family SMC.

+	  Warning: SMC will expose all memory for remote reads and writes
+	  once a connection is established.  Don't enable this option except
+	  for tightly controlled lab environment.
+
 	  Select this option if you want to run SMC socket applications

 config SMC_DIAG
