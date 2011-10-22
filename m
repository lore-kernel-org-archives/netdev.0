From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] inet: add rfc 3168 extract in front of
 INET_ECN_encapsulate()
Date: Sat, 22 Oct 2011 07:11:08 +0200
Message-ID: <1319260268.6180.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:32954 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751719Ab1JVFLN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Oct 2011 01:11:13 -0400
Received: by wyg36 with SMTP id 36so4603687wyg.19
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2011 22:11:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

INET_ECN_encapsulate() is better understood if we can read the official
statement.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/inet_ecn.h |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/include/net/inet_ecn.h b/include/net/inet_ecn.h
index 2fa8d13..2fa1469 100644
--- a/include/net/inet_ecn.h
+++ b/include/net/inet_ecn.h
@@ -30,6 +30,14 @@ static inline int INET_ECN_is_capable(__u8 dsfield)
 	return dsfield & INET_ECN_ECT_0;
 }
 
+/*
+ * RFC 3168 9.1.1
+ *  The full-functionality option for ECN encapsulation is to copy the
+ *  ECN codepoint of the inside header to the outside header on
+ *  encapsulation if the inside header is not-ECT or ECT, and to set the
+ *  ECN codepoint of the outside header to ECT(0) if the ECN codepoint of
+ *  the inside header is CE.
+ */
 static inline __u8 INET_ECN_encapsulate(__u8 outer, __u8 inner)
 {
 	outer &= ~INET_ECN_MASK;
