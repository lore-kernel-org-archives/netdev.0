From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v2 net-next 5/5] ipv6: Enable auto flow labels by default
Date: Fri, 31 Jul 2015 16:52:14 -0700
Message-ID: <1438386734-1942188-6-git-send-email-tom@herbertland.com>
References: <1438386734-1942188-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:34762 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753801AbbGaX5u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 19:57:50 -0400
Received: from pps.filterd (m0004060 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t6VNvnJt028006
	for <netdev@vger.kernel.org>; Fri, 31 Jul 2015 16:57:50 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1w0hrm8bwp-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 31 Jul 2015 16:57:50 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.223.100.99) with ESMTP	id
 b0977ada37df11e5800024be05956610-d63f22b0 for <netdev@vger.kernel.org>;	Fri,
 31 Jul 2015 16:55:58 -0700
In-Reply-To: <1438386734-1942188-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Initialize auto_flowlabels to one. This enables automatic flow labels,
individual socket may disable them using the IPV6_AUTOFLOWLABEL socket
option.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 Documentation/networking/ip-sysctl.txt | 2 +-
 include/net/ipv6.h                     | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 9ac3af3..56db1ef 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1228,7 +1228,7 @@ auto_flowlabels - INTEGER
 	   per socket basis using the IPV6_AUTOFLOWLABEL socket option
 	3: automatic flow labels are enabled and enforced, they cannot
 	   be disabled by the socket option
-	Default: 0
+	Default: 1
 
 flowlabel_state_ranges - BOOLEAN
 	Split the flow label number space into two ranges. 0-0x7FFFF is
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index f8e755b..500c0ee 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -716,7 +716,7 @@ static inline void iph_to_flow_copy_v6addrs(struct flow_keys *flow,
 
 #define IP6_AUTO_FLOW_LABEL_MAX		IP6_AUTO_FLOW_LABEL_FORCED
 
-#define IP6_DEFAULT_AUTO_FLOW_LABELS	IP6_AUTO_FLOW_LABEL_OFF
+#define IP6_DEFAULT_AUTO_FLOW_LABELS	IP6_AUTO_FLOW_LABEL_OPTOUT
 
 static inline __be32 ip6_make_flowlabel(struct net *net, struct sk_buff *skb,
 					__be32 flowlabel, bool autolabel,
-- 
1.8.5.6
