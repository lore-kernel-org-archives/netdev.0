From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: [PATCH net-next v5 5/6] rtnetlink: allow using zero MAC address in rtnl_fdb_{add,del}
Date: Tue, 25 Jun 2013 16:01:55 +0300
Message-ID: <1372165316-17647-6-git-send-email-mike.rapoport@ravellosystems.com>
References: <1372165316-17647-1-git-send-email-mike.rapoport@ravellosystems.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	David Stevens <dlstevens@us.ibm.com>,
	Thomas Graf <tgraf@suug.ch>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Mike Rapoport <mike.rapoport@ravellosystems.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog104.obsmtp.com ([74.125.245.76]:53125 "HELO
	na3sys010aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751784Ab3FYNC2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jun 2013 09:02:28 -0400
Received: by mail-wg0-f54.google.com with SMTP id n11so9144142wgh.21
        for <netdev@vger.kernel.org>; Tue, 25 Jun 2013 06:02:26 -0700 (PDT)
In-Reply-To: <1372165316-17647-1-git-send-email-mike.rapoport@ravellosystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is required for multiple default destinations management in VXLAN

Signed-off-by: Mike Rapoport <mike.rapoport@ravellosystems.com>
---
 net/core/rtnetlink.c | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 9007533..3de7408 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2109,10 +2109,6 @@ static int rtnl_fdb_add(struct sk_buff *skb, struct nlmsghdr *nlh)
 	}
 
 	addr = nla_data(tb[NDA_LLADDR]);
-	if (is_zero_ether_addr(addr)) {
-		pr_info("PF_BRIDGE: RTM_NEWNEIGH with invalid ether address\n");
-		return -EINVAL;
-	}
 
 	err = -EOPNOTSUPP;
 
@@ -2210,10 +2206,6 @@ static int rtnl_fdb_del(struct sk_buff *skb, struct nlmsghdr *nlh)
 	}
 
 	addr = nla_data(tb[NDA_LLADDR]);
-	if (is_zero_ether_addr(addr)) {
-		pr_info("PF_BRIDGE: RTM_DELNEIGH with invalid ether address\n");
-		return -EINVAL;
-	}
 
 	err = -EOPNOTSUPP;
 
-- 
1.8.1.5
