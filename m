From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 1/6] 8021q: Convert uses of __constant_<foo> to <foo>
Date: Wed, 12 Mar 2014 10:04:15 -0700
Message-ID: <c44725e4804d6e64f44263bfcb4d4c3d2d057db4.1394643455.git.joe@perches.com>
References: <cover.1394643455.git.joe@perches.com>
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1394643455.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The use of __constant_<foo> has been unnecessary for quite awhile now.

Make these uses consistent with the rest of the kernel.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/8021q/vlan.h         | 4 ++--
 net/8021q/vlan_netlink.c | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/8021q/vlan.h b/net/8021q/vlan.h
index 5704ed9..9d010a09 100644
--- a/net/8021q/vlan.h
+++ b/net/8021q/vlan.h
@@ -38,9 +38,9 @@ struct vlan_info {
 static inline unsigned int vlan_proto_idx(__be16 proto)
 {
 	switch (proto) {
-	case __constant_htons(ETH_P_8021Q):
+	case htons(ETH_P_8021Q):
 		return VLAN_PROTO_8021Q;
-	case __constant_htons(ETH_P_8021AD):
+	case htons(ETH_P_8021AD):
 		return VLAN_PROTO_8021AD;
 	default:
 		BUG();
diff --git a/net/8021q/vlan_netlink.c b/net/8021q/vlan_netlink.c
index c7e634a..8ac8a5c 100644
--- a/net/8021q/vlan_netlink.c
+++ b/net/8021q/vlan_netlink.c
@@ -56,8 +56,8 @@ static int vlan_validate(struct nlattr *tb[], struct nlattr *data[])
 
 	if (data[IFLA_VLAN_PROTOCOL]) {
 		switch (nla_get_be16(data[IFLA_VLAN_PROTOCOL])) {
-		case __constant_htons(ETH_P_8021Q):
-		case __constant_htons(ETH_P_8021AD):
+		case htons(ETH_P_8021Q):
+		case htons(ETH_P_8021AD):
 			break;
 		default:
 			return -EPROTONOSUPPORT;
-- 
1.8.1.2.459.gbcd45b4.dirty
