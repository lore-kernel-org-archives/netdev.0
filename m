From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: Remove unnecessary struct in6_addr *
 casts
Date: Mon, 10 Nov 2014 13:28:37 -0500 (EST)
Message-ID: <20141110.132837.1817456437352515704.davem@davemloft.net>
References: <1415333125-10635-1-git-send-email-hariprasad@chelsio.com>
	<1415333125-10635-2-git-send-email-hariprasad@chelsio.com>
	<1415335574.23530.4.camel@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hariprasad@chelsio.com, netdev@vger.kernel.org, leedom@chelsio.com,
	anish@chelsio.com, praveenm@chelsio.com, nirranjan@chelsio.com,
	kumaras@chelsio.com, j.vosburgh@gmail.com, vfalico@gmail.com,
	andy@greyhouse.net
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45971 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751322AbaKJS2l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 13:28:41 -0500
In-Reply-To: <1415335574.23530.4.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Thu, 06 Nov 2014 20:46:14 -0800

> Just use the address of the in6_addr.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied, thanks.

> ---
>> diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
> []
>>  #include <../drivers/net/bonding/bonding.h>
> 
> This include path seems unfortunate so I looked 
> at the code a bit.  I don't see an easy way to change it.
> 
> Maybe some of bonding.h should be moved into a new file
> like 'include/net/bonding.h' or something.

I just committed the following into net-next, thanks for pointing
this out.

====================
[PATCH] net: Move bonding headers under include/net

This ways drivers like cxgb4 don't need to do ugly relative includes.

Reported-by: Joe Perches <joe@perches.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/bonding/bond_3ad.c                  |   4 +-
 drivers/net/bonding/bond_3ad.h                  | 283 ----------
 drivers/net/bonding/bond_alb.c                  |   4 +-
 drivers/net/bonding/bond_alb.h                  | 181 -------
 drivers/net/bonding/bond_debugfs.c              |   4 +-
 drivers/net/bonding/bond_main.c                 |   6 +-
 drivers/net/bonding/bond_netlink.c              |   2 +-
 drivers/net/bonding/bond_options.c              |   2 +-
 drivers/net/bonding/bond_options.h              | 130 -----
 drivers/net/bonding/bond_procfs.c               |   2 +-
 drivers/net/bonding/bond_sysfs.c                |   2 +-
 drivers/net/bonding/bond_sysfs_slave.c          |   2 +-
 drivers/net/bonding/bonding.h                   | 654 ------------------------
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |   3 +-
 include/net/bond_3ad.h                          | 283 ++++++++++
 include/net/bond_alb.h                          | 181 +++++++
 include/net/bond_options.h                      | 130 +++++
 include/net/bonding.h                           | 654 ++++++++++++++++++++++++
 18 files changed, 1263 insertions(+), 1264 deletions(-)
 delete mode 100644 drivers/net/bonding/bond_3ad.h
 delete mode 100644 drivers/net/bonding/bond_alb.h
 delete mode 100644 drivers/net/bonding/bond_options.h
 delete mode 100644 drivers/net/bonding/bonding.h
 create mode 100644 include/net/bond_3ad.h
 create mode 100644 include/net/bond_alb.h
 create mode 100644 include/net/bond_options.h
 create mode 100644 include/net/bonding.h

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 2110215f..0a32143 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -29,8 +29,8 @@
 #include <linux/if_bonding.h>
 #include <linux/pkt_sched.h>
 #include <net/net_namespace.h>
-#include "bonding.h"
-#include "bond_3ad.h"
+#include <net/bonding.h>
+#include <net/bond_3ad.h>
 
 /* General definitions */
 #define AD_SHORT_TIMEOUT           1
diff --git a/drivers/net/bonding/bond_3ad.h b/drivers/net/bonding/bond_3ad.h
deleted file mode 100644
index c5f14ac..0000000
--- a/drivers/net/bonding/bond_3ad.h
+++ /dev/null
@@ -1,283 +0,0 @@
-/*
- * Copyright(c) 1999 - 2004 Intel Corporation. All rights reserved.
- *
- * This program is free software; you can redistribute it and/or modify it
- * under the terms of the GNU General Public License as published by the Free
- * Software Foundation; either version 2 of the License, or (at your option)
- * any later version.
- *
- * This program is distributed in the hope that it will be useful, but WITHOUT
- * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
- * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
- * more details.
- *
- * You should have received a copy of the GNU General Public License along with
- * this program; if not, write to the Free Software Foundation, Inc., 59
- * Temple Place - Suite 330, Boston, MA  02111-1307, USA.
- *
- * The full GNU General Public License is included in this distribution in the
- * file called LICENSE.
- *
- */
-
-#ifndef __BOND_3AD_H__
-#define __BOND_3AD_H__
-
-#include <asm/byteorder.h>
-#include <linux/skbuff.h>
-#include <linux/netdevice.h>
-#include <linux/if_ether.h>
-
-/* General definitions */
-#define PKT_TYPE_LACPDU         cpu_to_be16(ETH_P_SLOW)
-#define AD_TIMER_INTERVAL       100 /*msec*/
-
-#define MULTICAST_LACPDU_ADDR    {0x01, 0x80, 0xC2, 0x00, 0x00, 0x02}
-
-#define AD_LACP_SLOW 0
-#define AD_LACP_FAST 1
-
-typedef struct mac_addr {
-	u8 mac_addr_value[ETH_ALEN];
-} __packed mac_addr_t;
-
-enum {
-	BOND_AD_STABLE = 0,
-	BOND_AD_BANDWIDTH = 1,
-	BOND_AD_COUNT = 2,
-};
-
-/* rx machine states(43.4.11 in the 802.3ad standard) */
-typedef enum {
-	AD_RX_DUMMY,
-	AD_RX_INITIALIZE,	/* rx Machine */
-	AD_RX_PORT_DISABLED,	/* rx Machine */
-	AD_RX_LACP_DISABLED,	/* rx Machine */
-	AD_RX_EXPIRED,		/* rx Machine */
-	AD_RX_DEFAULTED,	/* rx Machine */
-	AD_RX_CURRENT		/* rx Machine */
-} rx_states_t;
-
-/* periodic machine states(43.4.12 in the 802.3ad standard) */
-typedef enum {
-	AD_PERIODIC_DUMMY,
-	AD_NO_PERIODIC,		/* periodic machine */
-	AD_FAST_PERIODIC,	/* periodic machine */
-	AD_SLOW_PERIODIC,	/* periodic machine */
-	AD_PERIODIC_TX		/* periodic machine */
-} periodic_states_t;
-
-/* mux machine states(43.4.13 in the 802.3ad standard) */
-typedef enum {
-	AD_MUX_DUMMY,
-	AD_MUX_DETACHED,	/* mux machine */
-	AD_MUX_WAITING,		/* mux machine */
-	AD_MUX_ATTACHED,	/* mux machine */
-	AD_MUX_COLLECTING_DISTRIBUTING	/* mux machine */
-} mux_states_t;
-
-/* tx machine states(43.4.15 in the 802.3ad standard) */
-typedef enum {
-	AD_TX_DUMMY,
-	AD_TRANSMIT		/* tx Machine */
-} tx_states_t;
-
-/* rx indication types */
-typedef enum {
-	AD_TYPE_LACPDU = 1,	/* type lacpdu */
-	AD_TYPE_MARKER		/* type marker */
-} pdu_type_t;
-
-/* rx marker indication types */
-typedef enum {
-	AD_MARKER_INFORMATION_SUBTYPE = 1,	/* marker imformation subtype */
-	AD_MARKER_RESPONSE_SUBTYPE		/* marker response subtype */
-} bond_marker_subtype_t;
-
-/* timers types(43.4.9 in the 802.3ad standard) */
-typedef enum {
-	AD_CURRENT_WHILE_TIMER,
-	AD_ACTOR_CHURN_TIMER,
-	AD_PERIODIC_TIMER,
-	AD_PARTNER_CHURN_TIMER,
-	AD_WAIT_WHILE_TIMER
-} ad_timers_t;
-
-#pragma pack(1)
-
-/* Link Aggregation Control Protocol(LACP) data unit structure(43.4.2.2 in the 802.3ad standard) */
-typedef struct lacpdu {
-	u8 subtype;		/* = LACP(= 0x01) */
-	u8 version_number;
-	u8 tlv_type_actor_info;	/* = actor information(type/length/value) */
-	u8 actor_information_length;	/* = 20 */
-	__be16 actor_system_priority;
-	struct mac_addr actor_system;
-	__be16 actor_key;
-	__be16 actor_port_priority;
-	__be16 actor_port;
-	u8 actor_state;
-	u8 reserved_3_1[3];		/* = 0 */
-	u8 tlv_type_partner_info;	/* = partner information */
-	u8 partner_information_length;	/* = 20 */
-	__be16 partner_system_priority;
-	struct mac_addr partner_system;
-	__be16 partner_key;
-	__be16 partner_port_priority;
-	__be16 partner_port;
-	u8 partner_state;
-	u8 reserved_3_2[3];		/* = 0 */
-	u8 tlv_type_collector_info;	/* = collector information */
-	u8 collector_information_length;/* = 16 */
-	__be16 collector_max_delay;
-	u8 reserved_12[12];
-	u8 tlv_type_terminator;		/* = terminator */
-	u8 terminator_length;		/* = 0 */
-	u8 reserved_50[50];		/* = 0 */
-} __packed lacpdu_t;
-
-typedef struct lacpdu_header {
-	struct ethhdr hdr;
-	struct lacpdu lacpdu;
-} __packed lacpdu_header_t;
-
-/* Marker Protocol Data Unit(PDU) structure(43.5.3.2 in the 802.3ad standard) */
-typedef struct bond_marker {
-	u8 subtype;		/* = 0x02  (marker PDU) */
-	u8 version_number;	/* = 0x01 */
-	u8 tlv_type;		/* = 0x01  (marker information) */
-	/* = 0x02  (marker response information) */
-	u8 marker_length;	/* = 0x16 */
-	u16 requester_port;	/* The number assigned to the port by the requester */
-	struct mac_addr requester_system;	/* The requester's system id */
-	u32 requester_transaction_id;		/* The transaction id allocated by the requester, */
-	u16 pad;		/* = 0 */
-	u8 tlv_type_terminator;	/* = 0x00 */
-	u8 terminator_length;	/* = 0x00 */
-	u8 reserved_90[90];	/* = 0 */
-} __packed bond_marker_t;
-
-typedef struct bond_marker_header {
-	struct ethhdr hdr;
-	struct bond_marker marker;
-} __packed bond_marker_header_t;
-
-#pragma pack()
-
-struct slave;
-struct bonding;
-struct ad_info;
-struct port;
-
-#ifdef __ia64__
-#pragma pack(8)
-#endif
-
-/* aggregator structure(43.4.5 in the 802.3ad standard) */
-typedef struct aggregator {
-	struct mac_addr aggregator_mac_address;
-	u16 aggregator_identifier;
-	bool is_individual;
-	u16 actor_admin_aggregator_key;
-	u16 actor_oper_aggregator_key;
-	struct mac_addr partner_system;
-	u16 partner_system_priority;
-	u16 partner_oper_aggregator_key;
-	u16 receive_state;	/* BOOLEAN */
-	u16 transmit_state;	/* BOOLEAN */
-	struct port *lag_ports;
-	/* ****** PRIVATE PARAMETERS ****** */
-	struct slave *slave;	/* pointer to the bond slave that this aggregator belongs to */
-	u16 is_active;		/* BOOLEAN. Indicates if this aggregator is active */
-	u16 num_of_ports;
-} aggregator_t;
-
-struct port_params {
-	struct mac_addr system;
-	u16 system_priority;
-	u16 key;
-	u16 port_number;
-	u16 port_priority;
-	u16 port_state;
-};
-
-/* port structure(43.4.6 in the 802.3ad standard) */
-typedef struct port {
-	u16 actor_port_number;
-	u16 actor_port_priority;
-	struct mac_addr actor_system;	/* This parameter is added here although it is not specified in the standard, just for simplification */
-	u16 actor_system_priority;	/* This parameter is added here although it is not specified in the standard, just for simplification */
-	u16 actor_port_aggregator_identifier;
-	bool ntt;
-	u16 actor_admin_port_key;
-	u16 actor_oper_port_key;
-	u8 actor_admin_port_state;
-	u8 actor_oper_port_state;
-
-	struct port_params partner_admin;
-	struct port_params partner_oper;
-
-	bool is_enabled;
-
-	/* ****** PRIVATE PARAMETERS ****** */
-	u16 sm_vars;		/* all state machines variables for this port */
-	rx_states_t sm_rx_state;	/* state machine rx state */
-	u16 sm_rx_timer_counter;	/* state machine rx timer counter */
-	periodic_states_t sm_periodic_state;	/* state machine periodic state */
-	u16 sm_periodic_timer_counter;	/* state machine periodic timer counter */
-	mux_states_t sm_mux_state;	/* state machine mux state */
-	u16 sm_mux_timer_counter;	/* state machine mux timer counter */
-	tx_states_t sm_tx_state;	/* state machine tx state */
-	u16 sm_tx_timer_counter;	/* state machine tx timer counter(allways on - enter to transmit state 3 time per second) */
-	struct slave *slave;		/* pointer to the bond slave that this port belongs to */
-	struct aggregator *aggregator;	/* pointer to an aggregator that this port related to */
-	struct port *next_port_in_aggregator;	/* Next port on the linked list of the parent aggregator */
-	u32 transaction_id;		/* continuous number for identification of Marker PDU's; */
-	struct lacpdu lacpdu;		/* the lacpdu that will be sent for this port */
-} port_t;
-
-/* system structure */
-struct ad_system {
-	u16 sys_priority;
-	struct mac_addr sys_mac_addr;
-};
-
-#ifdef __ia64__
-#pragma pack()
-#endif
-
-/* ========== AD Exported structures to the main bonding code ========== */
-#define BOND_AD_INFO(bond)   ((bond)->ad_info)
-#define SLAVE_AD_INFO(slave) ((slave)->ad_info)
-
-struct ad_bond_info {
-	struct ad_system system;	/* 802.3ad system structure */
-	u32 agg_select_timer;		/* Timer to select aggregator after all adapter's hand shakes */
-	u16 aggregator_identifier;
-};
-
-struct ad_slave_info {
-	struct aggregator aggregator;	/* 802.3ad aggregator structure */
-	struct port port;		/* 802.3ad port structure */
-	u16 id;
-};
-
-/* ========== AD Exported functions to the main bonding code ========== */
-void bond_3ad_initialize(struct bonding *bond, u16 tick_resolution);
-void bond_3ad_bind_slave(struct slave *slave);
-void bond_3ad_unbind_slave(struct slave *slave);
-void bond_3ad_state_machine_handler(struct work_struct *);
-void bond_3ad_initiate_agg_selection(struct bonding *bond, int timeout);
-void bond_3ad_adapter_speed_changed(struct slave *slave);
-void bond_3ad_adapter_duplex_changed(struct slave *slave);
-void bond_3ad_handle_link_change(struct slave *slave, char link);
-int  bond_3ad_get_active_agg_info(struct bonding *bond, struct ad_info *ad_info);
-int  __bond_3ad_get_active_agg_info(struct bonding *bond,
-				    struct ad_info *ad_info);
-int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev);
-int bond_3ad_lacpdu_recv(const struct sk_buff *skb, struct bonding *bond,
-			 struct slave *slave);
-int bond_3ad_set_carrier(struct bonding *bond);
-void bond_3ad_update_lacp_rate(struct bonding *bond);
-#endif /* __BOND_3AD_H__ */
-
diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index baa58e7..e1f1a00 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -37,8 +37,8 @@
 #include <net/arp.h>
 #include <net/ipv6.h>
 #include <asm/byteorder.h>
-#include "bonding.h"
-#include "bond_alb.h"
+#include <net/bonding.h>
+#include <net/bond_alb.h>
 
 
 
diff --git a/drivers/net/bonding/bond_alb.h b/drivers/net/bonding/bond_alb.h
deleted file mode 100644
index 1ad473b..0000000
--- a/drivers/net/bonding/bond_alb.h
+++ /dev/null
@@ -1,181 +0,0 @@
-/*
- * Copyright(c) 1999 - 2004 Intel Corporation. All rights reserved.
- *
- * This program is free software; you can redistribute it and/or modify it
- * under the terms of the GNU General Public License as published by the
- * Free Software Foundation; either version 2 of the License, or
- * (at your option) any later version.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
- * or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
- * for more details.
- *
- * You should have received a copy of the GNU General Public License along
- * with this program; if not, see <http://www.gnu.org/licenses/>.
- *
- * The full GNU General Public License is included in this distribution in the
- * file called LICENSE.
- *
- */
-
-#ifndef __BOND_ALB_H__
-#define __BOND_ALB_H__
-
-#include <linux/if_ether.h>
-
-struct bonding;
-struct slave;
-
-#define BOND_ALB_INFO(bond)   ((bond)->alb_info)
-#define SLAVE_TLB_INFO(slave) ((slave)->tlb_info)
-
-#define ALB_TIMER_TICKS_PER_SEC	    10	/* should be a divisor of HZ */
-#define BOND_TLB_REBALANCE_INTERVAL 10	/* In seconds, periodic re-balancing.
-					 * Used for division - never set
-					 * to zero !!!
-					 */
-#define BOND_ALB_DEFAULT_LP_INTERVAL 1
-#define BOND_ALB_LP_INTERVAL(bond) (bond->params.lp_interval)	/* In seconds, periodic send of
-								 * learning packets to the switch
-								 */
-
-#define BOND_TLB_REBALANCE_TICKS (BOND_TLB_REBALANCE_INTERVAL \
-				  * ALB_TIMER_TICKS_PER_SEC)
-
-#define BOND_ALB_LP_TICKS(bond) (BOND_ALB_LP_INTERVAL(bond) \
-			   * ALB_TIMER_TICKS_PER_SEC)
-
-#define TLB_HASH_TABLE_SIZE 256	/* The size of the clients hash table.
-				 * Note that this value MUST NOT be smaller
-				 * because the key hash table is BYTE wide !
-				 */
-
-
-#define TLB_NULL_INDEX		0xffffffff
-
-/* rlb defs */
-#define RLB_HASH_TABLE_SIZE	256
-#define RLB_NULL_INDEX		0xffffffff
-#define RLB_UPDATE_DELAY	(2*ALB_TIMER_TICKS_PER_SEC) /* 2 seconds */
-#define RLB_ARP_BURST_SIZE	2
-#define RLB_UPDATE_RETRY	3 /* 3-ticks - must be smaller than the rlb
-				   * rebalance interval (5 min).
-				   */
-/* RLB_PROMISC_TIMEOUT = 10 sec equals the time that the current slave is
- * promiscuous after failover
- */
-#define RLB_PROMISC_TIMEOUT	(10*ALB_TIMER_TICKS_PER_SEC)
-
-
-struct tlb_client_info {
-	struct slave *tx_slave;	/* A pointer to slave used for transmiting
-				 * packets to a Client that the Hash function
-				 * gave this entry index.
-				 */
-	u32 tx_bytes;		/* Each Client accumulates the BytesTx that
-				 * were transmitted to it, and after each
-				 * CallBack the LoadHistory is divided
-				 * by the balance interval
-				 */
-	u32 load_history;	/* This field contains the amount of Bytes
-				 * that were transmitted to this client by
-				 * the server on the previous balance
-				 * interval in Bps.
-				 */
-	u32 next;		/* The next Hash table entry index, assigned
-				 * to use the same adapter for transmit.
-				 */
-	u32 prev;		/* The previous Hash table entry index,
-				 * assigned to use the same
-				 */
-};
-
-/* -------------------------------------------------------------------------
- * struct rlb_client_info contains all info related to a specific rx client
- * connection. This is the Clients Hash Table entry struct.
- * Note that this is not a proper hash table; if a new client's IP address
- * hash collides with an existing client entry, the old entry is replaced.
- *
- * There is a linked list (linked by the used_next and used_prev members)
- * linking all the used entries of the hash table. This allows updating
- * all the clients without walking over all the unused elements of the table.
- *
- * There are also linked lists of entries with identical hash(ip_src). These
- * allow cleaning up the table from ip_src<->mac_src associations that have
- * become outdated and would cause sending out invalid ARP updates to the
- * network. These are linked by the (src_next and src_prev members).
- * -------------------------------------------------------------------------
- */
-struct rlb_client_info {
-	__be32 ip_src;		/* the server IP address */
-	__be32 ip_dst;		/* the client IP address */
-	u8  mac_src[ETH_ALEN];	/* the server MAC address */
-	u8  mac_dst[ETH_ALEN];	/* the client MAC address */
-
-	/* list of used hash table entries, starting at rx_hashtbl_used_head */
-	u32 used_next;
-	u32 used_prev;
-
-	/* ip_src based hashing */
-	u32 src_next;	/* next entry with same hash(ip_src) */
-	u32 src_prev;	/* prev entry with same hash(ip_src) */
-	u32 src_first;	/* first entry with hash(ip_src) == this entry's index */
-
-	u8  assigned;		/* checking whether this entry is assigned */
-	u8  ntt;		/* flag - need to transmit client info */
-	struct slave *slave;	/* the slave assigned to this client */
-	unsigned short vlan_id;	/* VLAN tag associated with IP address */
-};
-
-struct tlb_slave_info {
-	u32 head;	/* Index to the head of the bi-directional clients
-			 * hash table entries list. The entries in the list
-			 * are the entries that were assigned to use this
-			 * slave for transmit.
-			 */
-	u32 load;	/* Each slave sums the loadHistory of all clients
-			 * assigned to it
-			 */
-};
-
-struct alb_bond_info {
-	struct tlb_client_info	*tx_hashtbl; /* Dynamically allocated */
-	u32			unbalanced_load;
-	int			tx_rebalance_counter;
-	int			lp_counter;
-	/* -------- rlb parameters -------- */
-	int rlb_enabled;
-	struct rlb_client_info	*rx_hashtbl;	/* Receive hash table */
-	u32			rx_hashtbl_used_head;
-	u8			rx_ntt;	/* flag - need to transmit
-					 * to all rx clients
-					 */
-	struct slave		*rx_slave;/* last slave to xmit from */
-	u8			primary_is_promisc;	   /* boolean */
-	u32			rlb_promisc_timeout_counter;/* counts primary
-							     * promiscuity time
-							     */
-	u32			rlb_update_delay_counter;
-	u32			rlb_update_retry_counter;/* counter of retries
-							  * of client update
-							  */
-	u8			rlb_rebalance;	/* flag - indicates that the
-						 * rx traffic should be
-						 * rebalanced
-						 */
-};
-
-int bond_alb_initialize(struct bonding *bond, int rlb_enabled);
-void bond_alb_deinitialize(struct bonding *bond);
-int bond_alb_init_slave(struct bonding *bond, struct slave *slave);
-void bond_alb_deinit_slave(struct bonding *bond, struct slave *slave);
-void bond_alb_handle_link_change(struct bonding *bond, struct slave *slave, char link);
-void bond_alb_handle_active_change(struct bonding *bond, struct slave *new_slave);
-int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev);
-int bond_tlb_xmit(struct sk_buff *skb, struct net_device *bond_dev);
-void bond_alb_monitor(struct work_struct *);
-int bond_alb_set_mac_address(struct net_device *bond_dev, void *addr);
-void bond_alb_clear_vlan(struct bonding *bond, unsigned short vlan_id);
-#endif /* __BOND_ALB_H__ */
-
diff --git a/drivers/net/bonding/bond_debugfs.c b/drivers/net/bonding/bond_debugfs.c
index 8f99082..e52e25a 100644
--- a/drivers/net/bonding/bond_debugfs.c
+++ b/drivers/net/bonding/bond_debugfs.c
@@ -3,8 +3,8 @@
 #include <linux/device.h>
 #include <linux/netdevice.h>
 
-#include "bonding.h"
-#include "bond_alb.h"
+#include <net/bonding.h>
+#include <net/bond_alb.h>
 
 #if defined(CONFIG_DEBUG_FS) && !defined(CONFIG_NET_NS)
 
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index c752008..b9b3456 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -77,9 +77,9 @@
 #include <net/pkt_sched.h>
 #include <linux/rculist.h>
 #include <net/flow_keys.h>
-#include "bonding.h"
-#include "bond_3ad.h"
-#include "bond_alb.h"
+#include <net/bonding.h>
+#include <net/bond_3ad.h>
+#include <net/bond_alb.h>
 
 /*---------------------------- Module parameters ----------------------------*/
 
diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index c13d83e..3e6eebd 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -17,7 +17,7 @@
 #include <linux/if_ether.h>
 #include <net/netlink.h>
 #include <net/rtnetlink.h>
-#include "bonding.h"
+#include <net/bonding.h>
 
 static size_t bond_get_slave_size(const struct net_device *bond_dev,
 				  const struct net_device *slave_dev)
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index b62697f..1a61cc9 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -16,7 +16,7 @@
 #include <linux/rcupdate.h>
 #include <linux/ctype.h>
 #include <linux/inet.h>
-#include "bonding.h"
+#include <net/bonding.h>
 
 static int bond_option_active_slave_set(struct bonding *bond,
 					const struct bond_opt_value *newval);
diff --git a/drivers/net/bonding/bond_options.h b/drivers/net/bonding/bond_options.h
deleted file mode 100644
index 17ded5b..0000000
--- a/drivers/net/bonding/bond_options.h
+++ /dev/null
@@ -1,130 +0,0 @@
-/*
- * drivers/net/bond/bond_options.h - bonding options
- * Copyright (c) 2013 Nikolay Aleksandrov <nikolay@redhat.com>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License as published by
- * the Free Software Foundation; either version 2 of the License, or
- * (at your option) any later version.
- */
-
-#ifndef _BOND_OPTIONS_H
-#define _BOND_OPTIONS_H
-
-#define BOND_OPT_MAX_NAMELEN 32
-#define BOND_OPT_VALID(opt) ((opt) < BOND_OPT_LAST)
-#define BOND_MODE_ALL_EX(x) (~(x))
-
-/* Option flags:
- * BOND_OPTFLAG_NOSLAVES - check if the bond device is empty before setting
- * BOND_OPTFLAG_IFDOWN - check if the bond device is down before setting
- * BOND_OPTFLAG_RAWVAL - the option parses the value itself
- */
-enum {
-	BOND_OPTFLAG_NOSLAVES	= BIT(0),
-	BOND_OPTFLAG_IFDOWN	= BIT(1),
-	BOND_OPTFLAG_RAWVAL	= BIT(2)
-};
-
-/* Value type flags:
- * BOND_VALFLAG_DEFAULT - mark the value as default
- * BOND_VALFLAG_(MIN|MAX) - mark the value as min/max
- */
-enum {
-	BOND_VALFLAG_DEFAULT	= BIT(0),
-	BOND_VALFLAG_MIN	= BIT(1),
-	BOND_VALFLAG_MAX	= BIT(2)
-};
-
-/* Option IDs, their bit positions correspond to their IDs */
-enum {
-	BOND_OPT_MODE,
-	BOND_OPT_PACKETS_PER_SLAVE,
-	BOND_OPT_XMIT_HASH,
-	BOND_OPT_ARP_VALIDATE,
-	BOND_OPT_ARP_ALL_TARGETS,
-	BOND_OPT_FAIL_OVER_MAC,
-	BOND_OPT_ARP_INTERVAL,
-	BOND_OPT_ARP_TARGETS,
-	BOND_OPT_DOWNDELAY,
-	BOND_OPT_UPDELAY,
-	BOND_OPT_LACP_RATE,
-	BOND_OPT_MINLINKS,
-	BOND_OPT_AD_SELECT,
-	BOND_OPT_NUM_PEER_NOTIF,
-	BOND_OPT_MIIMON,
-	BOND_OPT_PRIMARY,
-	BOND_OPT_PRIMARY_RESELECT,
-	BOND_OPT_USE_CARRIER,
-	BOND_OPT_ACTIVE_SLAVE,
-	BOND_OPT_QUEUE_ID,
-	BOND_OPT_ALL_SLAVES_ACTIVE,
-	BOND_OPT_RESEND_IGMP,
-	BOND_OPT_LP_INTERVAL,
-	BOND_OPT_SLAVES,
-	BOND_OPT_TLB_DYNAMIC_LB,
-	BOND_OPT_LAST
-};
-
-/* This structure is used for storing option values and for passing option
- * values when changing an option. The logic when used as an arg is as follows:
- * - if string != NULL -> parse it, if the opt is RAW type then return it, else
- *   return the parse result
- * - if string == NULL -> parse value
- */
-struct bond_opt_value {
-	char *string;
-	u64 value;
-	u32 flags;
-};
-
-struct bonding;
-
-struct bond_option {
-	int id;
-	const char *name;
-	const char *desc;
-	u32 flags;
-
-	/* unsuppmodes is used to denote modes in which the option isn't
-	 * supported.
-	 */
-	unsigned long unsuppmodes;
-	/* supported values which this option can have, can be a subset of
-	 * BOND_OPTVAL_RANGE's value range
-	 */
-	const struct bond_opt_value *values;
-
-	int (*set)(struct bonding *bond, const struct bond_opt_value *val);
-};
-
-int __bond_opt_set(struct bonding *bond, unsigned int option,
-		   struct bond_opt_value *val);
-int bond_opt_tryset_rtnl(struct bonding *bond, unsigned int option, char *buf);
-
-const struct bond_opt_value *bond_opt_parse(const struct bond_option *opt,
-					    struct bond_opt_value *val);
-const struct bond_option *bond_opt_get(unsigned int option);
-const struct bond_option *bond_opt_get_by_name(const char *name);
-const struct bond_opt_value *bond_opt_get_val(unsigned int option, u64 val);
-
-/* This helper is used to initialize a bond_opt_value structure for parameter
- * passing. There should be either a valid string or value, but not both.
- * When value is ULLONG_MAX then string will be used.
- */
-static inline void __bond_opt_init(struct bond_opt_value *optval,
-				   char *string, u64 value)
-{
-	memset(optval, 0, sizeof(*optval));
-	optval->value = ULLONG_MAX;
-	if (value == ULLONG_MAX)
-		optval->string = string;
-	else
-		optval->value = value;
-}
-#define bond_opt_initval(optval, value) __bond_opt_init(optval, NULL, value)
-#define bond_opt_initstr(optval, str) __bond_opt_init(optval, str, ULLONG_MAX)
-
-void bond_option_arp_ip_targets_clear(struct bonding *bond);
-
-#endif /* _BOND_OPTIONS_H */
diff --git a/drivers/net/bonding/bond_procfs.c b/drivers/net/bonding/bond_procfs.c
index a3948f8..976f5ad 100644
--- a/drivers/net/bonding/bond_procfs.c
+++ b/drivers/net/bonding/bond_procfs.c
@@ -2,7 +2,7 @@
 #include <linux/export.h>
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
-#include "bonding.h"
+#include <net/bonding.h>
 
 
 static void *bond_info_seq_start(struct seq_file *seq, loff_t *pos)
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 8ffbafd..7e9e151 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -40,7 +40,7 @@
 #include <net/netns/generic.h>
 #include <linux/nsproxy.h>
 
-#include "bonding.h"
+#include <net/bonding.h>
 
 #define to_dev(obj)	container_of(obj, struct device, kobj)
 #define to_bond(cd)	((struct bonding *)(netdev_priv(to_net_dev(cd))))
diff --git a/drivers/net/bonding/bond_sysfs_slave.c b/drivers/net/bonding/bond_sysfs_slave.c
index b01b0ce..23618a8 100644
--- a/drivers/net/bonding/bond_sysfs_slave.c
+++ b/drivers/net/bonding/bond_sysfs_slave.c
@@ -12,7 +12,7 @@
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
 
-#include "bonding.h"
+#include <net/bonding.h>
 
 struct slave_attribute {
 	struct attribute attr;
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
deleted file mode 100644
index bfb0b51..0000000
--- a/drivers/net/bonding/bonding.h
+++ /dev/null
@@ -1,654 +0,0 @@
-/*
- * Bond several ethernet interfaces into a Cisco, running 'Etherchannel'.
- *
- * Portions are (c) Copyright 1995 Simon "Guru Aleph-Null" Janes
- * NCM: Network and Communications Management, Inc.
- *
- * BUT, I'm the one who modified it for ethernet, so:
- * (c) Copyright 1999, Thomas Davis, tadavis@lbl.gov
- *
- *	This software may be used and distributed according to the terms
- *	of the GNU Public License, incorporated herein by reference.
- *
- */
-
-#ifndef _LINUX_BONDING_H
-#define _LINUX_BONDING_H
-
-#include <linux/timer.h>
-#include <linux/proc_fs.h>
-#include <linux/if_bonding.h>
-#include <linux/cpumask.h>
-#include <linux/in6.h>
-#include <linux/netpoll.h>
-#include <linux/inetdevice.h>
-#include <linux/etherdevice.h>
-#include <linux/reciprocal_div.h>
-#include <linux/if_link.h>
-
-#include "bond_3ad.h"
-#include "bond_alb.h"
-#include "bond_options.h"
-
-#define DRV_VERSION	"3.7.1"
-#define DRV_RELDATE	"April 27, 2011"
-#define DRV_NAME	"bonding"
-#define DRV_DESCRIPTION	"Ethernet Channel Bonding Driver"
-
-#define bond_version DRV_DESCRIPTION ": v" DRV_VERSION " (" DRV_RELDATE ")\n"
-
-#define BOND_MAX_ARP_TARGETS	16
-
-#define BOND_DEFAULT_MIIMON	100
-
-/*
- * Less bad way to call ioctl from within the kernel; this needs to be
- * done some other way to get the call out of interrupt context.
- * Needs "ioctl" variable to be supplied by calling context.
- */
-#define IOCTL(dev, arg, cmd) ({		\
-	int res = 0;			\
-	mm_segment_t fs = get_fs();	\
-	set_fs(get_ds());		\
-	res = ioctl(dev, arg, cmd);	\
-	set_fs(fs);			\
-	res; })
-
-#define BOND_MODE(bond) ((bond)->params.mode)
-
-/* slave list primitives */
-#define bond_slave_list(bond) (&(bond)->dev->adj_list.lower)
-
-#define bond_has_slaves(bond) !list_empty(bond_slave_list(bond))
-
-/* IMPORTANT: bond_first/last_slave can return NULL in case of an empty list */
-#define bond_first_slave(bond) \
-	(bond_has_slaves(bond) ? \
-		netdev_adjacent_get_private(bond_slave_list(bond)->next) : \
-		NULL)
-#define bond_last_slave(bond) \
-	(bond_has_slaves(bond) ? \
-		netdev_adjacent_get_private(bond_slave_list(bond)->prev) : \
-		NULL)
-
-/* Caller must have rcu_read_lock */
-#define bond_first_slave_rcu(bond) \
-	netdev_lower_get_first_private_rcu(bond->dev)
-
-#define bond_is_first_slave(bond, pos) (pos == bond_first_slave(bond))
-#define bond_is_last_slave(bond, pos) (pos == bond_last_slave(bond))
-
-/**
- * bond_for_each_slave - iterate over all slaves
- * @bond:	the bond holding this list
- * @pos:	current slave
- * @iter:	list_head * iterator
- *
- * Caller must hold RTNL
- */
-#define bond_for_each_slave(bond, pos, iter) \
-	netdev_for_each_lower_private((bond)->dev, pos, iter)
-
-/* Caller must have rcu_read_lock */
-#define bond_for_each_slave_rcu(bond, pos, iter) \
-	netdev_for_each_lower_private_rcu((bond)->dev, pos, iter)
-
-#ifdef CONFIG_NET_POLL_CONTROLLER
-extern atomic_t netpoll_block_tx;
-
-static inline void block_netpoll_tx(void)
-{
-	atomic_inc(&netpoll_block_tx);
-}
-
-static inline void unblock_netpoll_tx(void)
-{
-	atomic_dec(&netpoll_block_tx);
-}
-
-static inline int is_netpoll_tx_blocked(struct net_device *dev)
-{
-	if (unlikely(netpoll_tx_running(dev)))
-		return atomic_read(&netpoll_block_tx);
-	return 0;
-}
-#else
-#define block_netpoll_tx()
-#define unblock_netpoll_tx()
-#define is_netpoll_tx_blocked(dev) (0)
-#endif
-
-struct bond_params {
-	int mode;
-	int xmit_policy;
-	int miimon;
-	u8 num_peer_notif;
-	int arp_interval;
-	int arp_validate;
-	int arp_all_targets;
-	int use_carrier;
-	int fail_over_mac;
-	int updelay;
-	int downdelay;
-	int lacp_fast;
-	unsigned int min_links;
-	int ad_select;
-	char primary[IFNAMSIZ];
-	int primary_reselect;
-	__be32 arp_targets[BOND_MAX_ARP_TARGETS];
-	int tx_queues;
-	int all_slaves_active;
-	int resend_igmp;
-	int lp_interval;
-	int packets_per_slave;
-	int tlb_dynamic_lb;
-	struct reciprocal_value reciprocal_packets_per_slave;
-};
-
-struct bond_parm_tbl {
-	char *modename;
-	int mode;
-};
-
-struct slave {
-	struct net_device *dev; /* first - useful for panic debug */
-	struct bonding *bond; /* our master */
-	int    delay;
-	/* all three in jiffies */
-	unsigned long last_link_up;
-	unsigned long last_rx;
-	unsigned long target_last_arp_rx[BOND_MAX_ARP_TARGETS];
-	s8     link;    /* one of BOND_LINK_XXXX */
-	s8     new_link;
-	u8     backup:1,   /* indicates backup slave. Value corresponds with
-			      BOND_STATE_ACTIVE and BOND_STATE_BACKUP */
-	       inactive:1, /* indicates inactive slave */
-	       should_notify:1; /* indicateds whether the state changed */
-	u8     duplex;
-	u32    original_mtu;
-	u32    link_failure_count;
-	u32    speed;
-	u16    queue_id;
-	u8     perm_hwaddr[ETH_ALEN];
-	struct ad_slave_info *ad_info;
-	struct tlb_slave_info tlb_info;
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	struct netpoll *np;
-#endif
-	struct kobject kobj;
-	struct rtnl_link_stats64 slave_stats;
-};
-
-struct bond_up_slave {
-	unsigned int	count;
-	struct rcu_head rcu;
-	struct slave	*arr[0];
-};
-
-/*
- * Link pseudo-state only used internally by monitors
- */
-#define BOND_LINK_NOCHANGE -1
-
-/*
- * Here are the locking policies for the two bonding locks:
- * Get rcu_read_lock when reading or RTNL when writing slave list.
- */
-struct bonding {
-	struct   net_device *dev; /* first - useful for panic debug */
-	struct   slave __rcu *curr_active_slave;
-	struct   slave __rcu *current_arp_slave;
-	struct   slave __rcu *primary_slave;
-	struct   bond_up_slave __rcu *slave_arr; /* Array of usable slaves */
-	bool     force_primary;
-	s32      slave_cnt; /* never change this value outside the attach/detach wrappers */
-	int     (*recv_probe)(const struct sk_buff *, struct bonding *,
-			      struct slave *);
-	/* mode_lock is used for mode-specific locking needs, currently used by:
-	 * 3ad mode (4) - protect against running bond_3ad_unbind_slave() and
-	 *                bond_3ad_state_machine_handler() concurrently and also
-	 *                the access to the state machine shared variables.
-	 * TLB mode (5) - to sync the use and modifications of its hash table
-	 * ALB mode (6) - to sync the use and modifications of its hash table
-	 */
-	spinlock_t mode_lock;
-	u8	 send_peer_notif;
-	u8       igmp_retrans;
-#ifdef CONFIG_PROC_FS
-	struct   proc_dir_entry *proc_entry;
-	char     proc_file_name[IFNAMSIZ];
-#endif /* CONFIG_PROC_FS */
-	struct   list_head bond_list;
-	u32      rr_tx_counter;
-	struct   ad_bond_info ad_info;
-	struct   alb_bond_info alb_info;
-	struct   bond_params params;
-	struct   workqueue_struct *wq;
-	struct   delayed_work mii_work;
-	struct   delayed_work arp_work;
-	struct   delayed_work alb_work;
-	struct   delayed_work ad_work;
-	struct   delayed_work mcast_work;
-	struct   delayed_work slave_arr_work;
-#ifdef CONFIG_DEBUG_FS
-	/* debugging support via debugfs */
-	struct	 dentry *debug_dir;
-#endif /* CONFIG_DEBUG_FS */
-	struct rtnl_link_stats64 bond_stats;
-};
-
-#define bond_slave_get_rcu(dev) \
-	((struct slave *) rcu_dereference(dev->rx_handler_data))
-
-#define bond_slave_get_rtnl(dev) \
-	((struct slave *) rtnl_dereference(dev->rx_handler_data))
-
-struct bond_vlan_tag {
-	__be16		vlan_proto;
-	unsigned short	vlan_id;
-};
-
-/**
- * Returns NULL if the net_device does not belong to any of the bond's slaves
- *
- * Caller must hold bond lock for read
- */
-static inline struct slave *bond_get_slave_by_dev(struct bonding *bond,
-						  struct net_device *slave_dev)
-{
-	return netdev_lower_dev_get_private(bond->dev, slave_dev);
-}
-
-static inline struct bonding *bond_get_bond_by_slave(struct slave *slave)
-{
-	return slave->bond;
-}
-
-static inline bool bond_should_override_tx_queue(struct bonding *bond)
-{
-	return BOND_MODE(bond) == BOND_MODE_ACTIVEBACKUP ||
-	       BOND_MODE(bond) == BOND_MODE_ROUNDROBIN;
-}
-
-static inline bool bond_is_lb(const struct bonding *bond)
-{
-	return BOND_MODE(bond) == BOND_MODE_TLB ||
-	       BOND_MODE(bond) == BOND_MODE_ALB;
-}
-
-static inline bool bond_is_nondyn_tlb(const struct bonding *bond)
-{
-	return (BOND_MODE(bond) == BOND_MODE_TLB)  &&
-	       (bond->params.tlb_dynamic_lb == 0);
-}
-
-static inline bool bond_mode_uses_xmit_hash(const struct bonding *bond)
-{
-	return (BOND_MODE(bond) == BOND_MODE_8023AD ||
-		BOND_MODE(bond) == BOND_MODE_XOR ||
-		bond_is_nondyn_tlb(bond));
-}
-
-static inline bool bond_mode_uses_arp(int mode)
-{
-	return mode != BOND_MODE_8023AD && mode != BOND_MODE_TLB &&
-	       mode != BOND_MODE_ALB;
-}
-
-static inline bool bond_mode_uses_primary(int mode)
-{
-	return mode == BOND_MODE_ACTIVEBACKUP || mode == BOND_MODE_TLB ||
-	       mode == BOND_MODE_ALB;
-}
-
-static inline bool bond_uses_primary(struct bonding *bond)
-{
-	return bond_mode_uses_primary(BOND_MODE(bond));
-}
-
-static inline bool bond_slave_is_up(struct slave *slave)
-{
-	return netif_running(slave->dev) && netif_carrier_ok(slave->dev);
-}
-
-static inline void bond_set_active_slave(struct slave *slave)
-{
-	if (slave->backup) {
-		slave->backup = 0;
-		rtmsg_ifinfo(RTM_NEWLINK, slave->dev, 0, GFP_ATOMIC);
-	}
-}
-
-static inline void bond_set_backup_slave(struct slave *slave)
-{
-	if (!slave->backup) {
-		slave->backup = 1;
-		rtmsg_ifinfo(RTM_NEWLINK, slave->dev, 0, GFP_ATOMIC);
-	}
-}
-
-static inline void bond_set_slave_state(struct slave *slave,
-					int slave_state, bool notify)
-{
-	if (slave->backup == slave_state)
-		return;
-
-	slave->backup = slave_state;
-	if (notify) {
-		rtmsg_ifinfo(RTM_NEWLINK, slave->dev, 0, GFP_ATOMIC);
-		slave->should_notify = 0;
-	} else {
-		if (slave->should_notify)
-			slave->should_notify = 0;
-		else
-			slave->should_notify = 1;
-	}
-}
-
-static inline void bond_slave_state_change(struct bonding *bond)
-{
-	struct list_head *iter;
-	struct slave *tmp;
-
-	bond_for_each_slave(bond, tmp, iter) {
-		if (tmp->link == BOND_LINK_UP)
-			bond_set_active_slave(tmp);
-		else if (tmp->link == BOND_LINK_DOWN)
-			bond_set_backup_slave(tmp);
-	}
-}
-
-static inline void bond_slave_state_notify(struct bonding *bond)
-{
-	struct list_head *iter;
-	struct slave *tmp;
-
-	bond_for_each_slave(bond, tmp, iter) {
-		if (tmp->should_notify) {
-			rtmsg_ifinfo(RTM_NEWLINK, tmp->dev, 0, GFP_ATOMIC);
-			tmp->should_notify = 0;
-		}
-	}
-}
-
-static inline int bond_slave_state(struct slave *slave)
-{
-	return slave->backup;
-}
-
-static inline bool bond_is_active_slave(struct slave *slave)
-{
-	return !bond_slave_state(slave);
-}
-
-static inline bool bond_slave_can_tx(struct slave *slave)
-{
-	return bond_slave_is_up(slave) && slave->link == BOND_LINK_UP &&
-	       bond_is_active_slave(slave);
-}
-
-#define BOND_PRI_RESELECT_ALWAYS	0
-#define BOND_PRI_RESELECT_BETTER	1
-#define BOND_PRI_RESELECT_FAILURE	2
-
-#define BOND_FOM_NONE			0
-#define BOND_FOM_ACTIVE			1
-#define BOND_FOM_FOLLOW			2
-
-#define BOND_ARP_TARGETS_ANY		0
-#define BOND_ARP_TARGETS_ALL		1
-
-#define BOND_ARP_VALIDATE_NONE		0
-#define BOND_ARP_VALIDATE_ACTIVE	(1 << BOND_STATE_ACTIVE)
-#define BOND_ARP_VALIDATE_BACKUP	(1 << BOND_STATE_BACKUP)
-#define BOND_ARP_VALIDATE_ALL		(BOND_ARP_VALIDATE_ACTIVE | \
-					 BOND_ARP_VALIDATE_BACKUP)
-#define BOND_ARP_FILTER			(BOND_ARP_VALIDATE_ALL + 1)
-#define BOND_ARP_FILTER_ACTIVE		(BOND_ARP_VALIDATE_ACTIVE | \
-					 BOND_ARP_FILTER)
-#define BOND_ARP_FILTER_BACKUP		(BOND_ARP_VALIDATE_BACKUP | \
-					 BOND_ARP_FILTER)
-
-#define BOND_SLAVE_NOTIFY_NOW		true
-#define BOND_SLAVE_NOTIFY_LATER		false
-
-static inline int slave_do_arp_validate(struct bonding *bond,
-					struct slave *slave)
-{
-	return bond->params.arp_validate & (1 << bond_slave_state(slave));
-}
-
-static inline int slave_do_arp_validate_only(struct bonding *bond)
-{
-	return bond->params.arp_validate & BOND_ARP_FILTER;
-}
-
-static inline int bond_is_ip_target_ok(__be32 addr)
-{
-	return !ipv4_is_lbcast(addr) && !ipv4_is_zeronet(addr);
-}
-
-/* Get the oldest arp which we've received on this slave for bond's
- * arp_targets.
- */
-static inline unsigned long slave_oldest_target_arp_rx(struct bonding *bond,
-						       struct slave *slave)
-{
-	int i = 1;
-	unsigned long ret = slave->target_last_arp_rx[0];
-
-	for (; (i < BOND_MAX_ARP_TARGETS) && bond->params.arp_targets[i]; i++)
-		if (time_before(slave->target_last_arp_rx[i], ret))
-			ret = slave->target_last_arp_rx[i];
-
-	return ret;
-}
-
-static inline unsigned long slave_last_rx(struct bonding *bond,
-					struct slave *slave)
-{
-	if (bond->params.arp_all_targets == BOND_ARP_TARGETS_ALL)
-		return slave_oldest_target_arp_rx(bond, slave);
-
-	return slave->last_rx;
-}
-
-#ifdef CONFIG_NET_POLL_CONTROLLER
-static inline void bond_netpoll_send_skb(const struct slave *slave,
-					 struct sk_buff *skb)
-{
-	struct netpoll *np = slave->np;
-
-	if (np)
-		netpoll_send_skb(np, skb);
-}
-#else
-static inline void bond_netpoll_send_skb(const struct slave *slave,
-					 struct sk_buff *skb)
-{
-}
-#endif
-
-static inline void bond_set_slave_inactive_flags(struct slave *slave,
-						 bool notify)
-{
-	if (!bond_is_lb(slave->bond))
-		bond_set_slave_state(slave, BOND_STATE_BACKUP, notify);
-	if (!slave->bond->params.all_slaves_active)
-		slave->inactive = 1;
-}
-
-static inline void bond_set_slave_active_flags(struct slave *slave,
-					       bool notify)
-{
-	bond_set_slave_state(slave, BOND_STATE_ACTIVE, notify);
-	slave->inactive = 0;
-}
-
-static inline bool bond_is_slave_inactive(struct slave *slave)
-{
-	return slave->inactive;
-}
-
-static inline __be32 bond_confirm_addr(struct net_device *dev, __be32 dst, __be32 local)
-{
-	struct in_device *in_dev;
-	__be32 addr = 0;
-
-	rcu_read_lock();
-	in_dev = __in_dev_get_rcu(dev);
-
-	if (in_dev)
-		addr = inet_confirm_addr(dev_net(dev), in_dev, dst, local,
-					 RT_SCOPE_HOST);
-	rcu_read_unlock();
-	return addr;
-}
-
-struct bond_net {
-	struct net		*net;	/* Associated network namespace */
-	struct list_head	dev_list;
-#ifdef CONFIG_PROC_FS
-	struct proc_dir_entry	*proc_dir;
-#endif
-	struct class_attribute	class_attr_bonding_masters;
-};
-
-int bond_arp_rcv(const struct sk_buff *skb, struct bonding *bond, struct slave *slave);
-void bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb, struct net_device *slave_dev);
-int bond_create(struct net *net, const char *name);
-int bond_create_sysfs(struct bond_net *net);
-void bond_destroy_sysfs(struct bond_net *net);
-void bond_prepare_sysfs_group(struct bonding *bond);
-int bond_sysfs_slave_add(struct slave *slave);
-void bond_sysfs_slave_del(struct slave *slave);
-int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev);
-int bond_release(struct net_device *bond_dev, struct net_device *slave_dev);
-u32 bond_xmit_hash(struct bonding *bond, struct sk_buff *skb);
-void bond_select_active_slave(struct bonding *bond);
-void bond_change_active_slave(struct bonding *bond, struct slave *new_active);
-void bond_create_debugfs(void);
-void bond_destroy_debugfs(void);
-void bond_debug_register(struct bonding *bond);
-void bond_debug_unregister(struct bonding *bond);
-void bond_debug_reregister(struct bonding *bond);
-const char *bond_mode_name(int mode);
-void bond_setup(struct net_device *bond_dev);
-unsigned int bond_get_num_tx_queues(void);
-int bond_netlink_init(void);
-void bond_netlink_fini(void);
-struct net_device *bond_option_active_slave_get_rcu(struct bonding *bond);
-const char *bond_slave_link_status(s8 link);
-struct bond_vlan_tag *bond_verify_device_path(struct net_device *start_dev,
-					      struct net_device *end_dev,
-					      int level);
-int bond_update_slave_arr(struct bonding *bond, struct slave *skipslave);
-void bond_slave_arr_work_rearm(struct bonding *bond, unsigned long delay);
-
-#ifdef CONFIG_PROC_FS
-void bond_create_proc_entry(struct bonding *bond);
-void bond_remove_proc_entry(struct bonding *bond);
-void bond_create_proc_dir(struct bond_net *bn);
-void bond_destroy_proc_dir(struct bond_net *bn);
-#else
-static inline void bond_create_proc_entry(struct bonding *bond)
-{
-}
-
-static inline void bond_remove_proc_entry(struct bonding *bond)
-{
-}
-
-static inline void bond_create_proc_dir(struct bond_net *bn)
-{
-}
-
-static inline void bond_destroy_proc_dir(struct bond_net *bn)
-{
-}
-#endif
-
-static inline struct slave *bond_slave_has_mac(struct bonding *bond,
-					       const u8 *mac)
-{
-	struct list_head *iter;
-	struct slave *tmp;
-
-	bond_for_each_slave(bond, tmp, iter)
-		if (ether_addr_equal_64bits(mac, tmp->dev->dev_addr))
-			return tmp;
-
-	return NULL;
-}
-
-/* Caller must hold rcu_read_lock() for read */
-static inline struct slave *bond_slave_has_mac_rcu(struct bonding *bond,
-					       const u8 *mac)
-{
-	struct list_head *iter;
-	struct slave *tmp;
-
-	bond_for_each_slave_rcu(bond, tmp, iter)
-		if (ether_addr_equal_64bits(mac, tmp->dev->dev_addr))
-			return tmp;
-
-	return NULL;
-}
-
-/* Caller must hold rcu_read_lock() for read */
-static inline bool bond_slave_has_mac_rx(struct bonding *bond, const u8 *mac)
-{
-	struct list_head *iter;
-	struct slave *tmp;
-	struct netdev_hw_addr *ha;
-
-	bond_for_each_slave_rcu(bond, tmp, iter)
-		if (ether_addr_equal_64bits(mac, tmp->dev->dev_addr))
-			return true;
-
-	if (netdev_uc_empty(bond->dev))
-		return false;
-
-	netdev_for_each_uc_addr(ha, bond->dev)
-		if (ether_addr_equal_64bits(mac, ha->addr))
-			return true;
-
-	return false;
-}
-
-/* Check if the ip is present in arp ip list, or first free slot if ip == 0
- * Returns -1 if not found, index if found
- */
-static inline int bond_get_targets_ip(__be32 *targets, __be32 ip)
-{
-	int i;
-
-	for (i = 0; i < BOND_MAX_ARP_TARGETS; i++)
-		if (targets[i] == ip)
-			return i;
-		else if (targets[i] == 0)
-			break;
-
-	return -1;
-}
-
-/* exported from bond_main.c */
-extern int bond_net_id;
-extern const struct bond_parm_tbl bond_lacp_tbl[];
-extern const struct bond_parm_tbl xmit_hashtype_tbl[];
-extern const struct bond_parm_tbl arp_validate_tbl[];
-extern const struct bond_parm_tbl arp_all_targets_tbl[];
-extern const struct bond_parm_tbl fail_over_mac_tbl[];
-extern const struct bond_parm_tbl pri_reselect_tbl[];
-extern struct bond_parm_tbl ad_select_tbl[];
-
-/* exported from bond_netlink.c */
-extern struct rtnl_link_ops bond_link_ops;
-
-static inline void bond_tx_drop(struct net_device *dev, struct sk_buff *skb)
-{
-	atomic_long_inc(&dev->tx_dropped);
-	dev_kfree_skb_any(skb);
-}
-
-#endif /* _LINUX_BONDING_H */
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index a9c117f..d13d36a 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -61,6 +61,7 @@
 #include <net/neighbour.h>
 #include <net/netevent.h>
 #include <net/addrconf.h>
+#include <net/bonding.h>
 #include <asm/uaccess.h>
 
 #include "cxgb4.h"
@@ -71,8 +72,6 @@
 #include "cxgb4_debugfs.h"
 #include "l2t.h"
 
-#include <../drivers/net/bonding/bonding.h>
-
 #ifdef DRV_VERSION
 #undef DRV_VERSION
 #endif
diff --git a/include/net/bond_3ad.h b/include/net/bond_3ad.h
new file mode 100644
index 0000000..e01d903
--- /dev/null
+++ b/include/net/bond_3ad.h
@@ -0,0 +1,283 @@
+/*
+ * Copyright(c) 1999 - 2004 Intel Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by the Free
+ * Software Foundation; either version 2 of the License, or (at your option)
+ * any later version.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc., 59
+ * Temple Place - Suite 330, Boston, MA  02111-1307, USA.
+ *
+ * The full GNU General Public License is included in this distribution in the
+ * file called LICENSE.
+ *
+ */
+
+#ifndef _NET_BOND_3AD_H
+#define _NET_BOND_3AD_H
+
+#include <asm/byteorder.h>
+#include <linux/skbuff.h>
+#include <linux/netdevice.h>
+#include <linux/if_ether.h>
+
+/* General definitions */
+#define PKT_TYPE_LACPDU         cpu_to_be16(ETH_P_SLOW)
+#define AD_TIMER_INTERVAL       100 /*msec*/
+
+#define MULTICAST_LACPDU_ADDR    {0x01, 0x80, 0xC2, 0x00, 0x00, 0x02}
+
+#define AD_LACP_SLOW 0
+#define AD_LACP_FAST 1
+
+typedef struct mac_addr {
+	u8 mac_addr_value[ETH_ALEN];
+} __packed mac_addr_t;
+
+enum {
+	BOND_AD_STABLE = 0,
+	BOND_AD_BANDWIDTH = 1,
+	BOND_AD_COUNT = 2,
+};
+
+/* rx machine states(43.4.11 in the 802.3ad standard) */
+typedef enum {
+	AD_RX_DUMMY,
+	AD_RX_INITIALIZE,	/* rx Machine */
+	AD_RX_PORT_DISABLED,	/* rx Machine */
+	AD_RX_LACP_DISABLED,	/* rx Machine */
+	AD_RX_EXPIRED,		/* rx Machine */
+	AD_RX_DEFAULTED,	/* rx Machine */
+	AD_RX_CURRENT		/* rx Machine */
+} rx_states_t;
+
+/* periodic machine states(43.4.12 in the 802.3ad standard) */
+typedef enum {
+	AD_PERIODIC_DUMMY,
+	AD_NO_PERIODIC,		/* periodic machine */
+	AD_FAST_PERIODIC,	/* periodic machine */
+	AD_SLOW_PERIODIC,	/* periodic machine */
+	AD_PERIODIC_TX		/* periodic machine */
+} periodic_states_t;
+
+/* mux machine states(43.4.13 in the 802.3ad standard) */
+typedef enum {
+	AD_MUX_DUMMY,
+	AD_MUX_DETACHED,	/* mux machine */
+	AD_MUX_WAITING,		/* mux machine */
+	AD_MUX_ATTACHED,	/* mux machine */
+	AD_MUX_COLLECTING_DISTRIBUTING	/* mux machine */
+} mux_states_t;
+
+/* tx machine states(43.4.15 in the 802.3ad standard) */
+typedef enum {
+	AD_TX_DUMMY,
+	AD_TRANSMIT		/* tx Machine */
+} tx_states_t;
+
+/* rx indication types */
+typedef enum {
+	AD_TYPE_LACPDU = 1,	/* type lacpdu */
+	AD_TYPE_MARKER		/* type marker */
+} pdu_type_t;
+
+/* rx marker indication types */
+typedef enum {
+	AD_MARKER_INFORMATION_SUBTYPE = 1,	/* marker imformation subtype */
+	AD_MARKER_RESPONSE_SUBTYPE		/* marker response subtype */
+} bond_marker_subtype_t;
+
+/* timers types(43.4.9 in the 802.3ad standard) */
+typedef enum {
+	AD_CURRENT_WHILE_TIMER,
+	AD_ACTOR_CHURN_TIMER,
+	AD_PERIODIC_TIMER,
+	AD_PARTNER_CHURN_TIMER,
+	AD_WAIT_WHILE_TIMER
+} ad_timers_t;
+
+#pragma pack(1)
+
+/* Link Aggregation Control Protocol(LACP) data unit structure(43.4.2.2 in the 802.3ad standard) */
+typedef struct lacpdu {
+	u8 subtype;		/* = LACP(= 0x01) */
+	u8 version_number;
+	u8 tlv_type_actor_info;	/* = actor information(type/length/value) */
+	u8 actor_information_length;	/* = 20 */
+	__be16 actor_system_priority;
+	struct mac_addr actor_system;
+	__be16 actor_key;
+	__be16 actor_port_priority;
+	__be16 actor_port;
+	u8 actor_state;
+	u8 reserved_3_1[3];		/* = 0 */
+	u8 tlv_type_partner_info;	/* = partner information */
+	u8 partner_information_length;	/* = 20 */
+	__be16 partner_system_priority;
+	struct mac_addr partner_system;
+	__be16 partner_key;
+	__be16 partner_port_priority;
+	__be16 partner_port;
+	u8 partner_state;
+	u8 reserved_3_2[3];		/* = 0 */
+	u8 tlv_type_collector_info;	/* = collector information */
+	u8 collector_information_length;/* = 16 */
+	__be16 collector_max_delay;
+	u8 reserved_12[12];
+	u8 tlv_type_terminator;		/* = terminator */
+	u8 terminator_length;		/* = 0 */
+	u8 reserved_50[50];		/* = 0 */
+} __packed lacpdu_t;
+
+typedef struct lacpdu_header {
+	struct ethhdr hdr;
+	struct lacpdu lacpdu;
+} __packed lacpdu_header_t;
+
+/* Marker Protocol Data Unit(PDU) structure(43.5.3.2 in the 802.3ad standard) */
+typedef struct bond_marker {
+	u8 subtype;		/* = 0x02  (marker PDU) */
+	u8 version_number;	/* = 0x01 */
+	u8 tlv_type;		/* = 0x01  (marker information) */
+	/* = 0x02  (marker response information) */
+	u8 marker_length;	/* = 0x16 */
+	u16 requester_port;	/* The number assigned to the port by the requester */
+	struct mac_addr requester_system;	/* The requester's system id */
+	u32 requester_transaction_id;		/* The transaction id allocated by the requester, */
+	u16 pad;		/* = 0 */
+	u8 tlv_type_terminator;	/* = 0x00 */
+	u8 terminator_length;	/* = 0x00 */
+	u8 reserved_90[90];	/* = 0 */
+} __packed bond_marker_t;
+
+typedef struct bond_marker_header {
+	struct ethhdr hdr;
+	struct bond_marker marker;
+} __packed bond_marker_header_t;
+
+#pragma pack()
+
+struct slave;
+struct bonding;
+struct ad_info;
+struct port;
+
+#ifdef __ia64__
+#pragma pack(8)
+#endif
+
+/* aggregator structure(43.4.5 in the 802.3ad standard) */
+typedef struct aggregator {
+	struct mac_addr aggregator_mac_address;
+	u16 aggregator_identifier;
+	bool is_individual;
+	u16 actor_admin_aggregator_key;
+	u16 actor_oper_aggregator_key;
+	struct mac_addr partner_system;
+	u16 partner_system_priority;
+	u16 partner_oper_aggregator_key;
+	u16 receive_state;	/* BOOLEAN */
+	u16 transmit_state;	/* BOOLEAN */
+	struct port *lag_ports;
+	/* ****** PRIVATE PARAMETERS ****** */
+	struct slave *slave;	/* pointer to the bond slave that this aggregator belongs to */
+	u16 is_active;		/* BOOLEAN. Indicates if this aggregator is active */
+	u16 num_of_ports;
+} aggregator_t;
+
+struct port_params {
+	struct mac_addr system;
+	u16 system_priority;
+	u16 key;
+	u16 port_number;
+	u16 port_priority;
+	u16 port_state;
+};
+
+/* port structure(43.4.6 in the 802.3ad standard) */
+typedef struct port {
+	u16 actor_port_number;
+	u16 actor_port_priority;
+	struct mac_addr actor_system;	/* This parameter is added here although it is not specified in the standard, just for simplification */
+	u16 actor_system_priority;	/* This parameter is added here although it is not specified in the standard, just for simplification */
+	u16 actor_port_aggregator_identifier;
+	bool ntt;
+	u16 actor_admin_port_key;
+	u16 actor_oper_port_key;
+	u8 actor_admin_port_state;
+	u8 actor_oper_port_state;
+
+	struct port_params partner_admin;
+	struct port_params partner_oper;
+
+	bool is_enabled;
+
+	/* ****** PRIVATE PARAMETERS ****** */
+	u16 sm_vars;		/* all state machines variables for this port */
+	rx_states_t sm_rx_state;	/* state machine rx state */
+	u16 sm_rx_timer_counter;	/* state machine rx timer counter */
+	periodic_states_t sm_periodic_state;	/* state machine periodic state */
+	u16 sm_periodic_timer_counter;	/* state machine periodic timer counter */
+	mux_states_t sm_mux_state;	/* state machine mux state */
+	u16 sm_mux_timer_counter;	/* state machine mux timer counter */
+	tx_states_t sm_tx_state;	/* state machine tx state */
+	u16 sm_tx_timer_counter;	/* state machine tx timer counter(allways on - enter to transmit state 3 time per second) */
+	struct slave *slave;		/* pointer to the bond slave that this port belongs to */
+	struct aggregator *aggregator;	/* pointer to an aggregator that this port related to */
+	struct port *next_port_in_aggregator;	/* Next port on the linked list of the parent aggregator */
+	u32 transaction_id;		/* continuous number for identification of Marker PDU's; */
+	struct lacpdu lacpdu;		/* the lacpdu that will be sent for this port */
+} port_t;
+
+/* system structure */
+struct ad_system {
+	u16 sys_priority;
+	struct mac_addr sys_mac_addr;
+};
+
+#ifdef __ia64__
+#pragma pack()
+#endif
+
+/* ========== AD Exported structures to the main bonding code ========== */
+#define BOND_AD_INFO(bond)   ((bond)->ad_info)
+#define SLAVE_AD_INFO(slave) ((slave)->ad_info)
+
+struct ad_bond_info {
+	struct ad_system system;	/* 802.3ad system structure */
+	u32 agg_select_timer;		/* Timer to select aggregator after all adapter's hand shakes */
+	u16 aggregator_identifier;
+};
+
+struct ad_slave_info {
+	struct aggregator aggregator;	/* 802.3ad aggregator structure */
+	struct port port;		/* 802.3ad port structure */
+	u16 id;
+};
+
+/* ========== AD Exported functions to the main bonding code ========== */
+void bond_3ad_initialize(struct bonding *bond, u16 tick_resolution);
+void bond_3ad_bind_slave(struct slave *slave);
+void bond_3ad_unbind_slave(struct slave *slave);
+void bond_3ad_state_machine_handler(struct work_struct *);
+void bond_3ad_initiate_agg_selection(struct bonding *bond, int timeout);
+void bond_3ad_adapter_speed_changed(struct slave *slave);
+void bond_3ad_adapter_duplex_changed(struct slave *slave);
+void bond_3ad_handle_link_change(struct slave *slave, char link);
+int  bond_3ad_get_active_agg_info(struct bonding *bond, struct ad_info *ad_info);
+int  __bond_3ad_get_active_agg_info(struct bonding *bond,
+				    struct ad_info *ad_info);
+int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev);
+int bond_3ad_lacpdu_recv(const struct sk_buff *skb, struct bonding *bond,
+			 struct slave *slave);
+int bond_3ad_set_carrier(struct bonding *bond);
+void bond_3ad_update_lacp_rate(struct bonding *bond);
+#endif /* _NET_BOND_3AD_H */
+
diff --git a/include/net/bond_alb.h b/include/net/bond_alb.h
new file mode 100644
index 0000000..313a8d3
--- /dev/null
+++ b/include/net/bond_alb.h
@@ -0,0 +1,181 @@
+/*
+ * Copyright(c) 1999 - 2004 Intel Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by the
+ * Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
+ * or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
+ * for more details.
+ *
+ * You should have received a copy of the GNU General Public License along
+ * with this program; if not, see <http://www.gnu.org/licenses/>.
+ *
+ * The full GNU General Public License is included in this distribution in the
+ * file called LICENSE.
+ *
+ */
+
+#ifndef _NET_BOND_ALB_H
+#define _NET_BOND_ALB_H
+
+#include <linux/if_ether.h>
+
+struct bonding;
+struct slave;
+
+#define BOND_ALB_INFO(bond)   ((bond)->alb_info)
+#define SLAVE_TLB_INFO(slave) ((slave)->tlb_info)
+
+#define ALB_TIMER_TICKS_PER_SEC	    10	/* should be a divisor of HZ */
+#define BOND_TLB_REBALANCE_INTERVAL 10	/* In seconds, periodic re-balancing.
+					 * Used for division - never set
+					 * to zero !!!
+					 */
+#define BOND_ALB_DEFAULT_LP_INTERVAL 1
+#define BOND_ALB_LP_INTERVAL(bond) (bond->params.lp_interval)	/* In seconds, periodic send of
+								 * learning packets to the switch
+								 */
+
+#define BOND_TLB_REBALANCE_TICKS (BOND_TLB_REBALANCE_INTERVAL \
+				  * ALB_TIMER_TICKS_PER_SEC)
+
+#define BOND_ALB_LP_TICKS(bond) (BOND_ALB_LP_INTERVAL(bond) \
+			   * ALB_TIMER_TICKS_PER_SEC)
+
+#define TLB_HASH_TABLE_SIZE 256	/* The size of the clients hash table.
+				 * Note that this value MUST NOT be smaller
+				 * because the key hash table is BYTE wide !
+				 */
+
+
+#define TLB_NULL_INDEX		0xffffffff
+
+/* rlb defs */
+#define RLB_HASH_TABLE_SIZE	256
+#define RLB_NULL_INDEX		0xffffffff
+#define RLB_UPDATE_DELAY	(2*ALB_TIMER_TICKS_PER_SEC) /* 2 seconds */
+#define RLB_ARP_BURST_SIZE	2
+#define RLB_UPDATE_RETRY	3 /* 3-ticks - must be smaller than the rlb
+				   * rebalance interval (5 min).
+				   */
+/* RLB_PROMISC_TIMEOUT = 10 sec equals the time that the current slave is
+ * promiscuous after failover
+ */
+#define RLB_PROMISC_TIMEOUT	(10*ALB_TIMER_TICKS_PER_SEC)
+
+
+struct tlb_client_info {
+	struct slave *tx_slave;	/* A pointer to slave used for transmiting
+				 * packets to a Client that the Hash function
+				 * gave this entry index.
+				 */
+	u32 tx_bytes;		/* Each Client accumulates the BytesTx that
+				 * were transmitted to it, and after each
+				 * CallBack the LoadHistory is divided
+				 * by the balance interval
+				 */
+	u32 load_history;	/* This field contains the amount of Bytes
+				 * that were transmitted to this client by
+				 * the server on the previous balance
+				 * interval in Bps.
+				 */
+	u32 next;		/* The next Hash table entry index, assigned
+				 * to use the same adapter for transmit.
+				 */
+	u32 prev;		/* The previous Hash table entry index,
+				 * assigned to use the same
+				 */
+};
+
+/* -------------------------------------------------------------------------
+ * struct rlb_client_info contains all info related to a specific rx client
+ * connection. This is the Clients Hash Table entry struct.
+ * Note that this is not a proper hash table; if a new client's IP address
+ * hash collides with an existing client entry, the old entry is replaced.
+ *
+ * There is a linked list (linked by the used_next and used_prev members)
+ * linking all the used entries of the hash table. This allows updating
+ * all the clients without walking over all the unused elements of the table.
+ *
+ * There are also linked lists of entries with identical hash(ip_src). These
+ * allow cleaning up the table from ip_src<->mac_src associations that have
+ * become outdated and would cause sending out invalid ARP updates to the
+ * network. These are linked by the (src_next and src_prev members).
+ * -------------------------------------------------------------------------
+ */
+struct rlb_client_info {
+	__be32 ip_src;		/* the server IP address */
+	__be32 ip_dst;		/* the client IP address */
+	u8  mac_src[ETH_ALEN];	/* the server MAC address */
+	u8  mac_dst[ETH_ALEN];	/* the client MAC address */
+
+	/* list of used hash table entries, starting at rx_hashtbl_used_head */
+	u32 used_next;
+	u32 used_prev;
+
+	/* ip_src based hashing */
+	u32 src_next;	/* next entry with same hash(ip_src) */
+	u32 src_prev;	/* prev entry with same hash(ip_src) */
+	u32 src_first;	/* first entry with hash(ip_src) == this entry's index */
+
+	u8  assigned;		/* checking whether this entry is assigned */
+	u8  ntt;		/* flag - need to transmit client info */
+	struct slave *slave;	/* the slave assigned to this client */
+	unsigned short vlan_id;	/* VLAN tag associated with IP address */
+};
+
+struct tlb_slave_info {
+	u32 head;	/* Index to the head of the bi-directional clients
+			 * hash table entries list. The entries in the list
+			 * are the entries that were assigned to use this
+			 * slave for transmit.
+			 */
+	u32 load;	/* Each slave sums the loadHistory of all clients
+			 * assigned to it
+			 */
+};
+
+struct alb_bond_info {
+	struct tlb_client_info	*tx_hashtbl; /* Dynamically allocated */
+	u32			unbalanced_load;
+	int			tx_rebalance_counter;
+	int			lp_counter;
+	/* -------- rlb parameters -------- */
+	int rlb_enabled;
+	struct rlb_client_info	*rx_hashtbl;	/* Receive hash table */
+	u32			rx_hashtbl_used_head;
+	u8			rx_ntt;	/* flag - need to transmit
+					 * to all rx clients
+					 */
+	struct slave		*rx_slave;/* last slave to xmit from */
+	u8			primary_is_promisc;	   /* boolean */
+	u32			rlb_promisc_timeout_counter;/* counts primary
+							     * promiscuity time
+							     */
+	u32			rlb_update_delay_counter;
+	u32			rlb_update_retry_counter;/* counter of retries
+							  * of client update
+							  */
+	u8			rlb_rebalance;	/* flag - indicates that the
+						 * rx traffic should be
+						 * rebalanced
+						 */
+};
+
+int bond_alb_initialize(struct bonding *bond, int rlb_enabled);
+void bond_alb_deinitialize(struct bonding *bond);
+int bond_alb_init_slave(struct bonding *bond, struct slave *slave);
+void bond_alb_deinit_slave(struct bonding *bond, struct slave *slave);
+void bond_alb_handle_link_change(struct bonding *bond, struct slave *slave, char link);
+void bond_alb_handle_active_change(struct bonding *bond, struct slave *new_slave);
+int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev);
+int bond_tlb_xmit(struct sk_buff *skb, struct net_device *bond_dev);
+void bond_alb_monitor(struct work_struct *);
+int bond_alb_set_mac_address(struct net_device *bond_dev, void *addr);
+void bond_alb_clear_vlan(struct bonding *bond, unsigned short vlan_id);
+#endif /* _NET_BOND_ALB_H */
+
diff --git a/include/net/bond_options.h b/include/net/bond_options.h
new file mode 100644
index 0000000..ea6546d
--- /dev/null
+++ b/include/net/bond_options.h
@@ -0,0 +1,130 @@
+/*
+ * drivers/net/bond/bond_options.h - bonding options
+ * Copyright (c) 2013 Nikolay Aleksandrov <nikolay@redhat.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#ifndef _NET_BOND_OPTIONS_H
+#define _NET_BOND_OPTIONS_H
+
+#define BOND_OPT_MAX_NAMELEN 32
+#define BOND_OPT_VALID(opt) ((opt) < BOND_OPT_LAST)
+#define BOND_MODE_ALL_EX(x) (~(x))
+
+/* Option flags:
+ * BOND_OPTFLAG_NOSLAVES - check if the bond device is empty before setting
+ * BOND_OPTFLAG_IFDOWN - check if the bond device is down before setting
+ * BOND_OPTFLAG_RAWVAL - the option parses the value itself
+ */
+enum {
+	BOND_OPTFLAG_NOSLAVES	= BIT(0),
+	BOND_OPTFLAG_IFDOWN	= BIT(1),
+	BOND_OPTFLAG_RAWVAL	= BIT(2)
+};
+
+/* Value type flags:
+ * BOND_VALFLAG_DEFAULT - mark the value as default
+ * BOND_VALFLAG_(MIN|MAX) - mark the value as min/max
+ */
+enum {
+	BOND_VALFLAG_DEFAULT	= BIT(0),
+	BOND_VALFLAG_MIN	= BIT(1),
+	BOND_VALFLAG_MAX	= BIT(2)
+};
+
+/* Option IDs, their bit positions correspond to their IDs */
+enum {
+	BOND_OPT_MODE,
+	BOND_OPT_PACKETS_PER_SLAVE,
+	BOND_OPT_XMIT_HASH,
+	BOND_OPT_ARP_VALIDATE,
+	BOND_OPT_ARP_ALL_TARGETS,
+	BOND_OPT_FAIL_OVER_MAC,
+	BOND_OPT_ARP_INTERVAL,
+	BOND_OPT_ARP_TARGETS,
+	BOND_OPT_DOWNDELAY,
+	BOND_OPT_UPDELAY,
+	BOND_OPT_LACP_RATE,
+	BOND_OPT_MINLINKS,
+	BOND_OPT_AD_SELECT,
+	BOND_OPT_NUM_PEER_NOTIF,
+	BOND_OPT_MIIMON,
+	BOND_OPT_PRIMARY,
+	BOND_OPT_PRIMARY_RESELECT,
+	BOND_OPT_USE_CARRIER,
+	BOND_OPT_ACTIVE_SLAVE,
+	BOND_OPT_QUEUE_ID,
+	BOND_OPT_ALL_SLAVES_ACTIVE,
+	BOND_OPT_RESEND_IGMP,
+	BOND_OPT_LP_INTERVAL,
+	BOND_OPT_SLAVES,
+	BOND_OPT_TLB_DYNAMIC_LB,
+	BOND_OPT_LAST
+};
+
+/* This structure is used for storing option values and for passing option
+ * values when changing an option. The logic when used as an arg is as follows:
+ * - if string != NULL -> parse it, if the opt is RAW type then return it, else
+ *   return the parse result
+ * - if string == NULL -> parse value
+ */
+struct bond_opt_value {
+	char *string;
+	u64 value;
+	u32 flags;
+};
+
+struct bonding;
+
+struct bond_option {
+	int id;
+	const char *name;
+	const char *desc;
+	u32 flags;
+
+	/* unsuppmodes is used to denote modes in which the option isn't
+	 * supported.
+	 */
+	unsigned long unsuppmodes;
+	/* supported values which this option can have, can be a subset of
+	 * BOND_OPTVAL_RANGE's value range
+	 */
+	const struct bond_opt_value *values;
+
+	int (*set)(struct bonding *bond, const struct bond_opt_value *val);
+};
+
+int __bond_opt_set(struct bonding *bond, unsigned int option,
+		   struct bond_opt_value *val);
+int bond_opt_tryset_rtnl(struct bonding *bond, unsigned int option, char *buf);
+
+const struct bond_opt_value *bond_opt_parse(const struct bond_option *opt,
+					    struct bond_opt_value *val);
+const struct bond_option *bond_opt_get(unsigned int option);
+const struct bond_option *bond_opt_get_by_name(const char *name);
+const struct bond_opt_value *bond_opt_get_val(unsigned int option, u64 val);
+
+/* This helper is used to initialize a bond_opt_value structure for parameter
+ * passing. There should be either a valid string or value, but not both.
+ * When value is ULLONG_MAX then string will be used.
+ */
+static inline void __bond_opt_init(struct bond_opt_value *optval,
+				   char *string, u64 value)
+{
+	memset(optval, 0, sizeof(*optval));
+	optval->value = ULLONG_MAX;
+	if (value == ULLONG_MAX)
+		optval->string = string;
+	else
+		optval->value = value;
+}
+#define bond_opt_initval(optval, value) __bond_opt_init(optval, NULL, value)
+#define bond_opt_initstr(optval, str) __bond_opt_init(optval, str, ULLONG_MAX)
+
+void bond_option_arp_ip_targets_clear(struct bonding *bond);
+
+#endif /* _NET_BOND_OPTIONS_H */
diff --git a/include/net/bonding.h b/include/net/bonding.h
new file mode 100644
index 0000000..983a94b
--- /dev/null
+++ b/include/net/bonding.h
@@ -0,0 +1,654 @@
+/*
+ * Bond several ethernet interfaces into a Cisco, running 'Etherchannel'.
+ *
+ * Portions are (c) Copyright 1995 Simon "Guru Aleph-Null" Janes
+ * NCM: Network and Communications Management, Inc.
+ *
+ * BUT, I'm the one who modified it for ethernet, so:
+ * (c) Copyright 1999, Thomas Davis, tadavis@lbl.gov
+ *
+ *	This software may be used and distributed according to the terms
+ *	of the GNU Public License, incorporated herein by reference.
+ *
+ */
+
+#ifndef _NET_BONDING_H
+#define _NET_BONDING_H
+
+#include <linux/timer.h>
+#include <linux/proc_fs.h>
+#include <linux/if_bonding.h>
+#include <linux/cpumask.h>
+#include <linux/in6.h>
+#include <linux/netpoll.h>
+#include <linux/inetdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/reciprocal_div.h>
+#include <linux/if_link.h>
+
+#include <net/bond_3ad.h>
+#include <net/bond_alb.h>
+#include <net/bond_options.h>
+
+#define DRV_VERSION	"3.7.1"
+#define DRV_RELDATE	"April 27, 2011"
+#define DRV_NAME	"bonding"
+#define DRV_DESCRIPTION	"Ethernet Channel Bonding Driver"
+
+#define bond_version DRV_DESCRIPTION ": v" DRV_VERSION " (" DRV_RELDATE ")\n"
+
+#define BOND_MAX_ARP_TARGETS	16
+
+#define BOND_DEFAULT_MIIMON	100
+
+/*
+ * Less bad way to call ioctl from within the kernel; this needs to be
+ * done some other way to get the call out of interrupt context.
+ * Needs "ioctl" variable to be supplied by calling context.
+ */
+#define IOCTL(dev, arg, cmd) ({		\
+	int res = 0;			\
+	mm_segment_t fs = get_fs();	\
+	set_fs(get_ds());		\
+	res = ioctl(dev, arg, cmd);	\
+	set_fs(fs);			\
+	res; })
+
+#define BOND_MODE(bond) ((bond)->params.mode)
+
+/* slave list primitives */
+#define bond_slave_list(bond) (&(bond)->dev->adj_list.lower)
+
+#define bond_has_slaves(bond) !list_empty(bond_slave_list(bond))
+
+/* IMPORTANT: bond_first/last_slave can return NULL in case of an empty list */
+#define bond_first_slave(bond) \
+	(bond_has_slaves(bond) ? \
+		netdev_adjacent_get_private(bond_slave_list(bond)->next) : \
+		NULL)
+#define bond_last_slave(bond) \
+	(bond_has_slaves(bond) ? \
+		netdev_adjacent_get_private(bond_slave_list(bond)->prev) : \
+		NULL)
+
+/* Caller must have rcu_read_lock */
+#define bond_first_slave_rcu(bond) \
+	netdev_lower_get_first_private_rcu(bond->dev)
+
+#define bond_is_first_slave(bond, pos) (pos == bond_first_slave(bond))
+#define bond_is_last_slave(bond, pos) (pos == bond_last_slave(bond))
+
+/**
+ * bond_for_each_slave - iterate over all slaves
+ * @bond:	the bond holding this list
+ * @pos:	current slave
+ * @iter:	list_head * iterator
+ *
+ * Caller must hold RTNL
+ */
+#define bond_for_each_slave(bond, pos, iter) \
+	netdev_for_each_lower_private((bond)->dev, pos, iter)
+
+/* Caller must have rcu_read_lock */
+#define bond_for_each_slave_rcu(bond, pos, iter) \
+	netdev_for_each_lower_private_rcu((bond)->dev, pos, iter)
+
+#ifdef CONFIG_NET_POLL_CONTROLLER
+extern atomic_t netpoll_block_tx;
+
+static inline void block_netpoll_tx(void)
+{
+	atomic_inc(&netpoll_block_tx);
+}
+
+static inline void unblock_netpoll_tx(void)
+{
+	atomic_dec(&netpoll_block_tx);
+}
+
+static inline int is_netpoll_tx_blocked(struct net_device *dev)
+{
+	if (unlikely(netpoll_tx_running(dev)))
+		return atomic_read(&netpoll_block_tx);
+	return 0;
+}
+#else
+#define block_netpoll_tx()
+#define unblock_netpoll_tx()
+#define is_netpoll_tx_blocked(dev) (0)
+#endif
+
+struct bond_params {
+	int mode;
+	int xmit_policy;
+	int miimon;
+	u8 num_peer_notif;
+	int arp_interval;
+	int arp_validate;
+	int arp_all_targets;
+	int use_carrier;
+	int fail_over_mac;
+	int updelay;
+	int downdelay;
+	int lacp_fast;
+	unsigned int min_links;
+	int ad_select;
+	char primary[IFNAMSIZ];
+	int primary_reselect;
+	__be32 arp_targets[BOND_MAX_ARP_TARGETS];
+	int tx_queues;
+	int all_slaves_active;
+	int resend_igmp;
+	int lp_interval;
+	int packets_per_slave;
+	int tlb_dynamic_lb;
+	struct reciprocal_value reciprocal_packets_per_slave;
+};
+
+struct bond_parm_tbl {
+	char *modename;
+	int mode;
+};
+
+struct slave {
+	struct net_device *dev; /* first - useful for panic debug */
+	struct bonding *bond; /* our master */
+	int    delay;
+	/* all three in jiffies */
+	unsigned long last_link_up;
+	unsigned long last_rx;
+	unsigned long target_last_arp_rx[BOND_MAX_ARP_TARGETS];
+	s8     link;    /* one of BOND_LINK_XXXX */
+	s8     new_link;
+	u8     backup:1,   /* indicates backup slave. Value corresponds with
+			      BOND_STATE_ACTIVE and BOND_STATE_BACKUP */
+	       inactive:1, /* indicates inactive slave */
+	       should_notify:1; /* indicateds whether the state changed */
+	u8     duplex;
+	u32    original_mtu;
+	u32    link_failure_count;
+	u32    speed;
+	u16    queue_id;
+	u8     perm_hwaddr[ETH_ALEN];
+	struct ad_slave_info *ad_info;
+	struct tlb_slave_info tlb_info;
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	struct netpoll *np;
+#endif
+	struct kobject kobj;
+	struct rtnl_link_stats64 slave_stats;
+};
+
+struct bond_up_slave {
+	unsigned int	count;
+	struct rcu_head rcu;
+	struct slave	*arr[0];
+};
+
+/*
+ * Link pseudo-state only used internally by monitors
+ */
+#define BOND_LINK_NOCHANGE -1
+
+/*
+ * Here are the locking policies for the two bonding locks:
+ * Get rcu_read_lock when reading or RTNL when writing slave list.
+ */
+struct bonding {
+	struct   net_device *dev; /* first - useful for panic debug */
+	struct   slave __rcu *curr_active_slave;
+	struct   slave __rcu *current_arp_slave;
+	struct   slave __rcu *primary_slave;
+	struct   bond_up_slave __rcu *slave_arr; /* Array of usable slaves */
+	bool     force_primary;
+	s32      slave_cnt; /* never change this value outside the attach/detach wrappers */
+	int     (*recv_probe)(const struct sk_buff *, struct bonding *,
+			      struct slave *);
+	/* mode_lock is used for mode-specific locking needs, currently used by:
+	 * 3ad mode (4) - protect against running bond_3ad_unbind_slave() and
+	 *                bond_3ad_state_machine_handler() concurrently and also
+	 *                the access to the state machine shared variables.
+	 * TLB mode (5) - to sync the use and modifications of its hash table
+	 * ALB mode (6) - to sync the use and modifications of its hash table
+	 */
+	spinlock_t mode_lock;
+	u8	 send_peer_notif;
+	u8       igmp_retrans;
+#ifdef CONFIG_PROC_FS
+	struct   proc_dir_entry *proc_entry;
+	char     proc_file_name[IFNAMSIZ];
+#endif /* CONFIG_PROC_FS */
+	struct   list_head bond_list;
+	u32      rr_tx_counter;
+	struct   ad_bond_info ad_info;
+	struct   alb_bond_info alb_info;
+	struct   bond_params params;
+	struct   workqueue_struct *wq;
+	struct   delayed_work mii_work;
+	struct   delayed_work arp_work;
+	struct   delayed_work alb_work;
+	struct   delayed_work ad_work;
+	struct   delayed_work mcast_work;
+	struct   delayed_work slave_arr_work;
+#ifdef CONFIG_DEBUG_FS
+	/* debugging support via debugfs */
+	struct	 dentry *debug_dir;
+#endif /* CONFIG_DEBUG_FS */
+	struct rtnl_link_stats64 bond_stats;
+};
+
+#define bond_slave_get_rcu(dev) \
+	((struct slave *) rcu_dereference(dev->rx_handler_data))
+
+#define bond_slave_get_rtnl(dev) \
+	((struct slave *) rtnl_dereference(dev->rx_handler_data))
+
+struct bond_vlan_tag {
+	__be16		vlan_proto;
+	unsigned short	vlan_id;
+};
+
+/**
+ * Returns NULL if the net_device does not belong to any of the bond's slaves
+ *
+ * Caller must hold bond lock for read
+ */
+static inline struct slave *bond_get_slave_by_dev(struct bonding *bond,
+						  struct net_device *slave_dev)
+{
+	return netdev_lower_dev_get_private(bond->dev, slave_dev);
+}
+
+static inline struct bonding *bond_get_bond_by_slave(struct slave *slave)
+{
+	return slave->bond;
+}
+
+static inline bool bond_should_override_tx_queue(struct bonding *bond)
+{
+	return BOND_MODE(bond) == BOND_MODE_ACTIVEBACKUP ||
+	       BOND_MODE(bond) == BOND_MODE_ROUNDROBIN;
+}
+
+static inline bool bond_is_lb(const struct bonding *bond)
+{
+	return BOND_MODE(bond) == BOND_MODE_TLB ||
+	       BOND_MODE(bond) == BOND_MODE_ALB;
+}
+
+static inline bool bond_is_nondyn_tlb(const struct bonding *bond)
+{
+	return (BOND_MODE(bond) == BOND_MODE_TLB)  &&
+	       (bond->params.tlb_dynamic_lb == 0);
+}
+
+static inline bool bond_mode_uses_xmit_hash(const struct bonding *bond)
+{
+	return (BOND_MODE(bond) == BOND_MODE_8023AD ||
+		BOND_MODE(bond) == BOND_MODE_XOR ||
+		bond_is_nondyn_tlb(bond));
+}
+
+static inline bool bond_mode_uses_arp(int mode)
+{
+	return mode != BOND_MODE_8023AD && mode != BOND_MODE_TLB &&
+	       mode != BOND_MODE_ALB;
+}
+
+static inline bool bond_mode_uses_primary(int mode)
+{
+	return mode == BOND_MODE_ACTIVEBACKUP || mode == BOND_MODE_TLB ||
+	       mode == BOND_MODE_ALB;
+}
+
+static inline bool bond_uses_primary(struct bonding *bond)
+{
+	return bond_mode_uses_primary(BOND_MODE(bond));
+}
+
+static inline bool bond_slave_is_up(struct slave *slave)
+{
+	return netif_running(slave->dev) && netif_carrier_ok(slave->dev);
+}
+
+static inline void bond_set_active_slave(struct slave *slave)
+{
+	if (slave->backup) {
+		slave->backup = 0;
+		rtmsg_ifinfo(RTM_NEWLINK, slave->dev, 0, GFP_ATOMIC);
+	}
+}
+
+static inline void bond_set_backup_slave(struct slave *slave)
+{
+	if (!slave->backup) {
+		slave->backup = 1;
+		rtmsg_ifinfo(RTM_NEWLINK, slave->dev, 0, GFP_ATOMIC);
+	}
+}
+
+static inline void bond_set_slave_state(struct slave *slave,
+					int slave_state, bool notify)
+{
+	if (slave->backup == slave_state)
+		return;
+
+	slave->backup = slave_state;
+	if (notify) {
+		rtmsg_ifinfo(RTM_NEWLINK, slave->dev, 0, GFP_ATOMIC);
+		slave->should_notify = 0;
+	} else {
+		if (slave->should_notify)
+			slave->should_notify = 0;
+		else
+			slave->should_notify = 1;
+	}
+}
+
+static inline void bond_slave_state_change(struct bonding *bond)
+{
+	struct list_head *iter;
+	struct slave *tmp;
+
+	bond_for_each_slave(bond, tmp, iter) {
+		if (tmp->link == BOND_LINK_UP)
+			bond_set_active_slave(tmp);
+		else if (tmp->link == BOND_LINK_DOWN)
+			bond_set_backup_slave(tmp);
+	}
+}
+
+static inline void bond_slave_state_notify(struct bonding *bond)
+{
+	struct list_head *iter;
+	struct slave *tmp;
+
+	bond_for_each_slave(bond, tmp, iter) {
+		if (tmp->should_notify) {
+			rtmsg_ifinfo(RTM_NEWLINK, tmp->dev, 0, GFP_ATOMIC);
+			tmp->should_notify = 0;
+		}
+	}
+}
+
+static inline int bond_slave_state(struct slave *slave)
+{
+	return slave->backup;
+}
+
+static inline bool bond_is_active_slave(struct slave *slave)
+{
+	return !bond_slave_state(slave);
+}
+
+static inline bool bond_slave_can_tx(struct slave *slave)
+{
+	return bond_slave_is_up(slave) && slave->link == BOND_LINK_UP &&
+	       bond_is_active_slave(slave);
+}
+
+#define BOND_PRI_RESELECT_ALWAYS	0
+#define BOND_PRI_RESELECT_BETTER	1
+#define BOND_PRI_RESELECT_FAILURE	2
+
+#define BOND_FOM_NONE			0
+#define BOND_FOM_ACTIVE			1
+#define BOND_FOM_FOLLOW			2
+
+#define BOND_ARP_TARGETS_ANY		0
+#define BOND_ARP_TARGETS_ALL		1
+
+#define BOND_ARP_VALIDATE_NONE		0
+#define BOND_ARP_VALIDATE_ACTIVE	(1 << BOND_STATE_ACTIVE)
+#define BOND_ARP_VALIDATE_BACKUP	(1 << BOND_STATE_BACKUP)
+#define BOND_ARP_VALIDATE_ALL		(BOND_ARP_VALIDATE_ACTIVE | \
+					 BOND_ARP_VALIDATE_BACKUP)
+#define BOND_ARP_FILTER			(BOND_ARP_VALIDATE_ALL + 1)
+#define BOND_ARP_FILTER_ACTIVE		(BOND_ARP_VALIDATE_ACTIVE | \
+					 BOND_ARP_FILTER)
+#define BOND_ARP_FILTER_BACKUP		(BOND_ARP_VALIDATE_BACKUP | \
+					 BOND_ARP_FILTER)
+
+#define BOND_SLAVE_NOTIFY_NOW		true
+#define BOND_SLAVE_NOTIFY_LATER		false
+
+static inline int slave_do_arp_validate(struct bonding *bond,
+					struct slave *slave)
+{
+	return bond->params.arp_validate & (1 << bond_slave_state(slave));
+}
+
+static inline int slave_do_arp_validate_only(struct bonding *bond)
+{
+	return bond->params.arp_validate & BOND_ARP_FILTER;
+}
+
+static inline int bond_is_ip_target_ok(__be32 addr)
+{
+	return !ipv4_is_lbcast(addr) && !ipv4_is_zeronet(addr);
+}
+
+/* Get the oldest arp which we've received on this slave for bond's
+ * arp_targets.
+ */
+static inline unsigned long slave_oldest_target_arp_rx(struct bonding *bond,
+						       struct slave *slave)
+{
+	int i = 1;
+	unsigned long ret = slave->target_last_arp_rx[0];
+
+	for (; (i < BOND_MAX_ARP_TARGETS) && bond->params.arp_targets[i]; i++)
+		if (time_before(slave->target_last_arp_rx[i], ret))
+			ret = slave->target_last_arp_rx[i];
+
+	return ret;
+}
+
+static inline unsigned long slave_last_rx(struct bonding *bond,
+					struct slave *slave)
+{
+	if (bond->params.arp_all_targets == BOND_ARP_TARGETS_ALL)
+		return slave_oldest_target_arp_rx(bond, slave);
+
+	return slave->last_rx;
+}
+
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static inline void bond_netpoll_send_skb(const struct slave *slave,
+					 struct sk_buff *skb)
+{
+	struct netpoll *np = slave->np;
+
+	if (np)
+		netpoll_send_skb(np, skb);
+}
+#else
+static inline void bond_netpoll_send_skb(const struct slave *slave,
+					 struct sk_buff *skb)
+{
+}
+#endif
+
+static inline void bond_set_slave_inactive_flags(struct slave *slave,
+						 bool notify)
+{
+	if (!bond_is_lb(slave->bond))
+		bond_set_slave_state(slave, BOND_STATE_BACKUP, notify);
+	if (!slave->bond->params.all_slaves_active)
+		slave->inactive = 1;
+}
+
+static inline void bond_set_slave_active_flags(struct slave *slave,
+					       bool notify)
+{
+	bond_set_slave_state(slave, BOND_STATE_ACTIVE, notify);
+	slave->inactive = 0;
+}
+
+static inline bool bond_is_slave_inactive(struct slave *slave)
+{
+	return slave->inactive;
+}
+
+static inline __be32 bond_confirm_addr(struct net_device *dev, __be32 dst, __be32 local)
+{
+	struct in_device *in_dev;
+	__be32 addr = 0;
+
+	rcu_read_lock();
+	in_dev = __in_dev_get_rcu(dev);
+
+	if (in_dev)
+		addr = inet_confirm_addr(dev_net(dev), in_dev, dst, local,
+					 RT_SCOPE_HOST);
+	rcu_read_unlock();
+	return addr;
+}
+
+struct bond_net {
+	struct net		*net;	/* Associated network namespace */
+	struct list_head	dev_list;
+#ifdef CONFIG_PROC_FS
+	struct proc_dir_entry	*proc_dir;
+#endif
+	struct class_attribute	class_attr_bonding_masters;
+};
+
+int bond_arp_rcv(const struct sk_buff *skb, struct bonding *bond, struct slave *slave);
+void bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb, struct net_device *slave_dev);
+int bond_create(struct net *net, const char *name);
+int bond_create_sysfs(struct bond_net *net);
+void bond_destroy_sysfs(struct bond_net *net);
+void bond_prepare_sysfs_group(struct bonding *bond);
+int bond_sysfs_slave_add(struct slave *slave);
+void bond_sysfs_slave_del(struct slave *slave);
+int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev);
+int bond_release(struct net_device *bond_dev, struct net_device *slave_dev);
+u32 bond_xmit_hash(struct bonding *bond, struct sk_buff *skb);
+void bond_select_active_slave(struct bonding *bond);
+void bond_change_active_slave(struct bonding *bond, struct slave *new_active);
+void bond_create_debugfs(void);
+void bond_destroy_debugfs(void);
+void bond_debug_register(struct bonding *bond);
+void bond_debug_unregister(struct bonding *bond);
+void bond_debug_reregister(struct bonding *bond);
+const char *bond_mode_name(int mode);
+void bond_setup(struct net_device *bond_dev);
+unsigned int bond_get_num_tx_queues(void);
+int bond_netlink_init(void);
+void bond_netlink_fini(void);
+struct net_device *bond_option_active_slave_get_rcu(struct bonding *bond);
+const char *bond_slave_link_status(s8 link);
+struct bond_vlan_tag *bond_verify_device_path(struct net_device *start_dev,
+					      struct net_device *end_dev,
+					      int level);
+int bond_update_slave_arr(struct bonding *bond, struct slave *skipslave);
+void bond_slave_arr_work_rearm(struct bonding *bond, unsigned long delay);
+
+#ifdef CONFIG_PROC_FS
+void bond_create_proc_entry(struct bonding *bond);
+void bond_remove_proc_entry(struct bonding *bond);
+void bond_create_proc_dir(struct bond_net *bn);
+void bond_destroy_proc_dir(struct bond_net *bn);
+#else
+static inline void bond_create_proc_entry(struct bonding *bond)
+{
+}
+
+static inline void bond_remove_proc_entry(struct bonding *bond)
+{
+}
+
+static inline void bond_create_proc_dir(struct bond_net *bn)
+{
+}
+
+static inline void bond_destroy_proc_dir(struct bond_net *bn)
+{
+}
+#endif
+
+static inline struct slave *bond_slave_has_mac(struct bonding *bond,
+					       const u8 *mac)
+{
+	struct list_head *iter;
+	struct slave *tmp;
+
+	bond_for_each_slave(bond, tmp, iter)
+		if (ether_addr_equal_64bits(mac, tmp->dev->dev_addr))
+			return tmp;
+
+	return NULL;
+}
+
+/* Caller must hold rcu_read_lock() for read */
+static inline struct slave *bond_slave_has_mac_rcu(struct bonding *bond,
+					       const u8 *mac)
+{
+	struct list_head *iter;
+	struct slave *tmp;
+
+	bond_for_each_slave_rcu(bond, tmp, iter)
+		if (ether_addr_equal_64bits(mac, tmp->dev->dev_addr))
+			return tmp;
+
+	return NULL;
+}
+
+/* Caller must hold rcu_read_lock() for read */
+static inline bool bond_slave_has_mac_rx(struct bonding *bond, const u8 *mac)
+{
+	struct list_head *iter;
+	struct slave *tmp;
+	struct netdev_hw_addr *ha;
+
+	bond_for_each_slave_rcu(bond, tmp, iter)
+		if (ether_addr_equal_64bits(mac, tmp->dev->dev_addr))
+			return true;
+
+	if (netdev_uc_empty(bond->dev))
+		return false;
+
+	netdev_for_each_uc_addr(ha, bond->dev)
+		if (ether_addr_equal_64bits(mac, ha->addr))
+			return true;
+
+	return false;
+}
+
+/* Check if the ip is present in arp ip list, or first free slot if ip == 0
+ * Returns -1 if not found, index if found
+ */
+static inline int bond_get_targets_ip(__be32 *targets, __be32 ip)
+{
+	int i;
+
+	for (i = 0; i < BOND_MAX_ARP_TARGETS; i++)
+		if (targets[i] == ip)
+			return i;
+		else if (targets[i] == 0)
+			break;
+
+	return -1;
+}
+
+/* exported from bond_main.c */
+extern int bond_net_id;
+extern const struct bond_parm_tbl bond_lacp_tbl[];
+extern const struct bond_parm_tbl xmit_hashtype_tbl[];
+extern const struct bond_parm_tbl arp_validate_tbl[];
+extern const struct bond_parm_tbl arp_all_targets_tbl[];
+extern const struct bond_parm_tbl fail_over_mac_tbl[];
+extern const struct bond_parm_tbl pri_reselect_tbl[];
+extern struct bond_parm_tbl ad_select_tbl[];
+
+/* exported from bond_netlink.c */
+extern struct rtnl_link_ops bond_link_ops;
+
+static inline void bond_tx_drop(struct net_device *dev, struct sk_buff *skb)
+{
+	atomic_long_inc(&dev->tx_dropped);
+	dev_kfree_skb_any(skb);
+}
+
+#endif /* _NET_BONDING_H */
-- 
1.9.3
