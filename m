From: akpm@linux-foundation.org
Subject: [patch 2/2] drivers/net/82596.c: suppress warnings
Date: Tue, 12 May 2009 13:48:37 -0700
Message-ID: <200905122107.n4CL7qqQ010642@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:32774 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750939AbZELVJx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2009 17:09:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>

i386 allmodconfig:

drivers/net/82596.c: In function 'init_rx_bufs':
drivers/net/82596.c:544: warning: cast to pointer from integer of different size
drivers/net/82596.c:545: warning: cast to pointer from integer of different size
drivers/net/82596.c:548: warning: cast to pointer from integer of different size
drivers/net/82596.c:557: warning: cast to pointer from integer of different size
drivers/net/82596.c:565: warning: cast to pointer from integer of different size
drivers/net/82596.c:569: warning: cast to pointer from integer of different size
drivers/net/82596.c:575: warning: cast to pointer from integer of different size
drivers/net/82596.c: In function 'rebuild_rx_bufs':
drivers/net/82596.c:606: warning: cast to pointer from integer of different size
drivers/net/82596.c:608: warning: cast to pointer from integer of different size
drivers/net/82596.c: In function 'init_i596_mem':
drivers/net/82596.c:680: warning: cast to pointer from integer of different size
drivers/net/82596.c:681: warning: cast to pointer from integer of different size
drivers/net/82596.c: In function 'i596_rx':
drivers/net/82596.c:818: warning: cast to pointer from integer of different size
drivers/net/82596.c: In function 'i596_add_cmd':
drivers/net/82596.c:975: warning: cast to pointer from integer of different size
drivers/net/82596.c:979: warning: cast to pointer from integer of different size
drivers/net/82596.c: In function 'i596_start_xmit':
drivers/net/82596.c:1088: warning: cast to pointer from integer of different size
drivers/net/82596.c:1099: warning: cast to pointer from integer of different size
drivers/net/82596.c: In function 'i596_interrupt':
drivers/net/82596.c:1404: warning: cast to pointer from integer of different size

(ugh)

Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/82596.c |   14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff -puN drivers/net/82596.c~drivers-net-82596c-suppress-warnings drivers/net/82596.c
--- a/drivers/net/82596.c~drivers-net-82596c-suppress-warnings
+++ a/drivers/net/82596.c
@@ -122,13 +122,13 @@ static char version[] __initdata =
 #define ISCP_BUSY	0x00010000
 #define MACH_IS_APRICOT	0
 #else
-#define WSWAPrfd(x)     ((struct i596_rfd *)(x))
-#define WSWAPrbd(x)     ((struct i596_rbd *)(x))
-#define WSWAPiscp(x)    ((struct i596_iscp *)(x))
-#define WSWAPscb(x)     ((struct i596_scb *)(x))
-#define WSWAPcmd(x)     ((struct i596_cmd *)(x))
-#define WSWAPtbd(x)     ((struct i596_tbd *)(x))
-#define WSWAPchar(x)    ((char *)(x))
+#define WSWAPrfd(x)     ((struct i596_rfd *)((long)x))
+#define WSWAPrbd(x)     ((struct i596_rbd *)((long)x))
+#define WSWAPiscp(x)    ((struct i596_iscp *)((long)x))
+#define WSWAPscb(x)     ((struct i596_scb *)((long)x))
+#define WSWAPcmd(x)     ((struct i596_cmd *)((long)x))
+#define WSWAPtbd(x)     ((struct i596_tbd *)((long)x))
+#define WSWAPchar(x)    ((char *)((long)x))
 #define ISCP_BUSY	0x0001
 #define MACH_IS_APRICOT	1
 #endif
_
