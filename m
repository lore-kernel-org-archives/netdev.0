From: akpm@linux-foundation.org
Subject: [patch 2/8] net: hso driver uses rfkill functions
Date: Wed, 14 May 2008 16:19:41 -0700
Message-ID: <200805142319.m4ENJfqo026554@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	randy.dunlap@oracle.com, greg@kroah.com, jeff@garzik.org,
	paulius.zaleckas@teltonika.lt
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:42580 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754457AbYENXU3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2008 19:20:29 -0400
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

On Mon, 12 May 2008 11:29:20 +0300
Paulius Zaleckas <paulius.zaleckas@teltonika.lt> wrote:

> AFAIK Greg has (or he is going to do it) patch for rfkill so no more 
> depends or select RFKILL will be needed.

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
Cc: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Cc: Greg KH <greg@kroah.com>
Cc: Jeff Garzik <jeff@garzik.org>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/usb/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/usb/Kconfig~net-hso-driver-uses-rfkill-functions drivers/net/usb/Kconfig
--- a/drivers/net/usb/Kconfig~net-hso-driver-uses-rfkill-functions
+++ a/drivers/net/usb/Kconfig
@@ -156,7 +156,7 @@ config USB_NET_AX8817X
 
 config USB_HSO
 	tristate "Option USB High Speed Mobile Devices"
-	depends on USB
+	depends on USB && RFKILL
 	default n
 	help
 	  Choose this option if you have an Option HSDPA/HSUPA card.
_
