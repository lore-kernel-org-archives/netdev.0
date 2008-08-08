From: jamal <hadi@cyberus.ca>
Subject: [PATCH]:net-sched: fix Action flushing return code
Date: Fri, 08 Aug 2008 09:47:05 -0400
Message-ID: <1218203225.4688.56.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-4dExTCgpavKejMyVx5Pa"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.30]:10015 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757790AbYHHNrc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Aug 2008 09:47:32 -0400
Received: by yx-out-2324.google.com with SMTP id 8so235675yxm.1
        for <netdev@vger.kernel.org>; Fri, 08 Aug 2008 06:47:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-4dExTCgpavKejMyVx5Pa
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

This depends on previous patch "net-sched: Fix actions flushing".
Sorry - i noticed the discrepancy on the return codes only after i sent
the earlier patch.

cheers,
jamal

--=-4dExTCgpavKejMyVx5Pa
Content-Disposition: attachment; filename=act_f2
Content-Type: text/plain; name=act_f2; charset=us-ascii
Content-Transfer-Encoding: 7bit

net-sched: fix Action flushing return code

Flushing must consistently return ENOMEM on failure of any allocation

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

---
commit 0ca9612919f1e4e579915f947dae05858d3b40f2
tree 5915d47665f6408042a805f45a1b4872be97c8ef
parent 4e13e943acd2aa262e1e10c7779518d3ca18cae3
author Jamal Hadi Salim <hadi@cyberus.ca> Fri, 08 Aug 2008 09:44:22 -0400
committer Jamal Hadi Salim <hadi@cyberus.ca> Fri, 08 Aug 2008 09:44:22 -0400

 net/sched/act_api.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index 88b5733..9974b3f 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -751,7 +751,7 @@ static int tca_action_flush(struct nlattr *nla, struct nlmsghdr *n, u32 pid)
 	struct nlattr *tb[TCA_ACT_MAX+1];
 	struct nlattr *kind;
 	struct tc_action *a = create_a(0);
-	int err = -EINVAL;
+	int err = -ENOMEM;
 
 	if (a == NULL) {
 		printk("tca_action_flush: couldnt create tc_action\n");
@@ -762,7 +762,7 @@ static int tca_action_flush(struct nlattr *nla, struct nlmsghdr *n, u32 pid)
 	if (!skb) {
 		printk("tca_action_flush: failed skb alloc\n");
 		kfree(a);
-		return -ENOBUFS;
+		return err;
 	}
 
 	b = skb_tail_pointer(skb);

--=-4dExTCgpavKejMyVx5Pa--

