From: akpm@osdl.org
Subject: [patch 7/9] X.25: Dont log "unknown frame type" when receiving clear confirm
Date: Thu, 28 Oct 2004 00:19:46 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200410280721.i9S7Lj908010@mail.osdl.org>
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, akpm@osdl.org, ahendry@tusc.com.au
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: Andrew Hendry <ahendry@tusc.com.au>

There is no need to log "unknown frame type" when remote X.25 sends clear
confirms.

Signed-off-by: Andrew Hendry <ahendry@tusc.com.au>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/net/x25/x25_dev.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletion(-)

diff -puN net/x25/x25_dev.c~x25-dont-log-unknown-frame-type-when net/x25/x25_dev.c
--- 25/net/x25/x25_dev.c~x25-dont-log-unknown-frame-type-when	2004-10-28 00:17:08.407525848 -0700
+++ 25-akpm/net/x25/x25_dev.c	2004-10-28 00:17:08.410525392 -0700
@@ -92,7 +92,9 @@ static int x25_receive_data(struct sk_bu
 /*
 	x25_transmit_clear_request(nb, lci, 0x0D);
 */
-	printk(KERN_DEBUG "x25_receive_data(): unknown frame type %2x\n",frametype);
+
+	if (frametype != X25_CLEAR_CONFIRMATION)
+		printk(KERN_DEBUG "x25_receive_data(): unknown frame type %2x\n",frametype);
 
 	return 0;
 }
_
