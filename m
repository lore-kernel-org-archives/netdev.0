From: Nogah Frankel <nogahf@mellanox.com>
Subject: [PATCH iproute2 v2 3/3] ifstat: Add "sw only" extended statistics to ifstat
Date: Thu, 15 Dec 2016 15:00:45 +0200
Message-ID: <1481806845-63384-4-git-send-email-nogahf@mellanox.com>
References: <1481806845-63384-1-git-send-email-nogahf@mellanox.com>
Cc: stephen@networkplumber.org, roopa@cumulusnetworks.com,
        jiri@mellanox.com, eladr@mellanox.com, yotamg@mellanox.com,
        idosch@mellanox.com, ogerlitz@mellanox.com,
        Nogah Frankel <nogahf@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:37135 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1757434AbcLOM6d (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2016 07:58:33 -0500
In-Reply-To: <1481806845-63384-1-git-send-email-nogahf@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for extended statistics of SW only type, for counting only the
packets that went via the cpu. (useful for systems with forward
offloading). It reads it from filter type IFLA_STATS_LINK_OFFLOAD_XSTATS
and sub type IFLA_OFFLOAD_XSTATS_CPU_HIT.

It is under the name 'software'
(or any shorten of it as 'soft' or simply 's')

For example:
ifstat -x s

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Reviewed-by: Jiri Pirko <jiri@mellanox.com>
---
 misc/ifstat.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/misc/ifstat.c b/misc/ifstat.c
index ac99d04..62f1f2b 100644
--- a/misc/ifstat.c
+++ b/misc/ifstat.c
@@ -730,7 +730,8 @@ static void xstat_usage(void)
 {
 	fprintf(stderr,
 "Usage: ifstat supported xstats:\n"
-"       64bits         default stats, with 64 bits support\n");
+"       64bits         default stats, with 64 bits support\n"
+"       software        SW stats. Counts only packets that went via the CPU\n");
 }
 
 struct extended_stats_options_t {
@@ -745,6 +746,7 @@ struct extended_stats_options_t {
  */
 static const struct extended_stats_options_t extended_stats_options[] = {
 	{"64bits", IFLA_STATS_LINK_64, NO_SUB_TYPE},
+	{"software",  IFLA_STATS_LINK_OFFLOAD_XSTATS, IFLA_OFFLOAD_XSTATS_CPU_HIT},
 };
 
 static bool get_filter_type(char *name)
-- 
2.4.3
