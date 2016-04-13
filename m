From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH RFC 1/2] tun: don't require serialization lock on tx
Date: Wed, 13 Apr 2016 11:04:46 +0200
Message-ID: <425e8f69ffd8fe315ef9d3cc678519c7060fb2e0.1460393493.git.pabeni@redhat.com>
References: <cover.1460393493.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Greg Kurz <gkurz@linux.vnet.ibm.com>,
	Jason Wang <jasowang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37242 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759644AbcDMJFG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2016 05:05:06 -0400
In-Reply-To: <cover.1460393493.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current tun_net_xmit() implementation don't need any external
lock since it relay on rcu protection for the tun data structure
and on socket queue lock for skb queuing.

This patch set the NETIF_F_LLTX feature bit in the tun device, so
that on xmit, in absence of qdisc, no serialization lock is acquired
by the caller.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 drivers/net/tun.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index faf9297..42992dc 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1796,7 +1796,7 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 		dev->hw_features = NETIF_F_SG | NETIF_F_FRAGLIST |
 				   TUN_USER_FEATURES | NETIF_F_HW_VLAN_CTAG_TX |
 				   NETIF_F_HW_VLAN_STAG_TX;
-		dev->features = dev->hw_features;
+		dev->features = dev->hw_features | NETIF_F_LLTX;
 		dev->vlan_features = dev->features &
 				     ~(NETIF_F_HW_VLAN_CTAG_TX |
 				       NETIF_F_HW_VLAN_STAG_TX);
-- 
1.8.3.1
