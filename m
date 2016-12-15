From: Nogah Frankel <nogahf@mellanox.com>
Subject: [PATCH iproute2 v2 2/3] ifstat: Add 64 bits based stats to extended statistics
Date: Thu, 15 Dec 2016 15:00:44 +0200
Message-ID: <1481806845-63384-3-git-send-email-nogahf@mellanox.com>
References: <1481806845-63384-1-git-send-email-nogahf@mellanox.com>
Cc: stephen@networkplumber.org, roopa@cumulusnetworks.com,
        jiri@mellanox.com, eladr@mellanox.com, yotamg@mellanox.com,
        idosch@mellanox.com, ogerlitz@mellanox.com,
        Nogah Frankel <nogahf@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:37134 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1756056AbcLOM6e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2016 07:58:34 -0500
In-Reply-To: <1481806845-63384-1-git-send-email-nogahf@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The default stats for ifstat are 32 bits based.
The kernel supports 64 bits based stats. (They are returned in struct
rtnl_link_stats64 which is an exact copy of struct rtnl_link_stats, in
which the "normal" stats are returned, but with fields of u64 instead of
u32). This patch adds them as an extended stats.

It is read with filter type IFLA_STATS_LINK_64 and no sub type.

It is under the name 64bits
(or any shorten of it as "64")

For example:
ifstat -x 64bit

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Reviewed-by: Jiri Pirko <jiri@mellanox.com>
---
 misc/ifstat.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/misc/ifstat.c b/misc/ifstat.c
index d17ae21..ac99d04 100644
--- a/misc/ifstat.c
+++ b/misc/ifstat.c
@@ -729,7 +729,8 @@ static int verify_forging(int fd)
 static void xstat_usage(void)
 {
 	fprintf(stderr,
-"Usage: ifstat supported xstats:\n");
+"Usage: ifstat supported xstats:\n"
+"       64bits         default stats, with 64 bits support\n");
 }
 
 struct extended_stats_options_t {
@@ -743,6 +744,7 @@ struct extended_stats_options_t {
  * Name length must be under 64 chars.
  */
 static const struct extended_stats_options_t extended_stats_options[] = {
+	{"64bits", IFLA_STATS_LINK_64, NO_SUB_TYPE},
 };
 
 static bool get_filter_type(char *name)
-- 
2.4.3
