From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH RFC 1/3] net: Add skb_inner_transport_offset function
Date: Mon, 5 Oct 2015 16:39:22 -0700
Message-ID: <1444088364-2839440-2-git-send-email-tom@herbertland.com>
References: <1444088364-2839440-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>, <dwmw2@infradead.org>,
	<ogerlitz@mellanox.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:31640 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751165AbbJEXj4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 19:39:56 -0400
Received: from pps.filterd (m0041696 [127.0.0.1])
	by m0041696.ppops.net (8.14.5/8.14.5) with SMTP id t95Na7RU018501
	for <netdev@vger.kernel.org>; Mon, 5 Oct 2015 16:39:55 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0041696.ppops.net with ESMTP id 1xc2rar326-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 05 Oct 2015 16:39:55 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.223.100.99) with ESMTP	id
 5ffda8d86bba11e58e6a24be05956610-edbfa240 for <netdev@vger.kernel.org>;	Mon,
 05 Oct 2015 16:39:52 -0700
In-Reply-To: <1444088364-2839440-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Same thing as skb_transport_offset but returns the offset of the inner
transport header (when skb->encpasulation is set).

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/linux/skbuff.h | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 4398411..ad1a24c 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1933,6 +1933,11 @@ static inline unsigned char *skb_inner_transport_header(const struct sk_buff
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
