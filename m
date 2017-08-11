From: Joe Perches <joe@perches.com>
Subject: [PATCH] openvswitch: Remove unnecessary newlines from OVS_NLERR uses
Date: Fri, 11 Aug 2017 04:26:26 -0700
Message-ID: <72f936a314a54a7957afdeb19e3d019c8c1dabea.1502450609.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        dev@openvswitch.org, linux-kernel@vger.kernel.org
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

OVS_NLERR already adds a newline so these just add blank
lines to the logging.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/openvswitch/conntrack.c    | 14 +++++---------
 net/openvswitch/flow_netlink.c |  2 +-
 2 files changed, 6 insertions(+), 10 deletions(-)

diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index 03859e386b47..30d632509f82 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -1180,15 +1180,13 @@ static int parse_nat(const struct nlattr *attr,
 		int type = nla_type(a);
 
 		if (type > OVS_NAT_ATTR_MAX) {
-			OVS_NLERR(log,
-				  "Unknown NAT attribute (type=%d, max=%d).\n",
+			OVS_NLERR(log, "Unknown NAT attribute (type=%d, max=%d)",
 				  type, OVS_NAT_ATTR_MAX);
 			return -EINVAL;
 		}
 
 		if (nla_len(a) != ovs_nat_attr_lens[type][ip_vers]) {
-			OVS_NLERR(log,
-				  "NAT attribute type %d has unexpected length (%d != %d).\n",
+			OVS_NLERR(log, "NAT attribute type %d has unexpected length (%d != %d)",
 				  type, nla_len(a),
 				  ovs_nat_attr_lens[type][ip_vers]);
 			return -EINVAL;
@@ -1198,9 +1196,7 @@ static int parse_nat(const struct nlattr *attr,
 		case OVS_NAT_ATTR_SRC:
 		case OVS_NAT_ATTR_DST:
 			if (info->nat) {
-				OVS_NLERR(log,
-					  "Only one type of NAT may be specified.\n"
-					  );
+				OVS_NLERR(log, "Only one type of NAT may be specified");
 				return -ERANGE;
 			}
 			info->nat |= OVS_CT_NAT;
@@ -1245,13 +1241,13 @@ static int parse_nat(const struct nlattr *attr,
 			break;
 
 		default:
-			OVS_NLERR(log, "Unknown nat attribute (%d).\n", type);
+			OVS_NLERR(log, "Unknown nat attribute (%d)", type);
 			return -EINVAL;
 		}
 	}
 
 	if (rem > 0) {
-		OVS_NLERR(log, "NAT attribute has %d unknown bytes.\n", rem);
+		OVS_NLERR(log, "NAT attribute has %d unknown bytes", rem);
 		return -EINVAL;
 	}
 	if (!info->nat) {
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index f07d10ac35d8..e8eb427ce6d1 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -1255,7 +1255,7 @@ static int ovs_key_from_nlattrs(struct net *net, struct sw_flow_match *match,
 		}
 
 		if (!is_mask && ipv6_key->ipv6_label & htonl(0xFFF00000)) {
-			OVS_NLERR(log, "IPv6 flow label %x is out of range (max=%x).\n",
+			OVS_NLERR(log, "IPv6 flow label %x is out of range (max=%x)",
 				  ntohl(ipv6_key->ipv6_label), (1 << 20) - 1);
 			return -EINVAL;
 		}
-- 
2.10.0.rc2.1.g053435c
