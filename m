From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH net-next] net: em_canid: remove useless statements from em_canid_change
Date: Wed, 18 Jun 2014 16:48:39 +0800
Message-ID: <53A15267.7050304@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Rostislav Lisovy <lisovy@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([59.151.112.132]:50851 "EHLO
	heian.cn.fujitsu.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S934202AbaFRIvv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2014 04:51:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


tcf_ematch is allocated by kzalloc in function tcf_em_tree_validate(),
so cm_old is always NULL.

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---
 net/sched/em_canid.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/net/sched/em_canid.c b/net/sched/em_canid.c
index bfd34e4..7c292d4 100644
--- a/net/sched/em_canid.c
+++ b/net/sched/em_canid.c
@@ -125,7 +125,6 @@ static int em_canid_change(struct tcf_proto *tp, void *data, int len,
 {
 	struct can_filter *conf = data; /* Array with rules */
 	struct canid_match *cm;
-	struct canid_match *cm_old = (struct canid_match *)m->data;
 	int i;
 
 	if (!len)
@@ -181,12 +180,6 @@ static int em_canid_change(struct tcf_proto *tp, void *data, int len,
 
 	m->datalen = sizeof(struct canid_match) + len;
 	m->data = (unsigned long)cm;
-
-	if (cm_old != NULL) {
-		pr_err("canid: Configuring an existing ematch!\n");
-		kfree(cm_old);
-	}
-
 	return 0;
 }
 
-- 
1.8.3.1
