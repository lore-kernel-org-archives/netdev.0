From: Jeff Garzik <jgarzik@pobox.com>
Subject: [BK PATCHES] 2.6.x net driver fixes
Date: Mon, 18 Oct 2004 19:52:54 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041018235254.GA24493@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Please do a

	bk pull bk://gkernel.bkbits.net/net-drivers-2.6

This will update the following files:

 drivers/net/typhoon.c      |    1 +
 drivers/net/wan/cycx_x25.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletion(-)

through these ChangeSets:

<viro@www.linux.org.uk> (04/10/16 1.2201)
   [PATCH] 64bit fix in cycx_x25.c
   
   comparing u32 with ~0UL is wrong
   
   Signed-off-by: Al Viro <viro@parcelfarce.linux.theplanet.co.uk>

<viro@parcelfarce.linux.theplanet.co.uk> (04/10/15 1.2200)
   [PATCH] typhoon.c missing include
   
   DMA_32BIT_MASK is declared in linux/dma-mapping.h; not all platforms get
   it from already included headers, so we need explicit include here (fixes
   breakage at least on alpha and sparc64).
   
   Signed-off-by: Al Viro <viro@parcelfarce.linux.theplanet.co.uk>

diff -Nru a/drivers/net/typhoon.c b/drivers/net/typhoon.c
--- a/drivers/net/typhoon.c	2004-10-18 19:14:46 -04:00
+++ b/drivers/net/typhoon.c	2004-10-18 19:14:46 -04:00
@@ -114,6 +114,7 @@
 #include <linux/in6.h>
 #include <asm/checksum.h>
 #include <linux/version.h>
+#include <linux/dma-mapping.h>
 
 #include "typhoon.h"
 #include "typhoon-firmware.h"
diff -Nru a/drivers/net/wan/cycx_x25.c b/drivers/net/wan/cycx_x25.c
--- a/drivers/net/wan/cycx_x25.c	2004-10-18 19:14:46 -04:00
+++ b/drivers/net/wan/cycx_x25.c	2004-10-18 19:14:46 -04:00
@@ -1195,7 +1195,7 @@
 	     remotelen = strlen(chan->addr);
 	u8 key;
 
-	if (card->u.x.connection_keys == ~0UL) {
+	if (card->u.x.connection_keys == ~0U) {
 		printk(KERN_INFO "%s: too many simultaneous connection "
 				 "requests!\n", card->devname);
 		return -EAGAIN;
