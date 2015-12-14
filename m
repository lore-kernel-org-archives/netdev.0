From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 1/8] net: Add skb_inner_transport_offset function
Date: Mon, 14 Dec 2015 11:19:40 -0800
Message-ID: <1450120787-1773171-2-git-send-email-tom@herbertland.com>
References: <1450120787-1773171-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:10095 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932088AbbLNTUS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2015 14:20:18 -0500
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.15.0.59/8.15.0.59) with SMTP id tBEJIpts029799
	for <netdev@vger.kernel.org>; Mon, 14 Dec 2015 11:20:18 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0089730.ppops.net with ESMTP id 1ys6pmxhxx-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 14 Dec 2015 11:20:18 -0800
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.102.107.99) with ESMTP	id
 b3cc8088a29711e593540002c99293a0-b11f8210 for <netdev@vger.kernel.org>;	Mon,
 14 Dec 2015 11:20:16 -0800
In-Reply-To: <1450120787-1773171-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Same thing as skb_transport_offset but returns the offset of the inner
transport header (when skb->encpasulation is set).

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/linux/skbuff.h | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 9b9b9ea..3f19744 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1939,6 +1939,11 @@ static inline unsigned char *skb_inner_transport_header(const struct sk_buff
 	return skb->head + skb->inner_transport_header;
 }
 
+static inline int skb_inner_transport_offset(const struct sk_buff *skb)
+{
+	return skb_inner_transport_header(skb) - skb->data;
+}
+
 static inline void skb_reset_inner_transport_header(struct sk_buff *skb)
 {
 	skb->inner_transport_header = skb->data - skb->head;
-- 
2.4.6
