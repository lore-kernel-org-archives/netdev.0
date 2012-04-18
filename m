From: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Subject: batman: trivial endianness annotations
Date: Wed, 18 Apr 2012 19:14:55 +0100
Message-ID: <20120418181455.GF6589@ZenIV.linux.org.uk>
References: <1334743210-12338-1-git-send-email-ordex@autistici.org>
	<20120418180837.GB6589@ZenIV.linux.org.uk>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120418180837.GB6589-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

Missing endianness annotations - on-the-wire data and ip addresses.
BTW, casting memcpy() arguments to (uint8_t *) is cargo-cult programming -
they are void *, which is precisely "take any pointer to object"...

Signed-off-by: Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
---
 net/batman-adv/bridge_loop_avoidance.c |    8 ++++----
 net/batman-adv/distributed-arp-table.c |   16 ++++++++--------
 net/batman-adv/distributed-arp-table.h |    4 ++--
 net/batman-adv/packet.h                |   12 ++++++------
 4 files changed, 20 insertions(+), 20 deletions(-)

diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index 8bf9751..d51288b 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -258,7 +258,7 @@ static void bla_send_claim(struct bat_priv *bat_priv, uint8_t *mac,
 	struct net_device *soft_iface;
 	uint8_t *hw_src;
 	struct bla_claim_dst local_claim_dest;
-	uint32_t zeroip = 0;
+	__be32 zeroip = 0;
 
 	primary_if = primary_if_get_selected(bat_priv);
 	if (!primary_if)
@@ -506,11 +506,11 @@ static void bla_send_announce(struct bat_priv *bat_priv,
 			      struct backbone_gw *backbone_gw)
 {
 	uint8_t mac[ETH_ALEN];
-	uint16_t crc;
+	__be16 crc;
 
 	memcpy(mac, announce_mac, 4);
 	crc = htons(backbone_gw->crc);
-	memcpy(&mac[4], (uint8_t *)&crc, 2);
+	memcpy(&mac[4], &crc, 2);
 
 	bla_send_claim(bat_priv, mac, backbone_gw->vid, CLAIM_TYPE_ANNOUNCE);
 
@@ -627,7 +627,7 @@ static int handle_announce(struct bat_priv *bat_priv,
 
 	/* handle as ANNOUNCE frame */
 	backbone_gw->lasttime = jiffies;
-	crc = ntohs(*((uint16_t *)(&an_addr[4])));
+	crc = ntohs(*((__be16 *)(&an_addr[4])));
 
 	bat_dbg(DBG_BLA, bat_priv,
 		"handle_announce(): ANNOUNCE vid %d (sent by %pM)... CRC = %04x\n",
diff --git a/net/batman-adv/distributed-arp-table.c b/net/batman-adv/distributed-arp-table.c
index b43bece..d87f914 100644
--- a/net/batman-adv/distributed-arp-table.c
+++ b/net/batman-adv/distributed-arp-table.c
@@ -192,7 +192,7 @@ static void choose_next_candidate(struct bat_priv *bat_priv,
  *
  * return an array of size DHT_CANDIDATES_NUM */
 static struct dht_candidate *dht_select_candidates(struct bat_priv *bat_priv,
-						   uint32_t ip_dst)
+						   __be32 ip_dst)
 {
 	int select;
 	dat_addr_t last_max = DAT_ADDR_MAX, ip_key;
@@ -224,7 +224,7 @@ static struct dht_candidate *dht_select_candidates(struct bat_priv *bat_priv,
  * If the packet is successfully sent to at least one candidate, then this
  * function returns true */
 static bool dht_send_data(struct bat_priv *bat_priv, struct sk_buff *skb,
-			  uint32_t ip, int packet_subtype)
+			  __be32 ip, int packet_subtype)
 {
 	int i;
 	bool ret = false;
@@ -270,7 +270,7 @@ out:
 /* Update the neighbour entry corresponding to the IP passed as parameter with
  * the hw address hw. If the neighbour entry doesn't exists, then it will be
  * created */
-static void arp_neigh_update(struct bat_priv *bat_priv, uint32_t ip,
+static void arp_neigh_update(struct bat_priv *bat_priv, __be32 ip,
 			     uint8_t *hw)
 {
 	struct neighbour *n = NULL;
@@ -299,7 +299,7 @@ static uint16_t arp_get_type(struct bat_priv *bat_priv, struct sk_buff *skb,
 {
 	struct arphdr *arphdr;
 	struct ethhdr *ethhdr;
-	uint32_t ip_src, ip_dst;
+	__be32 ip_src, ip_dst;
 	uint16_t type = 0;
 
 	/* pull the ethernet header */
@@ -352,7 +352,7 @@ bool dat_snoop_outgoing_arp_request(struct bat_priv *bat_priv,
 				    struct sk_buff *skb)
 {
 	uint16_t type = 0;
-	uint32_t ip_dst, ip_src;
+	__be32 ip_dst, ip_src;
 	uint8_t *hw_src;
 	bool ret = false;
 	struct neighbour *n = NULL;
@@ -414,7 +414,7 @@ bool dat_snoop_incoming_arp_request(struct bat_priv *bat_priv,
 				    struct sk_buff *skb, int hdr_size)
 {
 	uint16_t type;
-	uint32_t ip_src, ip_dst;
+	__be32 ip_src, ip_dst;
 	uint8_t *hw_src;
 	struct hard_iface *primary_if = NULL;
 	struct sk_buff *skb_new;
@@ -470,7 +470,7 @@ bool dat_snoop_outgoing_arp_reply(struct bat_priv *bat_priv,
 				  struct sk_buff *skb)
 {
 	uint16_t type;
-	uint32_t ip_src, ip_dst;
+	__be32 ip_src, ip_dst;
 	uint8_t *hw_src, *hw_dst;
 	bool ret = false;
 
@@ -503,7 +503,7 @@ bool dat_snoop_incoming_arp_reply(struct bat_priv *bat_priv,
 				  struct sk_buff *skb, int hdr_size)
 {
 	uint16_t type;
-	uint32_t ip_src, ip_dst;
+	__be32 ip_src, ip_dst;
 	uint8_t *hw_src, *hw_dst;
 	bool ret = false;
 
diff --git a/net/batman-adv/distributed-arp-table.h b/net/batman-adv/distributed-arp-table.h
index fcf6c15..01d5b4f 100644
--- a/net/batman-adv/distributed-arp-table.h
+++ b/net/batman-adv/distributed-arp-table.h
@@ -33,10 +33,10 @@
 
 #define ARP_HW_SRC(skb, hdr_size) ((uint8_t *)(skb->data + hdr_size) + \
 				   ETH_HLEN + sizeof(struct arphdr))
-#define ARP_IP_SRC(skb, hdr_size) (*(uint32_t *)(ARP_HW_SRC(skb, hdr_size) + \
+#define ARP_IP_SRC(skb, hdr_size) (*(__be32 *)(ARP_HW_SRC(skb, hdr_size) + \
 				   ETH_ALEN))
 #define ARP_HW_DST(skb, hdr_size) (ARP_HW_SRC(skb, hdr_size) + ETH_ALEN + 4)
-#define ARP_IP_DST(skb, hdr_size) (*(uint32_t *)(ARP_HW_SRC(skb, hdr_size) + \
+#define ARP_IP_DST(skb, hdr_size) (*(__be32 *)(ARP_HW_SRC(skb, hdr_size) + \
 				   ETH_ALEN * 2 + 4))
 
 bool dat_snoop_outgoing_arp_request(struct bat_priv *bat_priv,
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index ad39938..eb4fdf6 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -113,7 +113,7 @@ enum bla_claimframe {
 struct bla_claim_dst {
 	uint8_t magic[3];	/* FF:43:05 */
 	uint8_t type;		/* bla_claimframe */
-	uint16_t group;		/* group id */
+	__be16 group;		/* group id */
 } __packed;
 
 struct batman_header {
@@ -142,7 +142,7 @@ struct icmp_packet {
 	uint8_t  msg_type; /* see ICMP message types above */
 	uint8_t  dst[ETH_ALEN];
 	uint8_t  orig[ETH_ALEN];
-	uint16_t seqno;
+	__be16   seqno;
 	uint8_t  uid;
 	uint8_t  reserved;
 } __packed;
@@ -156,7 +156,7 @@ struct icmp_packet_rr {
 	uint8_t  msg_type; /* see ICMP message types above */
 	uint8_t  dst[ETH_ALEN];
 	uint8_t  orig[ETH_ALEN];
-	uint16_t seqno;
+	__be16   seqno;
 	uint8_t  uid;
 	uint8_t  rr_cur;
 	uint8_t  rr[BAT_RR_LEN][ETH_ALEN];
@@ -181,20 +181,20 @@ struct unicast_frag_packet {
 	uint8_t  flags;
 	uint8_t  align;
 	uint8_t  orig[ETH_ALEN];
-	uint16_t seqno;
+	__be16   seqno;
 } __packed;
 
 struct bcast_packet {
 	struct batman_header header;
 	uint8_t  reserved;
-	uint32_t seqno;
+	__be32   seqno;
 	uint8_t  orig[ETH_ALEN];
 } __packed;
 
 struct vis_packet {
 	struct batman_header header;
 	uint8_t  vis_type;	 /* which type of vis-participant sent this? */
-	uint32_t seqno;		 /* sequence number */
+	__be32   seqno;		 /* sequence number */
 	uint8_t  entries;	 /* number of entries behind this struct */
 	uint8_t  reserved;
 	uint8_t  vis_orig[ETH_ALEN];	/* originator reporting its neighbors */
-- 
1.7.2.5
