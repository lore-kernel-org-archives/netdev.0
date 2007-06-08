From: "Ed L. Cashin" <ecashin@coraid.com>
Subject: [PATCH 1/1] make network DMA usable for non-tcp drivers
Date: Fri, 8 Jun 2007 10:30:53 -0400
Message-ID: <20070608143053.GC10489@coraid.com>
References: <20070605102427.26dd7fac.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: s.a.hopkins@gmail.com, jgarzik@pobox.com, randy.dunlap@oracle.com,
	akpm@linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1.coraid.com ([65.14.39.133]:7812 "EHLO coraid.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754837AbXFHOuU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jun 2007 10:50:20 -0400
Content-Disposition: inline
In-Reply-To: <20070605102427.26dd7fac.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Here is a patch against the netdev-2.6 git tree that makes the net DMA
feature usable for drivers like the ATA over Ethernet block driver,
which can use dma_skb_copy_datagram_iovec when receiving data from the
network.

The change was suggested on kernelnewbies.

  http://article.gmane.org/gmane.linux.kernel.kernelnewbies/21663

Signed-off-by: Ed L. Cashin <ecashin@coraid.com>
---
 drivers/dma/Kconfig |    2 +-
 net/core/user_dma.c |    2 ++
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/dma/Kconfig b/drivers/dma/Kconfig
index 72be6c6..270d23e 100644
--- a/drivers/dma/Kconfig
+++ b/drivers/dma/Kconfig
@@ -14,7 +14,7 @@ config DMA_ENGINE
 comment "DMA Clients"
 
 config NET_DMA
-	bool "Network: TCP receive copy offload"
+	bool "Network: receive copy offload"
 	depends on DMA_ENGINE && NET
 	default y
 	---help---
diff --git a/net/core/user_dma.c b/net/core/user_dma.c
index 0ad1cd5..69d0b15 100644
--- a/net/core/user_dma.c
+++ b/net/core/user_dma.c
@@ -130,3 +130,5 @@ end:
 fault:
 	return -EFAULT;
 }
+
+EXPORT_SYMBOL(dma_skb_copy_datagram_iovec);
-- 
1.5.2.1
