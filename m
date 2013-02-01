From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH net-next 1/4]netns: fdb: allow unprivileged users to add/del fdb entries
Date: Fri, 1 Feb 2013 10:30:57 +0800
Message-ID: <1359685860-29636-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	ebiederm@xmission.com, serge@hallyn.com, pablo@netfilter.org,
	amwang@redhat.com, Gao feng <gaofeng@cn.fujitsu.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:3031 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754229Ab3BACam (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jan 2013 21:30:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Right now,only ixgdb,macvlan,vxlan and bridge implement
fdb_add/fdb_del operations.

these operations only operate the private data of net
device. So allowing the unprivileged users who creates
the userns and netns to add/del fdb entries will do no
harm to other netns.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/core/rtnetlink.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 9a419b0..c1e4db6 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2058,9 +2058,6 @@ static int rtnl_fdb_add(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 	u8 *addr;
 	int err;
 
-	if (!capable(CAP_NET_ADMIN))
-		return -EPERM;
-
 	err = nlmsg_parse(nlh, sizeof(*ndm), tb, NDA_MAX, NULL);
 	if (err < 0)
 		return err;
@@ -2127,9 +2124,6 @@ static int rtnl_fdb_del(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 	int err = -EINVAL;
 	__u8 *addr;
 
-	if (!capable(CAP_NET_ADMIN))
-		return -EPERM;
-
 	if (nlmsg_len(nlh) < sizeof(*ndm))
 		return -EINVAL;
 
-- 
1.7.11.7
