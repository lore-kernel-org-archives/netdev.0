From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 2/2] ipaddress: Print IFLA_VF_QUERY_RSS_EN setting
Date: Wed,  1 Jun 2016 22:03:50 +0200
Message-ID: <1464811430-19415-3-git-send-email-phil@nwl.cc>
References: <1464811430-19415-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:52509 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751096AbcFAUEJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Jun 2016 16:04:09 -0400
In-Reply-To: <1464811430-19415-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/ipaddress.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 9ac077459f136..bd705dbed60c6 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -364,6 +364,14 @@ static void print_vfinfo(FILE *fp, struct rtattr *vfinfo)
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
2.8.2
