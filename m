From: Dmitrii Shcherbakov <fw.dmitrii@yandex.com>
Subject: [PATCH 1/2] [iproute2] tc/q_htb.c: remove printing of a deprecated overhead value previously encoded as a part of mpu field
Date: Sat, 19 Dec 2015 18:25:52 +0300
Message-ID: <3134751450538752@web30j.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	Phil Sutter <phil@nwl.cc>,
	Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward11j.cmail.yandex.net ([5.255.227.175]:35775 "EHLO
	forward11j.cmail.yandex.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933222AbbLSPZ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Dec 2015 10:25:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove printing according to the previously used encoding of mpu and overhead values within the tc_ratespec's mpu field. This encoding is no longer being used as a separate 'overhead' field in the ratespec structure has been introduced.

Signed-off-by: Dmitrii Shcherbakov <fw.dmitrii@yandex.com>
Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>
Acked-by: Phil Sutter <phil@nwl.cc>
---
 tc/q_htb.c | 11 ++++-------
 1 file changed, 4 insertions(+), 7 deletions(-)

diff --git a/tc/q_htb.c b/tc/q_htb.c
index 7075a4c..e76d20a 100644
--- a/tc/q_htb.c
+++ b/tc/q_htb.c
@@ -273,7 +273,6 @@ static int htb_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 	__u64 rate64, ceil64;
 	SPRINT_BUF(b1);
 	SPRINT_BUF(b2);
-	SPRINT_BUF(b3);
 	SPRINT_BUF(b4);
 
 	if (opt == NULL)
@@ -313,16 +312,14 @@ static int htb_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 		if (linklayer > TC_LINKLAYER_ETHERNET || show_details)
 			fprintf(f, "linklayer %s ", sprint_linklayer(linklayer, b4));
 		if (show_details) {
-			fprintf(f, "burst %s/%u mpu %s overhead %s ",
+			fprintf(f, "burst %s/%u mpu %s ",
 				sprint_size(buffer, b1),
 				1<<hopt->rate.cell_log,
-				sprint_size(hopt->rate.mpu&0xFF, b2),
-				sprint_size((hopt->rate.mpu>>8)&0xFF, b3));
-			fprintf(f, "cburst %s/%u mpu %s overhead %s ",
+				sprint_size(hopt->rate.mpu, b2));
+			fprintf(f, "cburst %s/%u mpu %s ",
 				sprint_size(cbuffer, b1),
 				1<<hopt->ceil.cell_log,
-				sprint_size(hopt->ceil.mpu&0xFF, b2),
-				sprint_size((hopt->ceil.mpu>>8)&0xFF, b3));
+				sprint_size(hopt->ceil.mpu, b2));
 			fprintf(f, "level %d ", (int)hopt->level);
 		} else {
 			fprintf(f, "burst %s ", sprint_size(buffer, b1));
-- 
2.5.0
