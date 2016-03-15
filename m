From: Jan Moskyto Matejka <mq-+ZI9xUNit7I@public.gmane.org>
Subject: [PATCH] rtnetlink.7: add missing RTA_* attributes
Date: Tue, 15 Mar 2016 13:06:27 +0100
Message-ID: <1458043587-5115-1-git-send-email-mq@ucw.cz>
Cc: Jan Moskyto Matejka <mq-+ZI9xUNit7I@public.gmane.org>,
	"Eric W . Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>,
	Lubomir Rintel <lkundrak-NGH9Lh4a5iE@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Used Bird's source code, kernel source code, iproute2 source code and
iproute2 manpages to find meanings of these new attributes.

Signed-off-by: Jan Moskyto Matejka <mq-+ZI9xUNit7I@public.gmane.org>
---
 man7/rtnetlink.7 | 61 ++++++++++++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 55 insertions(+), 6 deletions(-)

diff --git a/man7/rtnetlink.7 b/man7/rtnetlink.7
index f6eb8c7..e0b351f 100644
--- a/man7/rtnetlink.7
+++ b/man7/rtnetlink.7
@@ -200,7 +200,7 @@ struct rtmsg {
     unsigned char rtm_src_len;  /* Length of source */
     unsigned char rtm_tos;      /* TOS filter */
 
-    unsigned char rtm_table;    /* Routing table ID */
+    unsigned char rtm_table;    /* Routing table ID; see RTA_TABLE below */
     unsigned char rtm_protocol; /* Routing protocol; see below */
     unsigned char rtm_scope;    /* See below */
     unsigned char rtm_type;     /* See below */
@@ -319,14 +319,63 @@ RTA_IIF:int:Input interface index.
 RTA_OIF:int:Output interface index.
 RTA_GATEWAY:protocol address:The gateway of the route
 RTA_PRIORITY:int:Priority of route.
-RTA_PREFSRC::
+RTA_PREFSRC:protocol address:Preferred source address.
 RTA_METRICS:int:Route metric
-RTA_MULTIPATH::
-RTA_PROTOINFO::
-RTA_FLOW::
-RTA_CACHEINFO::
+RTA_MULTIPATH::Multipath nexthop data (see below).
+RTA_PROTOINFO::No longer used
+RTA_FLOW:int:Route realm
+RTA_CACHEINFO:struct rta_cacheinfo:(see linux/rtnetlink.h)
+RTA_SESSION::No longer used
+RTA_MP_ALGO::No longer used
+RTA_TABLE:int:Routing table ID; if set, rtm_table is ignored.
+RTA_MARK:int:
+RTA_MFC_STATS:struct rta_mfc_stats:(see linux/rtnetlink.h)
+RTA_VIA:struct rtvia:Gateway in different AF (see below).
+RTA_NEWDST:protocol address:Change packet destination address.
+RTA_PREF:char:RFC4191 IPv6 router preference (see below).
+RTA_ENCAP_TYPE:short:Encapsulation type for lwtunnels (see below).
+RTA_ENCAP::Defined by RTA_ENCAP_TYPE.
+RTA_EXPIRES:int:Expire time for IPv6 routes (in seconds).
 .TE
 
+.I RTA_MULTIPATH
+contains several packed instances of
+.I struct rtnexthop
+together with nested RTA's (RTA_GATEWAY)
+
+.nf
+struct rtnexthop {
+    unsigned short  rtnh_len;       /* Length of struct + length of RTA's
+    unsigned char   rtnh_flags;     /* Flags (see linux/rtnetlink.h) */
+    unsigned char   rtnh_hops;      /* Nexthop priority */
+    int             rtnh_ifindex;   /* Interface index for this nexthop */
+}
+
+There exist a bunch of RTNH_* macros similar to RTA_* and NLHDR_* macros
+useful to handle these structures.
+
+.nf
+struct rtvia {
+    unsigned short rtvia_family;
+    unsigned char  rtvia_addr[0];
+};
+.fi
+
+.I rtvia_addr
+is the address,
+.I rtvia_family
+is its family type.
+
+.I RTA_PREF
+may contain values ICMPV6_ROUTER_PREF_LOW,
+ICMPV6_ROUTER_PREF_MEDIUM and
+ICMPV6_ROUTER_PREF_HIGH defined in <linux/icmpv6.h>
+
+.I RTA_ENCAP_TYPE
+may contain values LWTUNNEL_ENCAP_MPLS, LWTUNNEL_ENCAP_IP, LWTUNNEL_ENCAP_ILA or LWTUNNEL_ENCAP_IP6
+defined in <linux/lwtunnel.h>
+
+
 .B Fill these values in!
 .TP
 .BR RTM_NEWNEIGH ", " RTM_DELNEIGH  ", " RTM_GETNEIGH
-- 
2.7.0

--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
