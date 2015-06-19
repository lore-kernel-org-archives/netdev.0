From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 06/12] netfilter: Kill unused copies of RCV_SKB_FAIL
Date: Fri, 19 Jun 2015 19:17:43 +0200
Message-ID: <1434734269-4545-7-git-send-email-pablo@netfilter.org>
References: <1434734269-4545-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:55533 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754725AbbFSRMg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Jun 2015 13:12:36 -0400
In-Reply-To: <1434734269-4545-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eric W. Biederman" <ebiederm@xmission.com>

This appears to have been a dead macro in both nfnetlink_log.c and
nfnetlink_queue_core.c since these pieces of code were added in 2005.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink_log.c        |    2 --
 net/netfilter/nfnetlink_queue_core.c |    2 --
 2 files changed, 4 deletions(-)

diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 4ef1fae..4670821 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -598,8 +598,6 @@ nla_put_failure:
 	return -1;
 }
 
-#define RCV_SKB_FAIL(err) do { netlink_ack(skb, nlh, (err)); return; } while (0)
-
 static struct nf_loginfo default_loginfo = {
 	.type =		NF_LOG_TYPE_ULOG,
 	.u = {
diff --git a/net/netfilter/nfnetlink_queue_core.c b/net/netfilter/nfnetlink_queue_core.c
index 6eccf0f..e26a46e 100644
--- a/net/netfilter/nfnetlink_queue_core.c
+++ b/net/netfilter/nfnetlink_queue_core.c
@@ -834,8 +834,6 @@ nfqnl_dev_drop(struct net *net, int ifindex)
 	rcu_read_unlock();
 }
 
-#define RCV_SKB_FAIL(err) do { netlink_ack(skb, nlh, (err)); return; } while (0)
-
 static int
 nfqnl_rcv_dev_event(struct notifier_block *this,
 		    unsigned long event, void *ptr)
-- 
1.7.10.4
