From: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>
Subject: [PATCH] [IPV6] fixed the size of the netlink message notified by
 inet6_rt_notify().
Date: Tue, 16 Jan 2007 12:57:28 +0900 (JST)
Message-ID: <20070116.125728.278729390.takamiya@po.ntts.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.ics.ntts.co.jp ([202.32.24.42]:60847 "EHLO
	mail2.ics.ntts.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932247AbXAPD5u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jan 2007 22:57:50 -0500
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

  I think the return value of rt6_nlmsg_size() should includes the
  amount of RTA_METRICS.

  Regards,

---
 net/ipv6/route.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 8c3d568..5f0043c 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2017,6 +2017,7 @@ static inline size_t rt6_nlmsg_size(void
 	       + nla_total_size(4) /* RTA_IIF */
 	       + nla_total_size(4) /* RTA_OIF */
 	       + nla_total_size(4) /* RTA_PRIORITY */
+	       + RTAX_MAX * nla_total_size(4) /* RTA_METRICS */
 	       + nla_total_size(sizeof(struct rta_cacheinfo));
 }
 
-- 
1.4.4

--
Noriaki TAKAMIYA
