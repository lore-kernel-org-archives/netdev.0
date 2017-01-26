From: Nogah Frankel <nogahf@mellanox.com>
Subject: [PATCH iproute2 v5 3/4] ifstat: Add "sw only" extended statistics to ifstat
Date: Thu, 26 Jan 2017 14:44:40 +0200
Message-ID: <1485434681-33947-4-git-send-email-nogahf@mellanox.com>
References: <1485434681-33947-1-git-send-email-nogahf@mellanox.com>
Cc: stephen@networkplumber.org, roopa@cumulusnetworks.com,
        roszenrami@gmail.com, jbenc@redhat.com,
        sergei.shtylyov@cogentembedded.com, jiri@mellanox.com,
        eladr@mellanox.com, idosch@mellanox.com, yotamg@mellanox.com,
        ogerlitz@mellanox.com, Nogah Frankel <nogahf@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:51774 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752054AbdAZMnH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 07:43:07 -0500
In-Reply-To: <1485434681-33947-1-git-send-email-nogahf@mellanox.com>
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
index 9467119..a853ee6 100644
--- a/misc/ifstat.c
+++ b/misc/ifstat.c
@@ -729,7 +729,8 @@ static int verify_forging(int fd)
 static void xstat_usage(void)
 {
 	fprintf(stderr,
-"Usage: ifstat supported xstats:\n");
+"Usage: ifstat supported xstats:\n"
+"       cpu_hits       Counts only packets that went via the CPU.\n");
 }
 
 struct extended_stats_options_t {
@@ -743,6 +744,7 @@ struct extended_stats_options_t {
  * Name length must be under 64 chars.
  */
 static const struct extended_stats_options_t extended_stats_options[] = {
+	{"cpu_hits",  IFLA_STATS_LINK_OFFLOAD_XSTATS, IFLA_OFFLOAD_XSTATS_CPU_HIT},
 };
 
 static const char *get_filter_type(const char *name)
-- 
2.4.3
