From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 1/4] net: Set SW hash in skb_set_hash_from_sk
Date: Wed, 31 Aug 2016 17:10:02 -0700
Message-ID: <1472688605-2613704-2-git-send-email-tom@herbertland.com>
References: <1472688605-2613704-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>, <rick.jones2@hpe.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:50996 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1754179AbcIAAKY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2016 20:10:24 -0400
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
        by m0089730.ppops.net (8.16.0.17/8.16.0.17) with SMTP id u8108lWp032740
        for <netdev@vger.kernel.org>; Wed, 31 Aug 2016 17:10:23 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0089730.ppops.net with ESMTP id 2564kytrb5-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 31 Aug 2016 17:10:23 -0700
Received: from facebook.com (2401:db00:21:6030:face:0:92:0)     by
 mx-out.facebook.com (10.212.236.89) with ESMTP id
 794373c26fd811e683ae0002c95209d8-f42f6a50 for <netdev@vger.kernel.org>;        Wed,
 31 Aug 2016 17:10:22 -0700
In-Reply-To: <1472688605-2613704-1-git-send-email-tom@herbertland.com>
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
