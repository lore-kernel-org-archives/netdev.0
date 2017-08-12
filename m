From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 06/51] iplink_vrf: Complain if main table is not found
Date: Sat, 12 Aug 2017 14:04:25 +0200
Message-ID: <20170812120510.28750-7-phil@nwl.cc>
References: <20170812120510.28750-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:48873 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751624AbdHLMJ2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 12 Aug 2017 08:09:28 -0400
In-Reply-To: <20170812120510.28750-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/iplink_vrf.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/ip/iplink_vrf.c b/ip/iplink_vrf.c
index 917630e853375..809eda5de8f6e 100644
--- a/ip/iplink_vrf.c
+++ b/ip/iplink_vrf.c
@@ -131,7 +131,10 @@ __u32 ipvrf_get_table(const char *name)
 					   &answer.n, sizeof(answer)) < 0) {
 		/* special case "default" vrf to be the main table */
 		if (errno == ENODEV && !strcmp(name, "default"))
-			rtnl_rttable_a2n(&tb_id, "main");
+			if (rtnl_rttable_a2n(&tb_id, "main"))
+				fprintf(stderr,
+					"BUG: RTTable \"main\" not found.\n");
+
 
 		return tb_id;
 	}
-- 
2.13.1
