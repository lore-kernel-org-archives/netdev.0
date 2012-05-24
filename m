From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Subject: [PATCH 13/21] global: Remove OVS_KEY_ATTR_TUN_ID
Date: Thu, 24 May 2012 18:09:06 +0900
Message-ID: <1337850554-10339-14-git-send-email-horms@verge.net.au>
References: <1337850554-10339-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1337850554-10339-1-git-send-email-horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

OVS_KEY_ATTR_TUN_ID may now be removed as it is
no longer used in any meaningful way.

Cc: Kyle Mestery <kmestery-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
---
 datapath/datapath.c         |  1 -
 datapath/flow.c             |  1 -
 include/linux/openvswitch.h |  1 -
 lib/dpif-netdev.c           |  1 -
 lib/odp-util.c              | 18 ------------------
 5 files changed, 22 deletions(-)

diff --git a/datapath/datapath.c b/datapath/datapath.c
index 65dfe79..dcff4c6 100644
--- a/datapath/datapath.c
+++ b/datapath/datapath.c
@@ -590,7 +590,6 @@ static int validate_set(const struct nlattr *a,
 	const struct ovs_key_ipv4_tunnel *tun_key;
 
 	case OVS_KEY_ATTR_PRIORITY:
-	case OVS_KEY_ATTR_TUN_ID:
 	case OVS_KEY_ATTR_ETHERNET:
 		break;
 
diff --git a/datapath/flow.c b/datapath/flow.c
index 49c0dd8..9c898c6 100644
--- a/datapath/flow.c
+++ b/datapath/flow.c
@@ -847,7 +847,6 @@ const int ovs_key_lens[OVS_KEY_ATTR_MAX + 1] = {
 	[OVS_KEY_ATTR_ND] = sizeof(struct ovs_key_nd),
 
 	/* Not upstream. */
-	[OVS_KEY_ATTR_TUN_ID] = sizeof(__be64),
 	[OVS_KEY_ATTR_IPV4_TUNNEL] = sizeof(struct ovs_key_ipv4_tunnel),
 };
 
diff --git a/include/linux/openvswitch.h b/include/linux/openvswitch.h
index f2d56ec..9de3f20 100644
--- a/include/linux/openvswitch.h
+++ b/include/linux/openvswitch.h
@@ -279,7 +279,6 @@ enum ovs_key_attr {
 	OVS_KEY_ATTR_ICMPV6,    /* struct ovs_key_icmpv6 */
 	OVS_KEY_ATTR_ARP,       /* struct ovs_key_arp */
 	OVS_KEY_ATTR_ND,        /* struct ovs_key_nd */
-	OVS_KEY_ATTR_TUN_ID,    /* be64 tunnel ID */
 	OVS_KEY_ATTR_IPV4_TUNNEL,  /* struct ovs_key_ipv4_tunnel */
 	__OVS_KEY_ATTR_MAX
 };
diff --git a/lib/dpif-netdev.c b/lib/dpif-netdev.c
index d065a3a..ff00e05 100644
--- a/lib/dpif-netdev.c
+++ b/lib/dpif-netdev.c
@@ -1162,7 +1162,6 @@ execute_set_action(struct ofpbuf *packet, const struct nlattr *a)
     const struct ovs_key_udp *udp_key;
 
     switch (type) {
-    case OVS_KEY_ATTR_TUN_ID:
     case OVS_KEY_ATTR_PRIORITY:
     case OVS_KEY_ATTR_IPV6:
     case OVS_KEY_ATTR_IPV4_TUNNEL:
diff --git a/lib/odp-util.c b/lib/odp-util.c
index 11b7a1b..d1fe9d8 100644
--- a/lib/odp-util.c
+++ b/lib/odp-util.c
@@ -105,7 +105,6 @@ ovs_key_attr_to_string(enum ovs_key_attr attr)
     case OVS_KEY_ATTR_ICMPV6: return "icmpv6";
     case OVS_KEY_ATTR_ARP: return "arp";
     case OVS_KEY_ATTR_ND: return "nd";
-    case OVS_KEY_ATTR_TUN_ID: return "tun_id";
     case OVS_KEY_ATTR_IPV4_TUNNEL: return "ipv4_tunnel";
 
     case __OVS_KEY_ATTR_MAX:
@@ -602,7 +601,6 @@ odp_flow_key_attr_len(uint16_t type)
     switch ((enum ovs_key_attr) type) {
     case OVS_KEY_ATTR_ENCAP: return -2;
     case OVS_KEY_ATTR_PRIORITY: return 4;
-    case OVS_KEY_ATTR_TUN_ID: return 8;
     case OVS_KEY_ATTR_IN_PORT: return 4;
     case OVS_KEY_ATTR_ETHERNET: return sizeof(struct ovs_key_ethernet);
     case OVS_KEY_ATTR_VLAN: return sizeof(ovs_be16);
@@ -697,10 +695,6 @@ format_odp_key_attr(const struct nlattr *a, struct ds *ds)
         ds_put_format(ds, "(%"PRIu32")", nl_attr_get_u32(a));
         break;
 
-    case OVS_KEY_ATTR_TUN_ID:
-        ds_put_format(ds, "(%#"PRIx64")", ntohll(nl_attr_get_be64(a)));
-        break;
-
     case OVS_KEY_ATTR_IPV4_TUNNEL:
         ipv4_tun_key = nl_attr_get(a);
         ds_put_format(ds, "(tun_id=%"PRIx64",flags=%"PRIx32
@@ -913,18 +907,6 @@ parse_odp_key_attr(const char *s, const struct simap *port_names,
     }
 
     {
-        char tun_id_s[32];
-        int n = -1;
-
-        if (sscanf(s, "tun_id(%31[x0123456789abcdefABCDEF])%n",
-                   tun_id_s, &n) > 0 && n > 0) {
-            uint64_t tun_id = strtoull(tun_id_s, NULL, 0);
-            nl_msg_put_be64(key, OVS_KEY_ATTR_TUN_ID, htonll(tun_id));
-            return n;
-        }
-    }
-
-    {
         ovs_be32 ipv4_src;
         ovs_be32 ipv4_dst;
         unsigned long long tun_flags;
-- 
1.7.10.2.484.gcd07cc5
