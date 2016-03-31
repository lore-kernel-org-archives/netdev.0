From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH] ip-link: Support printing VF trust setting
Date: Thu, 31 Mar 2016 14:43:32 +0200
Message-ID: <1459428212-19575-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:54333 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752805AbcCaMnp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Mar 2016 08:43:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds a new item to VF lines of a PF, stating whether the VF is
trusted or not.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/ipaddress.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 3998d8cec4ab2..2f1d55c115dde 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -380,6 +380,13 @@ static void print_vfinfo(FILE *fp, struct rtattr *vfinfo)
 		else
 			fprintf(fp, ", link-state disable");
 	}
+	if (vf[IFLA_VF_TRUST]) {
+		struct ifla_vf_trust *vf_trust = RTA_DATA(vf[IFLA_VF_TRUST]);
+
+		if (vf_trust->setting != -1)
+			fprintf(fp, ", trust %s",
+			        vf_trust->setting ? "on" : "off");
+	}
 	if (vf[IFLA_VF_STATS] && show_stats)
 		print_vf_stats64(fp, vf[IFLA_VF_STATS]);
 }
-- 
2.7.2
