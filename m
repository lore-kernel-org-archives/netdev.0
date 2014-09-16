From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: [PATCH 09/22] batman-adv: Replace strnicmp with strncasecmp
Date: Tue, 16 Sep 2014 22:51:23 +0200
Message-ID: <1410900696-6481-10-git-send-email-linux@rasmusvillemoes.dk>
References: <1410900696-6481-1-git-send-email-linux@rasmusvillemoes.dk>
Cc: linux-kernel@vger.kernel.org,
	Rasmus Villemoes <linux@rasmusvillemoes.dk>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	b.a.t.m.a.n@lists.open-mesh.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1410900696-6481-1-git-send-email-linux@rasmusvillemoes.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The kernel used to contain two functions for length-delimited,
case-insensitive string comparison, strnicmp with correct semantics
and a slightly buggy strncasecmp. The latter is the POSIX name, so
strnicmp was renamed to strncasecmp, and strnicmp made into a wrapper
for the new strncasecmp to avoid breaking existing users.

To allow the compat wrapper strnicmp to be removed at some point in
the future, and to avoid the extra indirection cost, do
s/strnicmp/strncasecmp/g.

Cc: Marek Lindner <mareklindner@neomailbox.ch>
Cc: b.a.t.m.a.n@lists.open-mesh.org
Cc: netdev@vger.kernel.org
Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
---
 net/batman-adv/gateway_common.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/batman-adv/gateway_common.c b/net/batman-adv/gateway_common.c
index 6f5e621..88a1bc3 100644
--- a/net/batman-adv/gateway_common.c
+++ b/net/batman-adv/gateway_common.c
@@ -44,10 +44,10 @@ static bool batadv_parse_gw_bandwidth(struct net_device *net_dev, char *buff,
 	if (strlen(buff) > 4) {
 		tmp_ptr = buff + strlen(buff) - 4;
 
-		if (strnicmp(tmp_ptr, "mbit", 4) == 0)
+		if (strncasecmp(tmp_ptr, "mbit", 4) == 0)
 			bw_unit_type = BATADV_BW_UNIT_MBIT;
 
-		if ((strnicmp(tmp_ptr, "kbit", 4) == 0) ||
+		if ((strncasecmp(tmp_ptr, "kbit", 4) == 0) ||
 		    (bw_unit_type == BATADV_BW_UNIT_MBIT))
 			*tmp_ptr = '\0';
 	}
@@ -77,10 +77,10 @@ static bool batadv_parse_gw_bandwidth(struct net_device *net_dev, char *buff,
 		if (strlen(slash_ptr + 1) > 4) {
 			tmp_ptr = slash_ptr + 1 - 4 + strlen(slash_ptr + 1);
 
-			if (strnicmp(tmp_ptr, "mbit", 4) == 0)
+			if (strncasecmp(tmp_ptr, "mbit", 4) == 0)
 				bw_unit_type = BATADV_BW_UNIT_MBIT;
 
-			if ((strnicmp(tmp_ptr, "kbit", 4) == 0) ||
+			if ((strncasecmp(tmp_ptr, "kbit", 4) == 0) ||
 			    (bw_unit_type == BATADV_BW_UNIT_MBIT))
 				*tmp_ptr = '\0';
 		}
-- 
2.0.4
