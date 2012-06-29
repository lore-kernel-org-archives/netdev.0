From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next v2 3/4] team: use IFF_LIVE_ADDR_CHANGE priv_flag
Date: Fri, 29 Jun 2012 17:10:07 +0200
Message-ID: <1340982608-897-4-git-send-email-jpirko@redhat.com>
References: <1340982608-897-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, rusty@rustcorp.com.au, mst@redhat.com,
	virtualization@lists.linux-foundation.org, edumazet@google.com,
	danny.kukawka@bisect.de, shimoda.hiroaki@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7834 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755548Ab2F2PKU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jun 2012 11:10:20 -0400
In-Reply-To: <1340982608-897-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/team/team.c |    9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 89853c3..9b94f53 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1188,10 +1188,11 @@ static int team_set_mac_address(struct net_device *dev, void *p)
 {
 	struct team *team = netdev_priv(dev);
 	struct team_port *port;
-	struct sockaddr *addr = p;
+	int err;
 
-	dev->addr_assign_type &= ~NET_ADDR_RANDOM;
-	memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
+	err = eth_mac_addr(dev, p);
+	if (err)
+		return err;
 	rcu_read_lock();
 	list_for_each_entry_rcu(port, &team->port_list, list)
 		if (team->ops.port_change_mac)
@@ -1393,7 +1394,7 @@ static void team_setup(struct net_device *dev)
 	 * bring us to promisc mode in case a unicast addr is added.
 	 * Let this up to underlay drivers.
 	 */
-	dev->priv_flags |= IFF_UNICAST_FLT;
+	dev->priv_flags |= IFF_UNICAST_FLT | IFF_LIVE_ADDR_CHANGE;
 
 	dev->features |= NETIF_F_LLTX;
 	dev->features |= NETIF_F_GRO;
-- 
1.7.10.4
