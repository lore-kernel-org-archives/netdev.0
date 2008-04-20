From: jamal <hadi@cyberus.ca>
Subject: [PATCH 2/3] [TC/FILTERS] Expose the filter protocol
Date: Sun, 20 Apr 2008 10:47:48 -0400
Message-ID: <1208702868.12249.54.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-vmGxH8m/62oUJhW/PUvR"
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.250]:53687 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753541AbYDTOrx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Apr 2008 10:47:53 -0400
Received: by an-out-0708.google.com with SMTP id d31so383784and.103
        for <netdev@vger.kernel.org>; Sun, 20 Apr 2008 07:47:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-vmGxH8m/62oUJhW/PUvR
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


makes protocol accessible ..

cheers,
jamal

--=-vmGxH8m/62oUJhW/PUvR
Content-Disposition: attachment; filename=0002-TC-FILTERS-Expose-the-filter-protocol.txt
Content-Type: text/plain; name=0002-TC-FILTERS-Expose-the-filter-protocol.txt; charset=us-ascii
Content-Transfer-Encoding: 7bit

[PATCH 2/3] [TC/FILTERS] Expose the filter protocol

Expose the filter protocol so it can be used by underlying
classifiers when they need it.

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>
---
 tc/tc_filter.c |    9 +++++----
 tc/tc_util.h   |    1 +
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/tc/tc_filter.c b/tc/tc_filter.c
index 6701f9a..db44dec 100644
--- a/tc/tc_filter.c
+++ b/tc/tc_filter.c
@@ -175,6 +175,7 @@ static __u32 filter_parent;
 static int filter_ifindex;
 static __u32 filter_prio;
 static __u32 filter_protocol;
+__u16 f_proto = 0;
 
 int print_filter(const struct sockaddr_nl *who,
 			struct nlmsghdr *n,
@@ -221,13 +222,13 @@ int print_filter(const struct sockaddr_nl *who,
 		}
 	}
 	if (t->tcm_info) {
-		__u32 protocol = TC_H_MIN(t->tcm_info);
+		f_proto = TC_H_MIN(t->tcm_info);
 		__u32 prio = TC_H_MAJ(t->tcm_info)>>16;
-		if (!filter_protocol || filter_protocol != protocol) {
-			if (protocol) {
+		if (!filter_protocol || filter_protocol != f_proto) {
+			if (f_proto) {
 				SPRINT_BUF(b1);
 				fprintf(fp, "protocol %s ",
-					ll_proto_n2a(protocol, b1, sizeof(b1)));
+					ll_proto_n2a(f_proto, b1, sizeof(b1)));
 			}
 		}
 		if (!filter_prio || filter_prio != prio) {
diff --git a/tc/tc_util.h b/tc/tc_util.h
index 301b5c7..796da54 100644
--- a/tc/tc_util.h
+++ b/tc/tc_util.h
@@ -19,6 +19,7 @@ struct qdisc_util
 	int	(*print_copt)(struct qdisc_util *qu, FILE *f, struct rtattr *opt);
 };
 
+extern __u16 f_proto;
 struct filter_util
 {
 	struct filter_util *next;
-- 
1.4.4.1.gaed4


--=-vmGxH8m/62oUJhW/PUvR--

