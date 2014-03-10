From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 4/4] bonding: Convert memcpy(foo, bar, ETH_ALEN)
 to ether_addr_copy(foo, bar)
Date: Mon, 10 Mar 2014 10:49:45 +0100
Message-ID: <20140310094945.GA2864@minipsycho.orion>
References: <cover.1392508410.git.joe@perches.com>
 <0022868482b6f5a6d723992e0802470771066cb1.1392508410.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <0022868482b6f5a6d723992e0802470771066cb1.1392508410.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Many times, the original len ETH_ALEN was wrong. Bonding should work
with other types than Ethernet as well.


Sun, Feb 16, 2014 at 01:02:17AM CET, joe@perches.com wrote:
>ether_addr_copy is smaller and faster for some architectures.
>
>This relies on a stack frame being at least __aligned(2)
>for one use of an Ethernet address on the stack.
>
>Signed-off-by: Joe Perches <joe@perches.com>
>---
> drivers/net/bonding/bond_3ad.c  |  8 ++++----
> drivers/net/bonding/bond_alb.c  | 30 +++++++++++++++---------------
> drivers/net/bonding/bond_main.c | 12 ++++++------
> 3 files changed, 25 insertions(+), 25 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
>index f6eda2d..e9edd84 100644
>--- a/drivers/net/bonding/bond_3ad.c
>+++ b/drivers/net/bonding/bond_3ad.c
>@@ -768,11 +768,11 @@ static int ad_lacpdu_send(struct port *port)
> 
> 	lacpdu_header = (struct lacpdu_header *)skb_put(skb, length);
> 
>-	memcpy(lacpdu_header->hdr.h_dest, lacpdu_mcast_addr, ETH_ALEN);
>+	ether_addr_copy(lacpdu_header->hdr.h_dest, lacpdu_mcast_addr);
> 	/* Note: source address is set to be the member's PERMANENT address,
> 	 * because we use it to identify loopback lacpdus in receive.
> 	 */
>-	memcpy(lacpdu_header->hdr.h_source, slave->perm_hwaddr, ETH_ALEN);
>+	ether_addr_copy(lacpdu_header->hdr.h_source, slave->perm_hwaddr);
> 	lacpdu_header->hdr.h_proto = PKT_TYPE_LACPDU;
> 
> 	lacpdu_header->lacpdu = port->lacpdu;
>@@ -810,11 +810,11 @@ static int ad_marker_send(struct port *port, struct bond_marker *marker)
> 
> 	marker_header = (struct bond_marker_header *)skb_put(skb, length);
> 
>-	memcpy(marker_header->hdr.h_dest, lacpdu_mcast_addr, ETH_ALEN);
>+	ether_addr_copy(marker_header->hdr.h_dest, lacpdu_mcast_addr);
> 	/* Note: source address is set to be the member's PERMANENT address,
> 	 * because we use it to identify loopback MARKERs in receive.
> 	 */
>-	memcpy(marker_header->hdr.h_source, slave->perm_hwaddr, ETH_ALEN);
>+	ether_addr_copy(marker_header->hdr.h_source, slave->perm_hwaddr);
> 	marker_header->hdr.h_proto = PKT_TYPE_LACPDU;
> 
> 	marker_header->marker = *marker;
>diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
>index e9f0a98..538913e 100644
>--- a/drivers/net/bonding/bond_alb.c
>+++ b/drivers/net/bonding/bond_alb.c
>@@ -333,7 +333,7 @@ static void rlb_update_entry_from_arp(struct bonding *bond, struct arp_pkt *arp)
> 	    (client_info->ip_dst == arp->ip_src) &&
> 	    (!ether_addr_equal_64bits(client_info->mac_dst, arp->mac_src))) {
> 		/* update the clients MAC address */
>-		memcpy(client_info->mac_dst, arp->mac_src, ETH_ALEN);
>+		ether_addr_copy(client_info->mac_dst, arp->mac_src);
> 		client_info->ntt = 1;
> 		bond_info->rx_ntt = 1;
> 	}
>@@ -669,9 +669,9 @@ static struct slave *rlb_choose_channel(struct sk_buff *skb, struct bonding *bon
> 			/* the entry is already assigned to this client */
> 			if (!ether_addr_equal_64bits(arp->mac_dst, mac_bcast)) {
> 				/* update mac address from arp */
>-				memcpy(client_info->mac_dst, arp->mac_dst, ETH_ALEN);
>+				ether_addr_copy(client_info->mac_dst, arp->mac_dst);
> 			}
>-			memcpy(client_info->mac_src, arp->mac_src, ETH_ALEN);
>+			ether_addr_copy(client_info->mac_src, arp->mac_src);
> 
> 			assigned_slave = client_info->slave;
> 			if (assigned_slave) {
>@@ -711,8 +711,8 @@ static struct slave *rlb_choose_channel(struct sk_buff *skb, struct bonding *bon
> 		 * will be updated with clients actual unicast mac address
> 		 * upon receiving an arp reply.
> 		 */
>-		memcpy(client_info->mac_dst, arp->mac_dst, ETH_ALEN);
>-		memcpy(client_info->mac_src, arp->mac_src, ETH_ALEN);
>+		ether_addr_copy(client_info->mac_dst, arp->mac_dst);
>+		ether_addr_copy(client_info->mac_src, arp->mac_src);
> 		client_info->slave = assigned_slave;
> 
> 		if (!ether_addr_equal_64bits(client_info->mac_dst, mac_bcast)) {
>@@ -763,7 +763,7 @@ static struct slave *rlb_arp_xmit(struct sk_buff *skb, struct bonding *bond)
> 		*/
> 		tx_slave = rlb_choose_channel(skb, bond);
> 		if (tx_slave)
>-			memcpy(arp->mac_src, tx_slave->dev->dev_addr, ETH_ALEN);
>+			ether_addr_copy(arp->mac_src, tx_slave->dev->dev_addr);
> 		pr_debug("Server sent ARP Reply packet\n");
> 	} else if (arp->op_code == htons(ARPOP_REQUEST)) {
> 		/* Create an entry in the rx_hashtbl for this client as a
>@@ -1003,8 +1003,8 @@ static void alb_send_lp_vid(struct slave *slave, u8 mac_addr[],
> 	char *data;
> 
> 	memset(&pkt, 0, size);
>-	memcpy(pkt.mac_dst, mac_addr, ETH_ALEN);
>-	memcpy(pkt.mac_src, mac_addr, ETH_ALEN);
>+	ether_addr_copy(pkt.mac_dst, mac_addr);
>+	ether_addr_copy(pkt.mac_src, mac_addr);
> 	pkt.type = cpu_to_be16(ETH_P_LOOP);
> 
> 	skb = dev_alloc_skb(size);
>@@ -1086,7 +1086,7 @@ static void alb_swap_mac_addr(struct slave *slave1, struct slave *slave2)
> {
> 	u8 tmp_mac_addr[ETH_ALEN];
> 
>-	memcpy(tmp_mac_addr, slave1->dev->dev_addr, ETH_ALEN);
>+	ether_addr_copy(tmp_mac_addr, slave1->dev->dev_addr);
> 	alb_set_slave_mac_addr(slave1, slave2->dev->dev_addr);
> 	alb_set_slave_mac_addr(slave2, tmp_mac_addr);
> 
>@@ -1283,12 +1283,12 @@ static int alb_set_mac_address(struct bonding *bond, void *addr)
> 
> 	bond_for_each_slave(bond, slave, iter) {
> 		/* save net_device's current hw address */
>-		memcpy(tmp_addr, slave->dev->dev_addr, ETH_ALEN);
>+		ether_addr_copy(tmp_addr, slave->dev->dev_addr);
> 
> 		res = dev_set_mac_address(slave->dev, addr);
> 
> 		/* restore net_device's hw address */
>-		memcpy(slave->dev->dev_addr, tmp_addr, ETH_ALEN);
>+		ether_addr_copy(slave->dev->dev_addr, tmp_addr);
> 
> 		if (res)
> 			goto unwind;
>@@ -1304,9 +1304,9 @@ unwind:
> 	bond_for_each_slave(bond, rollback_slave, iter) {
> 		if (rollback_slave == slave)
> 			break;
>-		memcpy(tmp_addr, rollback_slave->dev->dev_addr, ETH_ALEN);
>+		ether_addr_copy(tmp_addr, rollback_slave->dev->dev_addr);
> 		dev_set_mac_address(rollback_slave->dev, &sa);
>-		memcpy(rollback_slave->dev->dev_addr, tmp_addr, ETH_ALEN);
>+		ether_addr_copy(rollback_slave->dev->dev_addr, tmp_addr);
> 	}
> 
> 	return res;
>@@ -1704,14 +1704,14 @@ void bond_alb_handle_active_change(struct bonding *bond, struct slave *new_slave
> 		struct sockaddr sa;
> 		u8 tmp_addr[ETH_ALEN];
> 
>-		memcpy(tmp_addr, new_slave->dev->dev_addr, ETH_ALEN);
>+		ether_addr_copy(tmp_addr, new_slave->dev->dev_addr);
> 
> 		memcpy(sa.sa_data, bond->dev->dev_addr, bond->dev->addr_len);
> 		sa.sa_family = bond->dev->type;
> 		/* we don't care if it can't change its mac, best effort */
> 		dev_set_mac_address(new_slave->dev, &sa);
> 
>-		memcpy(new_slave->dev->dev_addr, tmp_addr, ETH_ALEN);
>+		ether_addr_copy(new_slave->dev->dev_addr, tmp_addr);
> 	}
> 
> 	/* curr_active_slave must be set before calling alb_swap_mac_addr */
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 90994ed..3bce855 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -673,12 +673,12 @@ static void bond_do_fail_over_mac(struct bonding *bond,
> 		write_unlock_bh(&bond->curr_slave_lock);
> 
> 		if (old_active) {
>-			memcpy(tmp_mac, new_active->dev->dev_addr, ETH_ALEN);
>+			ether_addr_copy(tmp_mac, new_active->dev->dev_addr);
> 			memcpy(saddr.sa_data, old_active->dev->dev_addr,
> 			       ETH_ALEN);
> 			saddr.sa_family = new_active->dev->type;
> 		} else {
>-			memcpy(saddr.sa_data, bond->dev->dev_addr, ETH_ALEN);
>+			ether_addr_copy(saddr.sa_data, bond->dev->dev_addr);
> 			saddr.sa_family = bond->dev->type;
> 		}
> 
>@@ -692,7 +692,7 @@ static void bond_do_fail_over_mac(struct bonding *bond,
> 		if (!old_active)
> 			goto out;
> 
>-		memcpy(saddr.sa_data, tmp_mac, ETH_ALEN);
>+		ether_addr_copy(saddr.sa_data, tmp_mac);
> 		saddr.sa_family = old_active->dev->type;
> 
> 		rv = dev_set_mac_address(old_active->dev, &saddr);
>@@ -1316,7 +1316,7 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
> 	 * that need it, and for restoring it upon release, and then
> 	 * set it to the master's address
> 	 */
>-	memcpy(new_slave->perm_hwaddr, slave_dev->dev_addr, ETH_ALEN);
>+	ether_addr_copy(new_slave->perm_hwaddr, slave_dev->dev_addr);
> 
> 	if (!bond->params.fail_over_mac ||
> 	    bond->params.mode != BOND_MODE_ACTIVEBACKUP) {
>@@ -1587,7 +1587,7 @@ err_restore_mac:
> 		 * MAC if this slave's MAC is in use by the bond, or at
> 		 * least print a warning.
> 		 */
>-		memcpy(addr.sa_data, new_slave->perm_hwaddr, ETH_ALEN);
>+		ether_addr_copy(addr.sa_data, new_slave->perm_hwaddr);
> 		addr.sa_family = slave_dev->type;
> 		dev_set_mac_address(slave_dev, &addr);
> 	}
>@@ -1776,7 +1776,7 @@ static int __bond_release_one(struct net_device *bond_dev,
> 	if (bond->params.fail_over_mac != BOND_FOM_ACTIVE ||
> 	    bond->params.mode != BOND_MODE_ACTIVEBACKUP) {
> 		/* restore original ("permanent") mac address */
>-		memcpy(addr.sa_data, slave->perm_hwaddr, ETH_ALEN);
>+		ether_addr_copy(addr.sa_data, slave->perm_hwaddr);
> 		addr.sa_family = slave_dev->type;
> 		dev_set_mac_address(slave_dev, &addr);
> 	}
>-- 
>1.8.1.2.459.gbcd45b4.dirty
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
