From: Tom Gundersen <teg@jklm.no>
Subject: [PATCH net-next v9 7/9] net: vlan - set name assign type
Date: Thu, 17 Jul 2014 10:06:08 +0200
Message-ID: <1405584370-30054-8-git-send-email-teg@jklm.no>
References: <1405584370-30054-1-git-send-email-teg@jklm.no>
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	Tom Gundersen <teg@jklm.no>, Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405584370-30054-1-git-send-email-teg@jklm.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When deriving the name from the real device, inherit the assign type, otherwise
set PREDICTABLE as the name will be uniquely determined by the VLANID.

Signed-off-by: Tom Gundersen <teg@jklm.no>
Cc: Patrick McHardy <kaber@trash.net>
---
 net/8021q/vlan.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index cba9c21..cf88f7b 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -212,6 +212,7 @@ static int register_vlan_device(struct net_device *real_dev, u16 vlan_id)
 {
 	struct net_device *new_dev;
 	struct vlan_dev_priv *vlan;
+	unsigned char name_assign_type;
 	struct net *net = dev_net(real_dev);
 	struct vlan_net *vn = net_generic(net, vlan_net_id);
 	char name[IFNAMSIZ];
@@ -229,18 +230,21 @@ static int register_vlan_device(struct net_device *real_dev, u16 vlan_id)
 	case VLAN_NAME_TYPE_RAW_PLUS_VID:
 		/* name will look like:	 eth1.0005 */
 		snprintf(name, IFNAMSIZ, "%s.%.4i", real_dev->name, vlan_id);
+		name_assign_type = real_dev->name_assign_type;
 		break;
 	case VLAN_NAME_TYPE_PLUS_VID_NO_PAD:
 		/* Put our vlan.VID in the name.
 		 * Name will look like:	 vlan5
 		 */
 		snprintf(name, IFNAMSIZ, "vlan%i", vlan_id);
+		name_assign_type = NET_NAME_PREDICTABLE;
 		break;
 	case VLAN_NAME_TYPE_RAW_PLUS_VID_NO_PAD:
 		/* Put our vlan.VID in the name.
 		 * Name will look like:	 eth0.5
 		 */
 		snprintf(name, IFNAMSIZ, "%s.%i", real_dev->name, vlan_id);
+		name_assign_type = real_dev->name_assign_type;
 		break;
 	case VLAN_NAME_TYPE_PLUS_VID:
 		/* Put our vlan.VID in the name.
@@ -248,10 +252,11 @@ static int register_vlan_device(struct net_device *real_dev, u16 vlan_id)
 		 */
 	default:
 		snprintf(name, IFNAMSIZ, "vlan%.4i", vlan_id);
+		name_assign_type = NET_NAME_PREDICTABLE;
 	}
 
 	new_dev = alloc_netdev(sizeof(struct vlan_dev_priv), name,
-			       NET_NAME_UNKNOWN, vlan_setup);
+			       name_assign_type, vlan_setup);
 
 	if (new_dev == NULL)
 		return -ENOBUFS;
-- 
1.9.3
