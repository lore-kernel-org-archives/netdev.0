From: pablo@netfilter.org
Subject: [PATCH 2/2] netfilter: ipset: "Directory not empty" error message
Date: Tue, 26 Feb 2013 14:45:20 +0100
Message-ID: <1361886320-9492-3-git-send-email-pablo@netfilter.org>
References: <1361886320-9492-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from slan-550-85.anhosting.com ([209.236.71.68]:56221 "EHLO
	slan-550-85.anhosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751503Ab3BZNpj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2013 08:45:39 -0500
In-Reply-To: <1361886320-9492-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

When an entry flagged with "nomatch" was tested by ipset, it
returned the error message "Kernel error received:
Directory not empty" instead of "<element> is NOT in set <setname>"
(reported by John Brendler).

The internal error code was not properly transformed before returning
to userspace, fixed.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 net/netfilter/ipset/ip_set_core.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/ipset/ip_set_core.c b/net/netfilter/ipset/ip_set_core.c
index 6d6d8f2..38ca630 100644
--- a/net/netfilter/ipset/ip_set_core.c
+++ b/net/netfilter/ipset/ip_set_core.c
@@ -1470,7 +1470,8 @@ ip_set_utest(struct sock *ctnl, struct sk_buff *skb,
 	if (ret == -EAGAIN)
 		ret = 1;
 
-	return ret < 0 ? ret : ret > 0 ? 0 : -IPSET_ERR_EXIST;
+	return (ret < 0 && ret != -ENOTEMPTY) ? ret :
+		ret > 0 ? 0 : -IPSET_ERR_EXIST;
 }
 
 /* Get headed data of a set */
-- 
1.7.10.4
