From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 1/3] net: make default TX queue length a defined
 constant
Date: Thu, 03 Nov 2016 14:56:01 +0100
Message-ID: <20161103135601.28737.94881.stgit@firesoul>
References: <20161103135534.28737.37657.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Phil Sutter <phil@nwl.cc>, Robert Olsson <robert@herjulf.se>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47860 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754583AbcKCN4E (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 3 Nov 2016 09:56:04 -0400
In-Reply-To: <20161103135534.28737.37657.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The default TX queue length of Ethernet devices have been a magic
constant of 1000, ever since the initial git import.

Looking back in historical trees[1][2] the value used to be 100,
with the same comment "Ethernet wants good queues". The commit[3]
that changed this from 100 to 1000 didn't describe why, but from
conversations with Robert Olsson it seems that it was changed
when Ethernet devices went from 100Mbit/s to 1Gbit/s, because the
link speed increased x10 the queue size were also adjusted.  This
value later caused much heartache for the bufferbloat community.

This patch merely moves the value into a defined constant.

[1] https://git.kernel.org/cgit/linux/kernel/git/davem/netdev-vger-cvs.git/
[2] https://git.kernel.org/cgit/linux/kernel/git/tglx/history.git/
[3] https://git.kernel.org/tglx/history/c/98921832c232

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 include/net/pkt_sched.h |    2 ++
 net/ethernet/eth.c      |    3 ++-
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index cd334c9584e9..f1b76b8e6d2d 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -6,6 +6,8 @@
 #include <linux/if_vlan.h>
 #include <net/sch_generic.h>
 
+#define DEFAULT_TX_QUEUE_LEN	1000
+
 struct qdisc_walker {
 	int	stop;
 	int	skip;
diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index d9e2fe1da724..8c5a479681ca 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -62,6 +62,7 @@
 #include <net/dsa.h>
 #include <net/flow_dissector.h>
 #include <linux/uaccess.h>
+#include <net/pkt_sched.h>
 
 __setup("ether=", netdev_boot_setup);
 
@@ -359,7 +360,7 @@ void ether_setup(struct net_device *dev)
 	dev->min_mtu		= ETH_MIN_MTU;
 	dev->max_mtu		= ETH_DATA_LEN;
 	dev->addr_len		= ETH_ALEN;
-	dev->tx_queue_len	= 1000;	/* Ethernet wants good queues */
+	dev->tx_queue_len	= DEFAULT_TX_QUEUE_LEN;
 	dev->flags		= IFF_BROADCAST|IFF_MULTICAST;
 	dev->priv_flags		|= IFF_TX_SKB_SHARING;
 
