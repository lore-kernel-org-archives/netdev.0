From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 03/15]: act_api: fix netlink API conversion bug
Date: Wed, 23 Jan 2008 17:36:39 +0100 (MET)
Message-ID: <20080123163559.6459.91294.sendpatchset@localhost.localdomain>
References: <20080123163555.6459.69501.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49717 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752873AbYAWQgl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2008 11:36:41 -0500
In-Reply-To: <20080123163555.6459.69501.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[NET_SCHED]: act_api: fix netlink API conversion bug

Fix two invalid attribute accesses, indices start at 1 with the new
netlink API.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 512b2ab20730e1d24e36fb94eab4a2731e90e315
tree e3583125570ee0c7a57feac7aa6fcabe2541112a
parent 1af28b79f4f0a67db344938ef6739ad2af1a72a7
author Patrick McHardy <kaber@trash.net> Wed, 23 Jan 2008 17:10:00 +0100
committer Patrick McHardy <kaber@trash.net> Wed, 23 Jan 2008 17:10:00 +0100

 net/sched/act_api.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index ebd21d2..ae077ed 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -997,11 +997,11 @@ find_dump_kind(struct nlmsghdr *n)
 	if (nla_parse(tb, TCA_ACT_MAX_PRIO, nla_data(tb1),
 		      NLMSG_ALIGN(nla_len(tb1)), NULL) < 0)
 		return NULL;
-	if (tb[0] == NULL)
-		return NULL;
 
-	if (nla_parse(tb2, TCA_ACT_MAX, nla_data(tb[0]),
-		      nla_len(tb[0]), NULL) < 0)
+	if (tb[1] == NULL)
+		return NULL;
+	if (nla_parse(tb2, TCA_ACT_MAX, nla_data(tb[1]),
+		      nla_len(tb[1]), NULL) < 0)
 		return NULL;
 	kind = tb2[TCA_ACT_KIND];
 
