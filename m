From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH] net: Provide lwtstate_free for non-lwt config
Date: Wed, 19 Aug 2015 15:16:06 -0700
Message-ID: <1440022566-4081118-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <jbenc@redhat.com>, <roopa@cumulusnetworks.com>,
	<netdev@vger.kernel.org>, Alex Gartrell <agartrell@fb.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:36809 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752358AbbHSWQK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 18:16:10 -0400
Received: from pps.filterd (m0044008 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t7JMFbMP002719
	for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 15:16:10 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1wd0hfgcpm-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 15:16:10 -0700
Received: from facebook.com (2401:db00:20:7017:face:0:13:0)	by
 mx-out.facebook.com (10.103.99.99) with ESMTP	id
 e466a7ca46bf11e5b29a0002c9dfb610-543f12b0 for <netdev@vger.kernel.org>;	Wed,
 19 Aug 2015 15:16:08 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes: df383e624 ("lwtunnel: fix memory leak")

Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 include/net/lwtunnel.h | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/include/net/lwtunnel.h b/include/net/lwtunnel.h
index 34fd8f7..cfee539 100644
--- a/include/net/lwtunnel.h
+++ b/include/net/lwtunnel.h
@@ -93,6 +93,10 @@ int lwtunnel_input6(struct sk_buff *skb);
 
 #else
 
+static inline void lwtstate_free(struct lwtunnel_state *lws)
+{
+}
+
 static inline struct lwtunnel_state *
 lwtstate_get(struct lwtunnel_state *lws)
 {
-- 
Alex Gartrell <agartrell@fb.com>
