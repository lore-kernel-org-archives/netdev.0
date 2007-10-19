From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] [Bug 9187] ir-functions.c:(.text+0xbce18): undefined reference
 to `input_event'
Date: Thu, 18 Oct 2007 21:53:50 -0700
Message-ID: <4718385E.7050105@oracle.com>
References: <20071019035702.B5C7E108010@picon.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: bugme-daemon@bugzilla.kernel.org, NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:54303 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753132AbXJSEyG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2007 00:54:06 -0400
In-Reply-To: <20071019035702.B5C7E108010@picon.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[bugme-daemon@bugzilla.kernel.org wrote:]



From: Randy Dunlap <randy.dunlap@oracle.com>

Drivers that use lro functions should depend on INET, otherwise they
may not link correctly.  Let's not select INET.  Select should be used
only for library-like code, not to enable subsystems.

ERROR: "lro_flush_all" [drivers/net/myri10ge/myri10ge.ko] undefined!
ERROR: "lro_receive_frags" [drivers/net/myri10ge/myri10ge.ko] undefined!

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 drivers/net/Kconfig |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- linux-2.6.23-git13.orig/drivers/net/Kconfig
+++ linux-2.6.23-git13/drivers/net/Kconfig
@@ -2494,7 +2494,7 @@ config CHELSIO_T3
 
 config EHEA
 	tristate "eHEA Ethernet support"
-	depends on IBMEBUS
+	depends on IBMEBUS && INET
 	select INET_LRO
 	---help---
 	  This driver supports the IBM pSeries eHEA ethernet adapter.
@@ -2591,7 +2591,7 @@ config S2IO_NAPI
 
 config MYRI10GE
 	tristate "Myricom Myri-10G Ethernet support"
-	depends on PCI
+	depends on PCI && INET
 	select FW_LOADER
 	select CRC32
 	select INET_LRO
