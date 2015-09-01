From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 08/11] flow_dissector: Add flag to stop parsing at L3
Date: Tue, 1 Sep 2015 09:24:30 -0700
Message-ID: <1441124673-3438470-9-git-send-email-tom@herbertland.com>
References: <1441124673-3438470-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:37961 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753486AbbIAQZV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 12:25:21 -0400
Received: from pps.filterd (m0004348 [127.0.0.1])
	by m0004348.ppops.net (8.14.5/8.14.5) with SMTP id t81GOxLX002489
	for <netdev@vger.kernel.org>; Tue, 1 Sep 2015 09:25:21 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0004348.ppops.net with ESMTP id 1wnews836j-11
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 01 Sep 2015 09:25:21 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.102.107.97) with ESMTP	id
 08a2033650c611e5b4920002c99331b0-5fbfc240 for <netdev@vger.kernel.org>;	Tue,
 01 Sep 2015 09:25:18 -0700
In-Reply-To: <1441124673-3438470-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add an input flag to flow dissector on rather dissection should be
stopped when an L3 packet is encountered. This would be useful if a
caller just wanted to get IP addresses of the outermost header (e.g.
to do an L3 hash).

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/flow_dissector.h | 1 +
 net/core/flow_dissector.c    | 6 ++++++
 2 files changed, 7 insertions(+)

diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
index 3410227..bb81e3b 100644
--- a/include/net/flow_dissector.h
+++ b/include/net/flow_dissector.h
@@ -125,6 +125,7 @@ enum flow_dissector_key_id {
 };
 
 #define FLOW_DISSECTOR_F_PARSE_1ST_FRAG		BIT(0)
+#define FLOW_DISSECTOR_F_STOP_AT_L3		BIT(1)
 
 struct flow_dissector_key {
 	enum flow_dissector_key_id key_id;
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 907de2f..94fd841 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -200,6 +200,9 @@ ip:
 			}
 		}
 
+		if (flags & FLOW_DISSECTOR_F_STOP_AT_L3)
+			goto out_good;
+
 		break;
 	}
 	case htons(ETH_P_IPV6): {
@@ -238,6 +241,9 @@ ipv6:
 			}
 		}
 
+		if (flags & FLOW_DISSECTOR_F_STOP_AT_L3)
+			goto out_good;
+
 		break;
 	}
 	case htons(ETH_P_8021AD):
-- 
1.8.1
