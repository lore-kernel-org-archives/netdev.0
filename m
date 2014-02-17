From: Wangyufen <wangyufen@huawei.com>
Subject: [PATCH 4/4] ipv6:fix checkpatch errors with assignment in if condition
Date: Mon, 17 Feb 2014 16:53:35 +0800
Message-ID: <1392627215-12804-4-git-send-email-wangyufen@huawei.com>
References: <1392627215-12804-1-git-send-email-wangyufen@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:2179 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751970AbaBQIy2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 03:54:28 -0500
In-Reply-To: <1392627215-12804-1-git-send-email-wangyufen@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Yufen <wangyufen@huawei.com>


Signed-off-by: Wang Yufen <wangyufen@huawei.com>
---
 net/ipv6/addrlabel.c | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/net/ipv6/addrlabel.c b/net/ipv6/addrlabel.c
index d702406..731e1e1 100644
--- a/net/ipv6/addrlabel.c
+++ b/net/ipv6/addrlabel.c
@@ -504,12 +504,13 @@ static int ip6addrlbl_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	hlist_for_each_entry_rcu(p, &ip6addrlbl_table.head, list) {
 		if (idx >= s_idx &&
 		    net_eq(ip6addrlbl_net(p), net)) {
-			if ((err = ip6addrlbl_fill(skb, p,
-						   ip6addrlbl_table.seq,
-						   NETLINK_CB(cb->skb).portid,
-						   cb->nlh->nlmsg_seq,
-						   RTM_NEWADDRLABEL,
-						   NLM_F_MULTI)) <= 0)
+			err = ip6addrlbl_fill(skb, p,
+					      ip6addrlbl_table.seq,
+					      NETLINK_CB(cb->skb).portid,
+					      cb->nlh->nlmsg_seq,
+					      RTM_NEWADDRLABEL,
+					      NLM_F_MULTI);
+			if (err <= 0)
 				break;
 		}
 		idx++;
@@ -567,7 +568,8 @@ static int ip6addrlbl_get(struct sk_buff *in_skb, struct nlmsghdr *nlh)
 		goto out;
 	}
 
-	if (!(skb = nlmsg_new(ip6addrlbl_msgsize(), GFP_KERNEL))) {
+	skb = nlmsg_new(ip6addrlbl_msgsize(), GFP_KERNEL);
+	if (!skb) {
 		ip6addrlbl_put(p);
 		return -ENOBUFS;
 	}
-- 
1.7.12
