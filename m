From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net] mpls: fix rtm policy in mpls_getroute
Date: Tue,  4 Jul 2017 17:03:02 -0700
Message-ID: <1499212982-12970-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, dsahern@gmail.com, rshearma@brocade.com,
        nikolay@cumulusnetworks.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:35421 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752395AbdGEADO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Jul 2017 20:03:14 -0400
Received: by mail-pg0-f46.google.com with SMTP id j186so115491328pge.2
        for <netdev@vger.kernel.org>; Tue, 04 Jul 2017 17:03:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

fix rtm policy name typo in mpls_getroute and also remove
export of rtm_ipv4_policy

Fixes: 397fc9e5cefe ("mpls: route get support")
Reported-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
David, since the rtm_ipv4_policy export is not in net yet
and assuming it will soon be there, I have generated this
patch against net-next, but addressed it to net. Thanks.

 net/ipv4/fib_frontend.c | 1 -
 net/mpls/af_mpls.c      | 2 +-
 2 files changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 1b5860f..4e678fa 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -626,7 +626,6 @@ int ip_rt_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 	[RTA_UID]		= { .type = NLA_U32 },
 	[RTA_MARK]		= { .type = NLA_U32 },
 };
-EXPORT_SYMBOL_GPL(rtm_ipv4_policy);
 
 static int rtm_to_fib_config(struct net *net, struct sk_buff *skb,
 			     struct nlmsghdr *nlh, struct fib_config *cfg,
diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index e17d6cd..bdcfb2d 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -2091,7 +2091,7 @@ static int mpls_getroute(struct sk_buff *in_skb, struct nlmsghdr *in_nlh,
 	u8 n_labels;
 
 	err = nlmsg_parse(in_nlh, sizeof(*rtm), tb, RTA_MAX,
-			  rtm_ipv4_policy, extack);
+			  rtm_mpls_policy, extack);
 	if (err < 0)
 		goto errout;
 
-- 
1.9.1
