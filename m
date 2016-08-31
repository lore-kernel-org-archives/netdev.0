From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH RFC 1/4] net: Set SW hash in skb_set_hash_from_sk
Date: Tue, 30 Aug 2016 17:00:31 -0700
Message-ID: <1472601634-531498-2-git-send-email-tom@herbertland.com>
References: <1472601634-531498-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <rick.jones2@hpe.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:45669 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752244AbcHaABI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2016 20:01:08 -0400
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u7UNtGRG014528
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2016 17:00:44 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 255juj0se9-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2016 17:00:44 -0700
Received: from facebook.com (2401:db00:21:6030:face:0:92:0)     by
 mx-out.facebook.com (10.223.100.97) with ESMTP id
 f5ea68846f0d11e695e924be0593f280-708efaa0 for <netdev@vger.kernel.org>;        Tue,
 30 Aug 2016 17:00:43 -0700
In-Reply-To: <1472601634-531498-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the __skb_set_sw_hash to set the hash in an skbuff from the socket
txhash.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/sock.h | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index c797c57..12e585c 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1910,10 +1910,8 @@ static inline void sock_poll_wait(struct file *filp,
 
 static inline void skb_set_hash_from_sk(struct sk_buff *skb, struct sock *sk)
 {
-	if (sk->sk_txhash) {
-		skb->l4_hash = 1;
-		skb->hash = sk->sk_txhash;
-	}
+	if (sk->sk_txhash)
+		__skb_set_sw_hash(skb, sk->sk_txhash, true);
 }
 
 void skb_set_owner_w(struct sk_buff *skb, struct sock *sk);
-- 
2.8.0.rc2
