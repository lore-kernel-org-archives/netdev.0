From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH 20/21] net: warn if drivers set tx_queue_len = 0
Date: Tue, 18 Aug 2015 10:30:48 +0200
Message-ID: <1439886649-24166-21-git-send-email-phil@nwl.cc>
References: <1439886649-24166-1-git-send-email-phil@nwl.cc>
 <1439886649-24166-2-git-send-email-phil@nwl.cc>
 <1439886649-24166-3-git-send-email-phil@nwl.cc>
 <1439886649-24166-4-git-send-email-phil@nwl.cc>
 <1439886649-24166-5-git-send-email-phil@nwl.cc>
 <1439886649-24166-6-git-send-email-phil@nwl.cc>
 <1439886649-24166-7-git-send-email-phil@nwl.cc>
 <1439886649-24166-8-git-send-email-phil@nwl.cc>
 <1439886649-24166-9-git-send-email-phil@nwl.cc>
 <1439886649-24166-10-git-send-email-phil@nwl.cc>
 <1439886649-24166-11-git-send-email-phil@nwl.cc>
 <1439886649-24166-12-git-send-email-phil@nwl.cc>
 <1439886649-24166-13-git-send-email-phil@nwl.cc>
 <1439886649-24166-14-git-send-email-phil@nwl.cc>
 <1439886649-24166-15-git-send-email-phil@nwl.cc>
 <1439886649-24166-16-git-send-email-phil@nwl.cc>
 <1439886649-24166-17-git-send-email-phil@nwl.cc>
 <1439886649-24166-18-git-send-email-phil@nwl.cc>
 <1439886649-24166-19-git-send-email-phil@nwl.cc>
 <1439886649-24166-20-git-send-email-phil@nwl.cc>
Cc: brouer@redhat.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:39580 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752134AbbHRIa4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2015 04:30:56 -0400
In-Reply-To: <1439886649-24166-20-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Due to the introduction of IFF_NO_QUEUE, there is a better way for
drivers to indicate that no qdisc should be attached by default. Though,
the old convention can't be dropped since ignoring that setting would
break drivers still using it. Instead, add a warning so out-of-tree
driver maintainers get a chance to adjust their code before we finally
get rid of any special handling of tx_queue_len == 0.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 net/core/dev.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/core/dev.c b/net/core/dev.c
index 4870c35..b1f3f48 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6997,6 +6997,9 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
 	dev->priv_flags = IFF_XMIT_DST_RELEASE | IFF_XMIT_DST_RELEASE_PERM;
 	setup(dev);
 
+	if (!dev->tx_queue_len)
+		printk(KERN_WARNING "%s uses DEPRECATED zero tx_queue_len - convert driver to use IFF_NO_QUEUE instead.\n", name);
+
 	dev->num_tx_queues = txqs;
 	dev->real_num_tx_queues = txqs;
 	if (netif_alloc_netdev_queues(dev))
-- 
2.1.2
