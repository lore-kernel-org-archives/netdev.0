From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: remove a sparse error in
 secure_dccpv6_sequence_number()
Date: Mon, 25 May 2015 18:55:48 -0700
Message-ID: <1432605348.4060.218.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:34738 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751143AbbEZBzu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2015 21:55:50 -0400
Received: by ieczm2 with SMTP id zm2so82034545iec.1
        for <netdev@vger.kernel.org>; Mon, 25 May 2015 18:55:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

make C=2 CF=-D__CHECK_ENDIAN__ net/core/secure_seq.o
net/core/secure_seq.c:157:50: warning: restricted __be32 degrades to
integer

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/secure_seq.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
diff --git a/net/core/secure_seq.c b/net/core/secure_seq.c
index 51dd3193a33ebb26ea3c008e752d1f2832f791d8..fd3ce461fbe6210ab95fbcbb4b5e6c862a262898 100644
--- a/net/core/secure_seq.c
+++ b/net/core/secure_seq.c
@@ -154,7 +154,7 @@ u64 secure_dccpv6_sequence_number(__be32 *saddr, __be32 *daddr,
 	net_secret_init();
 	memcpy(hash, saddr, 16);
 	for (i = 0; i < 4; i++)
-		secret[i] = net_secret[i] + daddr[i];
+		secret[i] = net_secret[i] + (__force u32)daddr[i];
 	secret[4] = net_secret[4] +
 		(((__force u16)sport << 16) + (__force u16)dport);
 	for (i = 5; i < MD5_MESSAGE_BYTES / 4; i++)
