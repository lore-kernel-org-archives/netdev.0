From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next 3/6] netem: define NETEM_DIST_MAX
Date: Wed, 23 Feb 2011 15:04:19 -0800
Message-ID: <20110223230534.268429590@vyatta.com>
References: <20110223230416.532009518@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:47474 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754774Ab1BWXHt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Feb 2011 18:07:49 -0500
Content-Disposition: inline; filename=netem-maxsize.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rather than magic constant in code, expose the maximum size of
packet distribution table in API. In iproute2, q_netem defines
MAX_DIST as 16K already.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 include/linux/pkt_sched.h |    1 +
 net/sched/sch_netem.c     |    2 +-
 2 files changed, 2 insertions(+), 1 deletion(-)

--- a/include/linux/pkt_sched.h	2011-02-23 14:43:08.838297372 -0800
+++ b/include/linux/pkt_sched.h	2011-02-23 14:50:10.329760558 -0800
@@ -495,6 +495,7 @@ struct tc_netem_corrupt {
 };
 
 #define NETEM_DIST_SCALE	8192
+#define NETEM_DIST_MAX		16384
 
 /* DRR */
 
--- a/net/sched/sch_netem.c	2011-02-23 14:50:09.445745344 -0800
+++ b/net/sched/sch_netem.c	2011-02-23 14:50:10.329760558 -0800
@@ -332,7 +332,7 @@ static int get_dist_table(struct Qdisc *
 	int i;
 	size_t s;
 
-	if (n > 65536)
+	if (n > NETEM_DIST_MAX)
 		return -EINVAL;
 
 	s = sizeof(struct disttable) + n * sizeof(s16);


