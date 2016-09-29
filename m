From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v2 net-next 1/5] net: Set SW hash in skb_set_hash_from_sk
Date: Wed, 28 Sep 2016 20:54:24 -0700
Message-ID: <20160929035428.204355-2-tom@herbertland.com>
References: <20160929035428.204355-1-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>, <rick.jones2@hpe.com>,
        <alexander.duyck@gmail.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:50064 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751268AbcI2Dyq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 23:54:46 -0400
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
        by m0089730.ppops.net (8.16.0.17/8.16.0.17) with SMTP id u8T3rkc5016305
        for <netdev@vger.kernel.org>; Wed, 28 Sep 2016 20:54:44 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0089730.ppops.net with ESMTP id 25qjw9uncw-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 28 Sep 2016 20:54:44 -0700
Received: from facebook.com (2401:db00:21:6030:face:0:92:0)     by
 mx-out.facebook.com (10.212.232.59) with ESMTP id
 744a362c85f811e6b2090002c991e86a-334f3a50 for <netdev@vger.kernel.org>;        Wed,
 28 Sep 2016 20:54:43 -0700
In-Reply-To: <20160929035428.204355-1-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the __skb_set_sw_hash to set the hash in an skbuff from the socket
txhash.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/sock.h | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index ebf75db..17d379a 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1920,10 +1920,8 @@ static inline void sock_poll_wait(struct file *filp,
 
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
2.9.3
