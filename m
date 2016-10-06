From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] strparser: Propagate correct error code in strp_recv()
Date: Thu,  6 Oct 2016 15:41:49 +0200
Message-ID: <1475761309-13481-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Geert Uytterhoeven <geert@linux-m68k.org>
To: "David S. Miller" <davem@davemloft.net>,
        Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from andre.telenet-ops.be ([195.130.132.53]:41578 "EHLO
        andre.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S941992AbcJFNlv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2016 09:41:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With m68k-linux-gnu-gcc-4.1:

    net/strparser/strparser.c: In function ‘strp_recv’:
    net/strparser/strparser.c:98: warning: ‘err’ may be used uninitialized in this function

Pass "len" (which is an error code when negative) instead of the
uninitialized "err" variable to fix this.

Fixes: 43a0c6751a322847 ("strparser: Stream parser for messages")
Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
Compile-tested only.
---
 net/strparser/strparser.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/strparser/strparser.c b/net/strparser/strparser.c
index 5c7549b5b92cd23c..41adf362936d7dc4 100644
--- a/net/strparser/strparser.c
+++ b/net/strparser/strparser.c
@@ -246,7 +246,7 @@ static int strp_recv(read_descriptor_t *desc, struct sk_buff *orig_skb,
 				} else {
 					strp->rx_interrupted = 1;
 				}
-				strp_parser_err(strp, err, desc);
+				strp_parser_err(strp, len, desc);
 				break;
 			} else if (len > strp->sk->sk_rcvbuf) {
 				/* Message length exceeds maximum allowed */
-- 
1.9.1
