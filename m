From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: [PATCH 2/7] [DCCP]: Introduce generic function to test for `data packets'
Date: Thu,  6 Dec 2007 19:02:49 -0200
Message-ID: <1196974974-31531-3-git-send-email-acme@redhat.com>
References: <1196974974-31531-1-git-send-email-acme@redhat.com>
 <1196974974-31531-2-git-send-email-acme@redhat.com>
Cc: netdev@vger.kernel.org, dccp@vger.kernel.org,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>,
	Ian McDonald <ian.mcdonald@jandi.co.nz>,
	Arnaldo Carvalho de Melo <acme@redhat.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.248]:54299 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752054AbXLFVDJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2007 16:03:09 -0500
Received: by an-out-0708.google.com with SMTP id d31so97881and
        for <netdev@vger.kernel.org>; Thu, 06 Dec 2007 13:03:07 -0800 (PST)
In-Reply-To: <1196974974-31531-2-git-send-email-acme@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>

as per  RFC 4340, sec. 7.7.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/dccp.h |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index ee97950..f4a5ea1 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -334,6 +334,7 @@ struct dccp_skb_cb {
 
 #define DCCP_SKB_CB(__skb) ((struct dccp_skb_cb *)&((__skb)->cb[0]))
 
+/* RFC 4340, sec. 7.7 */
 static inline int dccp_non_data_packet(const struct sk_buff *skb)
 {
 	const __u8 type = DCCP_SKB_CB(skb)->dccpd_type;
@@ -346,6 +347,17 @@ static inline int dccp_non_data_packet(const struct sk_buff *skb)
 	       type == DCCP_PKT_SYNCACK;
 }
 
+/* RFC 4340, sec. 7.7 */
+static inline int dccp_data_packet(const struct sk_buff *skb)
+{
+	const __u8 type = DCCP_SKB_CB(skb)->dccpd_type;
+
+	return type == DCCP_PKT_DATA	 ||
+	       type == DCCP_PKT_DATAACK  ||
+	       type == DCCP_PKT_REQUEST  ||
+	       type == DCCP_PKT_RESPONSE;
+}
+
 static inline int dccp_packet_without_ack(const struct sk_buff *skb)
 {
 	const __u8 type = DCCP_SKB_CB(skb)->dccpd_type;
-- 
1.5.3.4

