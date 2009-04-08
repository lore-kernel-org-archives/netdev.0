From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH -next] ethoc: fix library build errors
Date: Wed, 8 Apr 2009 10:00:39 -0700
Message-ID: <20090408100039.855ab138.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Thierry Reding <thierry.reding@avionic-design.de>,
	davem@davemloft.net
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:20052 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754259AbZDHRAh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2009 13:00:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

ethoc indirectly uses crc32_le() and bitrev32(), so select
those library functions to be built.

drivers/built-in.o: In function `ethoc_set_multicast_list':
ethoc.c:(.text+0x6226f): undefined reference to `crc32_le'
ethoc.c:(.text+0x62276): undefined reference to `bitrev32'

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
cc: Thierry Reding <thierry.reding@avionic-design.de>
---
 drivers/net/Kconfig |    2 ++
 1 file changed, 2 insertions(+)

--- linux-next-20090408.orig/drivers/net/Kconfig
+++ linux-next-20090408/drivers/net/Kconfig
@@ -977,6 +977,8 @@ config ETHOC
 	depends on NET_ETHERNET && HAS_IOMEM
 	select MII
 	select PHYLIB
+	select CRC32
+	select BITREVERSE
 	help
 	  Say Y here if you want to use the OpenCores 10/100 Mbps Ethernet MAC.
 
