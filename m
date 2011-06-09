From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: [PATCH 5/6] batman-adv: Use enums for related
	constants
Date: Thu,  9 Jun 2011 23:09:13 +0200
Message-ID: <1307653754-5014-6-git-send-email-sven@narfation.org>
References: <1307653754-5014-1-git-send-email-sven@narfation.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1307653754-5014-1-git-send-email-sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
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

CodingStyle "Chapter 12: Macros, Enums and RTL" recommends to use enums
for several related constants. Internal states can be used without
defining the actual value, but all values which are visible to the
outside must be defined as before. Normal values are assigned as usual
and flags are defined by shifts of a bit.

Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
---
 net/batman-adv/hard-interface.h |   14 ++++++-----
 net/batman-adv/main.h           |   17 ++++++++-----
 net/batman-adv/packet.h         |   47 ++++++++++++++++++++++++---------------
 3 files changed, 47 insertions(+), 31 deletions(-)

diff --git a/net/batman-adv/hard-interface.h b/net/batman-adv/hard-interface.h
index 79e25cb..442eacb 100644
--- a/net/batman-adv/hard-interface.h
+++ b/net/batman-adv/hard-interface.h
@@ -22,12 +22,14 @@
 #ifndef _NET_BATMAN_ADV_HARD_INTERFACE_H_
 #define _NET_BATMAN_ADV_HARD_INTERFACE_H_
 
-#define IF_NOT_IN_USE 0
-#define IF_TO_BE_REMOVED 1
-#define IF_INACTIVE 2
-#define IF_ACTIVE 3
-#define IF_TO_BE_ACTIVATED 4
-#define IF_I_WANT_YOU 5
+enum hard_if_state {
+	IF_NOT_IN_USE,
+	IF_TO_BE_REMOVED,
+	IF_INACTIVE,
+	IF_ACTIVE,
+	IF_TO_BE_ACTIVATED,
+	IF_I_WANT_YOU
+};
 
 extern struct notifier_block hard_if_notifier;
 
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 610eaf0..27ad734 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -72,9 +72,11 @@
 #define RESET_PROTECTION_MS 30000
 #define EXPECTED_SEQNO_RANGE	65536
 
-#define MESH_INACTIVE 0
-#define MESH_ACTIVE 1
-#define MESH_DEACTIVATING 2
+enum mesh_state {
+	MESH_INACTIVE,
+	MESH_ACTIVE,
+	MESH_DEACTIVATING
+};
 
 #define BCAST_QUEUE_LEN		256
 #define BATMAN_QUEUE_LEN	256
@@ -89,10 +91,11 @@
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
 /* all messages related to routing / flooding / broadcasting / etc */
-#define DBG_BATMAN 1
-/* route or tt entry added / changed / deleted */
-#define DBG_ROUTES 2
-#define DBG_ALL 3
+enum dbg_level {
+	DBG_BATMAN = 1 << 0,
+	DBG_ROUTES = 1 << 1, /* route added / changed / deleted */
+	DBG_ALL    = 3
+};
 
 
 /*
diff --git a/net/batman-adv/packet.h b/net/batman-adv/packet.h
index eda9965..9f77086 100644
--- a/net/batman-adv/packet.h
+++ b/net/batman-adv/packet.h
@@ -24,33 +24,44 @@
 
 #define ETH_P_BATMAN  0x4305	/* unofficial/not registered Ethertype */
 
-#define BAT_PACKET       0x01
-#define BAT_ICMP         0x02
-#define BAT_UNICAST      0x03
-#define BAT_BCAST        0x04
-#define BAT_VIS          0x05
-#define BAT_UNICAST_FRAG 0x06
+enum bat_packettype {
+	BAT_PACKET       = 0x01,
+	BAT_ICMP         = 0x02,
+	BAT_UNICAST      = 0x03,
+	BAT_BCAST        = 0x04,
+	BAT_VIS          = 0x05,
+	BAT_UNICAST_FRAG = 0x06
+};
 
 /* this file is included by batctl which needs these defines */
 #define COMPAT_VERSION 12
-#define DIRECTLINK 0x40
-#define VIS_SERVER 0x20
-#define PRIMARIES_FIRST_HOP 0x10
+
+enum batman_flags {
+	PRIMARIES_FIRST_HOP = 1 << 4,
+	VIS_SERVER	    = 1 << 5,
+	DIRECTLINK	    = 1 << 6
+};
 
 /* ICMP message types */
-#define ECHO_REPLY 0
-#define DESTINATION_UNREACHABLE 3
-#define ECHO_REQUEST 8
-#define TTL_EXCEEDED 11
-#define PARAMETER_PROBLEM 12
+enum icmp_packettype {
+	ECHO_REPLY		= 0,
+	DESTINATION_UNREACHABLE = 3,
+	ECHO_REQUEST		= 8,
+	TTL_EXCEEDED		= 11,
+	PARAMETER_PROBLEM	= 12
+};
 
 /* vis defines */
-#define VIS_TYPE_SERVER_SYNC		0
-#define VIS_TYPE_CLIENT_UPDATE		1
+enum vis_packettype {
+	VIS_TYPE_SERVER_SYNC   = 0,
+	VIS_TYPE_CLIENT_UPDATE = 1
+};
 
 /* fragmentation defines */
-#define UNI_FRAG_HEAD 0x01
-#define UNI_FRAG_LARGETAIL 0x02
+enum unicast_frag_flags {
+	UNI_FRAG_HEAD	   = 1 << 0,
+	UNI_FRAG_LARGETAIL = 1 << 1
+};
 
 struct batman_packet {
 	uint8_t  packet_type;
-- 
1.7.5.3
