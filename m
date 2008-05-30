From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH -next] cxgb3: fix build error when INET=n
Date: Fri, 30 May 2008 10:29:19 -0700
Message-ID: <20080530102919.ecd1fb27.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik <jgarzik@pobox.com>, linux-next@vger.kernel.org,
	akpm <akpm@linux-foundation.org>
To: netdev <netdev@vger.kernel.org>, divy@chelsio.com
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

cxgb3 uses lro_* functions and selects INET_LRO, but this doesn't help unless
INET is already enabled, so make the driver depend on INET also.

sge.c:(.text+0x9f09a): undefined reference to `lro_flush_all'
sge.c:(.text+0x9f62f): undefined reference to `lro_receive_skb'
sge.c:(.text+0x9f8a3): undefined reference to `lro_receive_frags'
sge.c:(.text+0x9fbe0): undefined reference to `lro_vlan_hwaccel_receive_skb'
sge.c:(.text+0x9ffcd): undefined reference to `lro_vlan_hwaccel_receive_frags'

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 drivers/net/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-next-20080530.orig/drivers/net/Kconfig
+++ linux-next-20080530/drivers/net/Kconfig
@@ -2407,7 +2407,7 @@ config CHELSIO_T1_NAPI
 
 config CHELSIO_T3
 	tristate "Chelsio Communications T3 10Gb Ethernet support"
-	depends on PCI
+	depends on PCI && INET
 	select FW_LOADER
 	select INET_LRO
 	help
