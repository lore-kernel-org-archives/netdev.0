From: Nogah Frankel <nogahf@mellanox.com>
Subject: [PATCH iproute2 v4 4/4] ifstat: Add "sw only" extended statistics to ifstat
Date: Thu, 12 Jan 2017 15:49:51 +0200
Message-ID: <1484228991-32999-5-git-send-email-nogahf@mellanox.com>
References: <1484228991-32999-1-git-send-email-nogahf@mellanox.com>
Cc: stephen@networkplumber.org, roszenrami@gmail.com,
        roopa@cumulusnetworks.com, jiri@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com,
        Nogah Frankel <nogahf@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:44272 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750981AbdALNq7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 08:46:59 -0500
In-Reply-To: <1484228991-32999-1-git-send-email-nogahf@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for extended statistics of SW only type, for counting only the
packets that went via the cpu. (useful for systems with forward
offloading). It reads it from filter type IFLA_STATS_LINK_OFFLOAD_XSTATS
and sub type IFLA_OFFLOAD_XSTATS_CPU_HIT.

It is under the name 'cpu_hits'
(or any shorten of it as 'cpu' or simply 'c')

For example:
ifstat -x c

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Reviewed-by: Jiri Pirko <jiri@mellanox.com>
---
 misc/ifstat.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/misc/ifstat.c b/misc/ifstat.c
index 3478f0a..5b6a36b 100644
--- a/misc/ifstat.c
+++ b/misc/ifstat.c
@@ -730,7 +730,8 @@ static void xstat_usage(void)
 {
 	fprintf(stderr,
 "Usage: ifstat supported xstats:\n"
-"       64bits         default stats, with 64 bits support\n");
+"       64bits         default stats, with 64 bits support\n"
+"       cpu_hits       Counts only packets that went via the CPU.\n");
 }
 
 struct extended_stats_options_t {
@@ -745,6 +746,7 @@ struct extended_stats_options_t {
  */
 static const struct extended_stats_options_t extended_stats_options[] = {
 	{"64bits", IFLA_STATS_LINK_64, NO_SUB_TYPE},
+	{"cpu_hits",  IFLA_STATS_LINK_OFFLOAD_XSTATS, IFLA_OFFLOAD_XSTATS_CPU_HIT},
 };
 
 static const char *get_filter_type(const char *name)
-- 
2.4.3
