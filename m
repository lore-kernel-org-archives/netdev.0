From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 2/2] ipaddress: Print IFLA_VF_QUERY_RSS_EN setting
Date: Tue,  8 Nov 2016 22:29:12 +0100
Message-ID: <20161108212912.27258-3-phil@nwl.cc>
References: <20161108212912.27258-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:44324 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754255AbcKHV3a (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 8 Nov 2016 16:29:30 -0500
In-Reply-To: <20161108212912.27258-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/ipaddress.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index df0f1b9c94c58..c9f769fb748e4 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -405,6 +405,14 @@ static void print_vfinfo(FILE *fp, struct rtattr *vfinfo)
 			fprintf(fp, ", trust %s",
 			        vf_trust->setting ? "on" : "off");
 	}
+	if (vf[IFLA_VF_RSS_QUERY_EN]) {
+		struct ifla_vf_rss_query_en *rss_query =
+			RTA_DATA(vf[IFLA_VF_RSS_QUERY_EN]);
+
+		if (rss_query->setting != -1)
+			fprintf(fp, ", query_rss %s",
+			        rss_query->setting ? "on" : "off");
+	}
 	if (vf[IFLA_VF_STATS] && show_stats)
 		print_vf_stats64(fp, vf[IFLA_VF_STATS]);
 }
-- 
2.10.0
