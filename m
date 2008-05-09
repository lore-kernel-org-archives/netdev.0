From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH -next] net: hso driver uses rfkill functions
Date: Fri, 9 May 2008 09:51:40 -0700
Message-ID: <20080509095140.520aa39c.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik <jgarzik@pobox.com>, akpm <akpm@linux-foundation.org>
To: netdev <netdev@vger.kernel.org>, ajb@spheresystems.co.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:14733 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761323AbYEIQwu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2008 12:52:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

hso driver uses rfkill functions so should either depend on RFKILL
or select it.  This patch uses depends on RFKILL.

drivers/built-in.o: In function `hso_disconnect':
hso.c:(.text+0x868c9): undefined reference to `rfkill_unregister'
drivers/built-in.o: In function `hso_probe':
hso.c:(.text+0x88226): undefined reference to `rfkill_allocate'
hso.c:(.text+0x8829e): undefined reference to `rfkill_register'
hso.c:(.text+0x8860f): undefined reference to `rfkill_free'
make[1]: *** [.tmp_vmlinux1] Error 1

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 drivers/net/usb/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- next-20080509.orig/drivers/net/usb/Kconfig
+++ next-20080509/drivers/net/usb/Kconfig
@@ -156,7 +156,7 @@ config USB_NET_AX8817X
 
 config USB_HSO
 	tristate "Option USB High Speed Mobile Devices"
-	depends on USB
+	depends on USB && RFKILL
 	default n
 	help
 	  Choose this option if you have an Option HSDPA/HSUPA card.
