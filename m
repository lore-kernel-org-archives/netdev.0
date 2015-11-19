From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH 01/15] net: Add skb_inner_transport_offset function
Date: Thu, 19 Nov 2015 11:55:47 -0800
Message-ID: <1447962961-2106059-2-git-send-email-tom@herbertland.com>
References: <1447962961-2106059-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:54154 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759041AbbKST4M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 14:56:12 -0500
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id tAJJsEua022559
	for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 11:56:11 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1y8r6u785m-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 19 Nov 2015 11:56:11 -0800
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.102.107.97) with ESMTP	id
 947d29ac8ef711e581b20002c99331b0-989fa230 for <netdev@vger.kernel.org>;	Thu,
 19 Nov 2015 11:56:10 -0800
In-Reply-To: <1447962961-2106059-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Same thing as skb_transport_offset but returns the offset of the inner
transport header (when skb->encpasulation is set).

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/linux/skbuff.h | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index c9c394b..0713080 100644
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
