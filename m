From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 4/7] No need to initialize rtattr fields before parsing
Date: Tue, 21 Jun 2016 18:18:38 +0200
Message-ID: <1466525921-15738-5-git-send-email-phil@nwl.cc>
References: <1466525921-15738-1-git-send-email-phil@nwl.cc>
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	David Ahern <dsa@cumulusnetworks.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Julien Floret <julien.floret@6wind.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:54991 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752417AbcFUQ1l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jun 2016 12:27:41 -0400
In-Reply-To: <1466525921-15738-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since parse_rtattr_flags() calls memset already, there is no need for
callers to do so themselves.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/ipaddress.c | 2 +-
 tc/tc_class.c  | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index afb115e5f592a..643e9133e47b2 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -439,7 +439,7 @@ static void print_num(FILE *fp, unsigned int width, uint64_t count)
 
 static void print_vf_stats64(FILE *fp, struct rtattr *vfstats)
 {
-	struct rtattr *vf[IFLA_VF_STATS_MAX + 1] = {};
+	struct rtattr *vf[IFLA_VF_STATS_MAX + 1];
 
 	if (vfstats->rta_type != IFLA_VF_STATS) {
 		fprintf(stderr, "BUG: rta type is %d\n", vfstats->rta_type);
diff --git a/tc/tc_class.c b/tc/tc_class.c
index 523fafb35dd44..1b79b03efc038 100644
--- a/tc/tc_class.c
+++ b/tc/tc_class.c
@@ -221,7 +221,7 @@ static void graph_cls_show(FILE *fp, char *buf, struct hlist_head *root_list,
 {
 	struct hlist_node *n, *tmp_cls;
 	char cls_id_str[256] = {};
-	struct rtattr *tb[TCA_MAX + 1] = {};
+	struct rtattr *tb[TCA_MAX + 1];
 	struct qdisc_util *q;
 	char str[100] = {};
 
@@ -306,7 +306,7 @@ int print_class(const struct sockaddr_nl *who,
 	FILE *fp = (FILE *)arg;
 	struct tcmsg *t = NLMSG_DATA(n);
 	int len = n->nlmsg_len;
-	struct rtattr *tb[TCA_MAX + 1] = {};
+	struct rtattr *tb[TCA_MAX + 1];
 	struct qdisc_util *q;
 	char abuf[256];
 
-- 
2.8.2
