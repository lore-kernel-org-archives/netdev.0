From: Dan Carpenter <error27@gmail.com>
Subject: [patch] net/sched: remove unneeded NULL check
Date: Sat, 14 Aug 2010 23:09:49 +0200
Message-ID: <20100814210949.GB645@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Jarek Poplawski <jarkao2@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Jamal Hadi Salim <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:36801 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755614Ab0HNVKc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Aug 2010 17:10:32 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no need to check "s".  nla_data() doesn't return NULL.  Also we
already dereferenced "s" at this point so it would have oopsed ealier if
it were NULL.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 408eea7..6fb3d41 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -360,7 +360,7 @@ static struct qdisc_size_table *qdisc_get_stab(struct nlattr *opt)
 		tsize = nla_len(tb[TCA_STAB_DATA]) / sizeof(u16);
 	}
 
-	if (!s || tsize != s->tsize || (!tab && tsize > 0))
+	if (tsize != s->tsize || (!tab && tsize > 0))
 		return ERR_PTR(-EINVAL);
 
 	spin_lock(&qdisc_stab_lock);
