From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 1/2] net: add skb_checksum_complete_unset
Date: Mon, 20 Apr 2015 14:10:04 -0700
Message-ID: <1429564205-1661247-2-git-send-email-tom@herbertland.com>
References: <1429564205-1661247-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:47500 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754402AbbDTVKW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2015 17:10:22 -0400
Received: from pps.filterd (m0004348 [127.0.0.1])
	by m0004348.ppops.net (8.14.5/8.14.5) with SMTP id t3KL9osK021545
	for <netdev@vger.kernel.org>; Mon, 20 Apr 2015 14:10:21 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0004348.ppops.net with ESMTP id 1tw7pwr4y6-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 20 Apr 2015 14:10:21 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.236.89) with ESMTP	id
 a6fd948ee7a111e487e00002c95209d8-492a72c0 for <netdev@vger.kernel.org>;	Mon,
 20 Apr 2015 14:10:20 -0700
In-Reply-To: <1429564205-1661247-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This function changes ip_summed to CHECKSUM_NONE if CHECKSUM_COMPLETE
is set. This is called to discard checksum-complete when packet
is being modified and checksum is not pulled for headers in a layer.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/linux/skbuff.h | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 0991259..06793b5 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -3016,6 +3016,18 @@ static inline bool __skb_checksum_validate_needed(struct sk_buff *skb,
  */
 #define CHECKSUM_BREAK 76
 
+/* Unset checksum-complete
+ *
+ * Unset checksum complete can be done when packet is being modified
+ * (uncompressed for instance) and checksum-complete value is
+ * invalidated.
+ */
+static inline void skb_checksum_complete_unset(struct sk_buff *skb)
+{
+	if (skb->ip_summed == CHECKSUM_COMPLETE)
+		skb->ip_summed = CHECKSUM_NONE;
+}
+
 /* Validate (init) checksum based on checksum complete.
  *
  * Return values:
-- 
1.8.1
