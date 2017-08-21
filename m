From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 2/3] iplink_vrf: Complain if main table is not found
Date: Mon, 21 Aug 2017 18:36:51 +0200
Message-ID: <20170821163652.23752-3-phil@nwl.cc>
References: <20170821163652.23752-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:38813 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754033AbdHUQhX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Aug 2017 12:37:23 -0400
In-Reply-To: <20170821163652.23752-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
Acked-by: David Ahern <dsahern@gmail.com>
---
Changes since v1:
- Remove double newline addon.
- Added David's ACK from v1 review.
---
 ip/iplink_vrf.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/ip/iplink_vrf.c b/ip/iplink_vrf.c
index 917630e853375..2b85a3a56eb70 100644
--- a/ip/iplink_vrf.c
+++ b/ip/iplink_vrf.c
@@ -131,7 +131,9 @@ __u32 ipvrf_get_table(const char *name)
 					   &answer.n, sizeof(answer)) < 0) {
 		/* special case "default" vrf to be the main table */
 		if (errno == ENODEV && !strcmp(name, "default"))
-			rtnl_rttable_a2n(&tb_id, "main");
+			if (rtnl_rttable_a2n(&tb_id, "main"))
+				fprintf(stderr,
+					"BUG: RTTable \"main\" not found.\n");
 
 		return tb_id;
 	}
-- 
2.13.1
