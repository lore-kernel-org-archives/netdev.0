From: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Subject: [PATCH 03/16] batman-adv: use ETH_ALEN instead of
	hardcoded numeric constants
Date: Sat,  7 Apr 2012 20:49:45 +0200
Message-ID: <1333824598-27771-4-git-send-email-ordex@autistici.org>
References: <1333824598-27771-1-git-send-email-ordex@autistici.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1333824598-27771-1-git-send-email-ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
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

In packet.h the numeric constant 6 is used instead of the more portable ETH_ALEN
define. This patch substitute any hardcoded value with such define.

Signed-off-by: Antonio Quartulli <ordex-GaUfNO9RBHfsrOwW+9ziJQ@public.gmane.org>
Acked-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
---
 net/batman-adv/packet.h |   26 +++++++++++++-------------
 1 file changed, 13 insertions(+), 13 deletions(-)

diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index 441f3db..45e75ed 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -100,8 +100,8 @@ struct batman_ogm_packet {
 	struct batman_header header;
 	uint8_t  flags;    /* 0x40: DIRECTLINK flag, 0x20 VIS_SERVER flag... */
 	uint32_t seqno;
-	uint8_t  orig[6];
-	uint8_t  prev_sender[6];
+	uint8_t  orig[ETH_ALEN];
+	uint8_t  prev_sender[ETH_ALEN];
 	uint8_t  gw_flags;  /* flags related to gateway class */
 	uint8_t  tq;
 	uint8_t  tt_num_changes;
@@ -114,8 +114,8 @@ struct batman_ogm_packet {
 struct icmp_packet {
 	struct batman_header header;
 	uint8_t  msg_type; /* see ICMP message types above */
-	uint8_t  dst[6];
-	uint8_t  orig[6];
+	uint8_t  dst[ETH_ALEN];
+	uint8_t  orig[ETH_ALEN];
 	uint16_t seqno;
 	uint8_t  uid;
 	uint8_t  reserved;
@@ -128,8 +128,8 @@ struct icmp_packet {
 struct icmp_packet_rr {
 	struct batman_header header;
 	uint8_t  msg_type; /* see ICMP message types above */
-	uint8_t  dst[6];
-	uint8_t  orig[6];
+	uint8_t  dst[ETH_ALEN];
+	uint8_t  orig[ETH_ALEN];
 	uint16_t seqno;
 	uint8_t  uid;
 	uint8_t  rr_cur;
@@ -139,16 +139,16 @@ struct icmp_packet_rr {
 struct unicast_packet {
 	struct batman_header header;
 	uint8_t  ttvn; /* destination translation table version number */
-	uint8_t  dest[6];
+	uint8_t  dest[ETH_ALEN];
 } __packed;
 
 struct unicast_frag_packet {
 	struct batman_header header;
 	uint8_t  ttvn; /* destination translation table version number */
-	uint8_t  dest[6];
+	uint8_t  dest[ETH_ALEN];
 	uint8_t  flags;
 	uint8_t  align;
-	uint8_t  orig[6];
+	uint8_t  orig[ETH_ALEN];
 	uint16_t seqno;
 } __packed;
 
@@ -156,7 +156,7 @@ struct bcast_packet {
 	struct batman_header header;
 	uint8_t  reserved;
 	uint32_t seqno;
-	uint8_t  orig[6];
+	uint8_t  orig[ETH_ALEN];
 } __packed;
 
 struct vis_packet {
@@ -165,9 +165,9 @@ struct vis_packet {
 	uint32_t seqno;		 /* sequence number */
 	uint8_t  entries;	 /* number of entries behind this struct */
 	uint8_t  reserved;
-	uint8_t  vis_orig[6];	 /* originator that announces its neighbors */
-	uint8_t  target_orig[6]; /* who should receive this packet */
-	uint8_t  sender_orig[6]; /* who sent or rebroadcasted this packet */
+	uint8_t  vis_orig[ETH_ALEN];	/* originator reporting its neighbors */
+	uint8_t  target_orig[ETH_ALEN]; /* who should receive this packet */
+	uint8_t  sender_orig[ETH_ALEN]; /* who sent or forwarded this packet */
 } __packed;
 
 struct tt_query_packet {
-- 
1.7.9.4
