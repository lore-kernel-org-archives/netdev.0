From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH] rtnetlink: Mask the rta_type when range checking
Date: Wed, 13 Mar 2013 10:18:58 -0400
Message-ID: <1363184338-15781-1-git-send-email-vyasevic@redhat.com>
Cc: davem@davemloft.net, Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13760 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933128Ab3CMOTE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Mar 2013 10:19:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Range/validity checks on rta_type in rtnetlink_rcv_msg() do
not account for flags that may be set.  This causes the function
to return -EINVAL when flags are set on the type (for example
NLA_F_NESTED).

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/core/rtnetlink.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 1868625..dc5edf1 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2538,7 +2538,7 @@ static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 		struct rtattr *attr = (void *)nlh + NLMSG_ALIGN(min_len);
 
 		while (RTA_OK(attr, attrlen)) {
-			unsigned int flavor = attr->rta_type;
+			unsigned int flavor = attr->rta_type & NLA_TYPE_MASK;
 			if (flavor) {
 				if (flavor > rta_max[sz_idx])
 					return -EINVAL;
-- 
1.7.7.6
