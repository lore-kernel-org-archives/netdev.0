From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: [PATCH 2/2] batman-adv: Use "__attribute__" shortcut
	macros
Date: Sun, 16 Jan 2011 03:38:47 +0100
Message-ID: <1295145527-17537-3-git-send-email-sven@narfation.org>
References: <1295145527-17537-1-git-send-email-sven@narfation.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1295145527-17537-1-git-send-email-sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
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

Linux 2.6.21 defines different macros for __attribute__ which are also
used inside batman-adv. The next version of checkpatch.pl warns about
the usage of __attribute__((packed))).

Linux 2.6.33 defines an extra macro __always_unused which is used to
assist source code analyzers and can be used to removed the last
existing __attribute__ inside the source code.

Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
---
 net/batman-adv/main.h   |    6 +++---
 net/batman-adv/packet.h |   14 +++++++-------
 net/batman-adv/types.h  |    4 ++--
 3 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index d4d9926..65106fb 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -151,9 +151,9 @@ int debug_log(struct bat_priv *bat_priv, char *fmt, ...);
 	}							\
 	while (0)
 #else /* !CONFIG_BATMAN_ADV_DEBUG */
-static inline void bat_dbg(char type __attribute__((unused)),
-			   struct bat_priv *bat_priv __attribute__((unused)),
-			   char *fmt __attribute__((unused)), ...)
+static inline void bat_dbg(char type __always_unused,
+			   struct bat_priv *bat_priv __always_unused,
+			   char *fmt __always_unused, ...)
 {
 }
 #endif
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index b49fdf7..2284e81 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -63,7 +63,7 @@ struct batman_packet {
 	uint8_t  num_hna;
 	uint8_t  gw_flags;  /* flags related to gateway class */
 	uint8_t  align;
-} __attribute__((packed));
+} __packed;
 
 #define BAT_PACKET_LEN sizeof(struct batman_packet)
 
@@ -76,7 +76,7 @@ struct icmp_packet {
 	uint8_t  orig[6];
 	uint16_t seqno;
 	uint8_t  uid;
-} __attribute__((packed));
+} __packed;
 
 #define BAT_RR_LEN 16
 
@@ -93,14 +93,14 @@ struct icmp_packet_rr {
 	uint8_t  uid;
 	uint8_t  rr_cur;
 	uint8_t  rr[BAT_RR_LEN][ETH_ALEN];
-} __attribute__((packed));
+} __packed;
 
 struct unicast_packet {
 	uint8_t  packet_type;
 	uint8_t  version;  /* batman version field */
 	uint8_t  dest[6];
 	uint8_t  ttl;
-} __attribute__((packed));
+} __packed;
 
 struct unicast_frag_packet {
 	uint8_t  packet_type;
@@ -110,7 +110,7 @@ struct unicast_frag_packet {
 	uint8_t  flags;
 	uint8_t  orig[6];
 	uint16_t seqno;
-} __attribute__((packed));
+} __packed;
 
 struct bcast_packet {
 	uint8_t  packet_type;
@@ -118,7 +118,7 @@ struct bcast_packet {
 	uint8_t  orig[6];
 	uint8_t  ttl;
 	uint32_t seqno;
-} __attribute__((packed));
+} __packed;
 
 struct vis_packet {
 	uint8_t  packet_type;
@@ -131,6 +131,6 @@ struct vis_packet {
 				  * neighbors */
 	uint8_t  target_orig[6]; /* who should receive this packet */
 	uint8_t  sender_orig[6]; /* who sent or rebroadcasted this packet */
-} __attribute__((packed));
+} __packed;
 
 #endif /* _NET_BATMAN_ADV_PACKET_H_ */
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 97cb23d..bf3f6f5 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -246,13 +246,13 @@ struct vis_info {
 	/* this packet might be part of the vis send queue. */
 	struct sk_buff *skb_packet;
 	/* vis_info may follow here*/
-} __attribute__((packed));
+} __packed;
 
 struct vis_info_entry {
 	uint8_t  src[ETH_ALEN];
 	uint8_t  dest[ETH_ALEN];
 	uint8_t  quality;	/* quality = 0 means HNA */
-} __attribute__((packed));
+} __packed;
 
 struct recvlist_node {
 	struct list_head list;
-- 
1.7.2.3
