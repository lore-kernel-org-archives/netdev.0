From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Subject: [PATCH 3/7] [DCCP]: Introduces follows48 function
Date: Thu, 24 Aug 2006 15:21:51 +1200
Message-ID: <200608241521.52012.ian.mcdonald@jandi.co.nz>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.180]:11809 "EHLO
	py-out-1112.google.com") by vger.kernel.org with ESMTP
	id S1030240AbWHXDWH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 23:22:07 -0400
Received: by py-out-1112.google.com with SMTP id n25so510095pyg
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2006 20:22:07 -0700 (PDT)
To: Andrea Bittau <a.bittau@cs.ucl.ac.uk>,
	David Miller <davem@davemloft.net>,
	Arnaldo de Melo <arnaldo.melo@gmail.com>,
	"DCCP (vger)" <dccp@vger.kernel.org>,
	"netdev, " <netdev@vger.kernel.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This adds a new function to see if two sequence numbers follow each other.

Signed off by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index b8931d3..84b477d 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -81,6 +81,14 @@ static inline u64 max48(const u64 seq1, 
 	return after48(seq1, seq2) ? seq1 : seq2;
 }
 
+/* is seq1 next seqno after seq2 */
+static inline int follows48(const u64 seq1, const u64 seq2)
+{
+	int diff = (seq1 & 0xFFFF) - (seq2 & 0xFFFF);
+	
+	return diff==1;
+}
+
 enum {
 	DCCP_MIB_NUM = 0,
 	DCCP_MIB_ACTIVEOPENS,			/* ActiveOpens */
