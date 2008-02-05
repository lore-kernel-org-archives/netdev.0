From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 02/04]: cls_flow: fix key mask validity check
Date: Tue,  5 Feb 2008 15:29:41 +0100 (MET)
Message-ID: <20080205142904.13543.34586.sendpatchset@localhost.localdomain>
References: <20080205142902.13543.88604.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59221 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752317AbYBEO3n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 09:29:43 -0500
In-Reply-To: <20080205142902.13543.88604.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[NET_SCHED]: cls_flow: fix key mask validity check

Since we're using fls(), we need to check whether the value is non-zero first.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 2e5915ef51e55135522e59e041bb176432857d82
tree 9a42fac3d1646a378acdc91b55642b68c9d97dde
parent adfab462c5e0a32ffff274927bba4eec3afc6e35
author Patrick McHardy <kaber@trash.net> Tue, 05 Feb 2008 15:22:23 +0100
committer Patrick McHardy <kaber@trash.net> Tue, 05 Feb 2008 15:22:23 +0100

 net/sched/cls_flow.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index 8d76986..eeb223c 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -402,12 +402,13 @@ static int flow_change(struct tcf_proto *tp, unsigned long base,
 
 	if (tb[TCA_FLOW_KEYS]) {
 		keymask = nla_get_u32(tb[TCA_FLOW_KEYS]);
-		if (fls(keymask) - 1 > FLOW_KEY_MAX)
-			return -EOPNOTSUPP;
 
 		nkeys = hweight32(keymask);
 		if (nkeys == 0)
 			return -EINVAL;
+
+		if (fls(keymask) - 1 > FLOW_KEY_MAX)
+			return -EOPNOTSUPP;
 	}
 
 	err = tcf_exts_validate(tp, tb, tca[TCA_RATE], &e, &flow_ext_map);
