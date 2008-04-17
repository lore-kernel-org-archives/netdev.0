From: Roel Kluin <12o3l@tiscali.nl>
Subject: [PATCH] NET: catch signed nla_len() retval in tcf_simp_init()
Date: Thu, 17 Apr 2008 05:33:21 +0200
Message-ID: <4806C501.20300@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: hadi@cyberus.ca, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756950AbYDQDdk@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

'datalen' is unsigned, use 'ret' instead to catch a negative return value.

Signed-off-by: Roel Kluin <12o3l@tiscali.nl>
---
diff --git a/net/sched/act_simple.c b/net/sched/act_simple.c
index fbde461..b78d015 100644
--- a/net/sched/act_simple.c
+++ b/net/sched/act_simple.c
@@ -114,9 +114,10 @@ static int tcf_simp_init(struct nlattr *nla, struct nlattr *est,
 	if (defdata == NULL)
 		return -EINVAL;
 
-	datalen = nla_len(tb[TCA_DEF_DATA]);
-	if (datalen <= 0)
+	ret = nla_len(tb[TCA_DEF_DATA]);
+	if (ret <= 0)
 		return -EINVAL;
+	datalen = ret;
 
 	pc = tcf_hash_check(parm->index, a, bind, &simp_hash_info);
 	if (!pc) {
