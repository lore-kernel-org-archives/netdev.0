From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 3/8] dcbnl: Remove now unused dcbnl_reply()
Date: Wed, 13 Jun 2012 14:54:56 +0200
Message-ID: <e1995599af2b8f79cf76dbf2cdaa941045c1712b.1339591572.git.tgraf@suug.ch>
References: <cover.1339591572.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, lucy.liu@intel.com,
	john.r.fastabend@intel.com, alexander.h.duyck@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46724 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753648Ab2FMMzI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2012 08:55:08 -0400
In-Reply-To: <cover.1339591572.git.tgraf@suug.ch>
In-Reply-To: <cover.1339591572.git.tgraf@suug.ch>
References: <cover.1339591572.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 net/dcb/dcbnl.c |   37 -------------------------------------
 1 files changed, 0 insertions(+), 37 deletions(-)

diff --git a/net/dcb/dcbnl.c b/net/dcb/dcbnl.c
index 5e392b8..5ed7167 100644
--- a/net/dcb/dcbnl.c
+++ b/net/dcb/dcbnl.c
@@ -224,43 +224,6 @@ static struct sk_buff *dcbnl_newmsg(int type, u8 cmd, u32 port, u32 seq,
 	return skb;
 }
 
-/* standard netlink reply call */
-static int dcbnl_reply(u8 value, u8 event, u8 cmd, u8 attr, u32 pid,
-                       u32 seq, u16 flags)
-{
-	struct sk_buff *dcbnl_skb;
-	struct dcbmsg *dcb;
-	struct nlmsghdr *nlh;
-	int ret = -EINVAL;
-
-	dcbnl_skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
-	if (!dcbnl_skb)
-		return ret;
-
-	nlh = NLMSG_NEW(dcbnl_skb, pid, seq, event, sizeof(*dcb), flags);
-
-	dcb = NLMSG_DATA(nlh);
-	dcb->dcb_family = AF_UNSPEC;
-	dcb->cmd = cmd;
-	dcb->dcb_pad = 0;
-
-	ret = nla_put_u8(dcbnl_skb, attr, value);
-	if (ret)
-		goto err;
-
-	/* end the message, assign the nlmsg_len. */
-	nlmsg_end(dcbnl_skb, nlh);
-	ret = rtnl_unicast(dcbnl_skb, &init_net, pid);
-	if (ret)
-		return -EINVAL;
-
-	return 0;
-nlmsg_failure:
-err:
-	kfree_skb(dcbnl_skb);
-	return ret;
-}
-
 static int dcbnl_getstate(struct net_device *netdev, struct nlmsghdr *nlh,
 			  u32 seq, struct nlattr **tb, struct sk_buff *skb)
 {
-- 
1.7.7.6
