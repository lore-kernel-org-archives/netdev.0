From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] tcp: sizeof struct tcp_skb_cb is 44
Date: Fri, 16 Jul 2010 06:20:59 +0200
Message-ID: <1279254059.2433.9.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:64282 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750838Ab0GPEVF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jul 2010 00:21:05 -0400
Received: by wwi17 with SMTP id 17so830730wwi.1
        for <netdev@vger.kernel.org>; Thu, 15 Jul 2010 21:21:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Correct comment stating sizeof(struct tcp_skb_cb) is 36 or 40, since its
44 bytes, since commit 951dbc8ac714b04 ([IPV6]: Move nextheader offset
to the IP6CB).

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/tcp.h |    9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 468b01f..df6a2eb 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -570,11 +570,10 @@ extern u32 __tcp_select_window(struct sock *sk);
 #define TCPHDR_CWR 0x80
 
 /* This is what the send packet queuing engine uses to pass
- * TCP per-packet control information to the transmission
- * code.  We also store the host-order sequence numbers in
- * here too.  This is 36 bytes on 32-bit architectures,
- * 40 bytes on 64-bit machines, if this grows please adjust
- * skbuff.h:skbuff->cb[xxx] size appropriately.
+ * TCP per-packet control information to the transmission code.
+ * We also store the host-order sequence numbers in here too.
+ * This is 44 bytes if IPV6 is enabled.
+ * If this grows please adjust skbuff.h:skbuff->cb[xxx] size appropriately.
  */
 struct tcp_skb_cb {
 	union {


