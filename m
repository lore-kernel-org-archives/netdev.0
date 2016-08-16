From: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Subject: [PATCH 04/16] batman-adv: netlink: hardif query
Date: Tue, 16 Aug 2016 10:32:32 +0200
Message-ID: <1471336364-16334-5-git-send-email-sw@simonwunderlich.de>
References: <1471336364-16334-1-git-send-email-sw@simonwunderlich.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org, Sven Eckelmann <sven.eckelmann-2BnEqQcu77q1Z/+hSey0Gg@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1471336364-16334-1-git-send-email-sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

From: Matthias Schiffer <mschiffer-Nyw9WiXk/RKXhJHkyCwd5uTW4wlIGRCZ@public.gmane.org>

BATADV_CMD_GET_HARDIFS will return the list of hardifs (including index,
name and MAC address) of all hardifs for a given softif.

Signed-off-by: Matthias Schiffer <mschiffer-Nyw9WiXk/RKXhJHkyCwd5uTW4wlIGRCZ@public.gmane.org>
Signed-off-by: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
[sven.eckelmann-2BnEqQcu77q1Z/+hSey0Gg@public.gmane.org: Reduce the number of changes to
BATADV_CMD_GET_HARDIFS, add policy for attributes]
Signed-off-by: Sven Eckelmann <sven.eckelmann-2BnEqQcu77q1Z/+hSey0Gg@public.gmane.org>
Signed-off-by: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Signed-off-by: Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>
---
 include/uapi/linux/batman_adv.h |   4 ++
 net/batman-adv/netlink.c        | 128 +++++++++++++++++++++++++++++++++++++++-
 2 files changed, 130 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/batman_adv.h b/include/uapi/linux/batman_adv.h
index 7afce44..8abcbca 100644
--- a/include/uapi/linux/batman_adv.h
+++ b/include/uapi/linux/batman_adv.h
@@ -40,6 +40,7 @@
  * @BATADV_ATTR_TPMETER_BYTES: amount of acked bytes during run
  * @BATADV_ATTR_TPMETER_COOKIE: session cookie to match tp_meter session
  * @BATADV_ATTR_PAD: attribute used for padding for 64-bit alignment
+ * @BATADV_ATTR_ACTIVE: Flag indicating if the hard interface is active
  * @__BATADV_ATTR_AFTER_LAST: internal use
  * @NUM_BATADV_ATTR: total number of batadv_nl_attrs available
  * @BATADV_ATTR_MAX: highest attribute number currently defined
@@ -60,6 +61,7 @@ enum batadv_nl_attrs {
 	BATADV_ATTR_TPMETER_BYTES,
 	BATADV_ATTR_TPMETER_COOKIE,
 	BATADV_ATTR_PAD,
+	BATADV_ATTR_ACTIVE,
 	/* add attributes above here, update the policy in netlink.c */
 	__BATADV_ATTR_AFTER_LAST,
 	NUM_BATADV_ATTR = __BATADV_ATTR_AFTER_LAST,
@@ -74,6 +76,7 @@ enum batadv_nl_attrs {
  * @BATADV_CMD_TP_METER: Start a tp meter session
  * @BATADV_CMD_TP_METER_CANCEL: Cancel a tp meter session
  * @BATADV_CMD_GET_ROUTING_ALGOS: Query the list of routing algorithms.
+ * @BATADV_CMD_GET_HARDIFS: Query list of hard interfaces
  * @__BATADV_CMD_AFTER_LAST: internal use
  * @BATADV_CMD_MAX: highest used command number
  */
@@ -83,6 +86,7 @@ enum batadv_nl_commands {
 	BATADV_CMD_TP_METER,
 	BATADV_CMD_TP_METER_CANCEL,
 	BATADV_CMD_GET_ROUTING_ALGOS,
+	BATADV_CMD_GET_HARDIFS,
 	/* add new commands above here */
 	__BATADV_CMD_AFTER_LAST,
 	BATADV_CMD_MAX = __BATADV_CMD_AFTER_LAST - 1
diff --git a/net/batman-adv/netlink.c b/net/batman-adv/netlink.c
index 19fb265..3f872d6 100644
--- a/net/batman-adv/netlink.c
+++ b/net/batman-adv/netlink.c
@@ -26,10 +26,14 @@
 #include <linux/netdevice.h>
 #include <linux/netlink.h>
 #include <linux/printk.h>
+#include <linux/rculist.h>
+#include <linux/rcupdate.h>
+#include <linux/skbuff.h>
 #include <linux/stddef.h>
 #include <linux/types.h>
 #include <net/genetlink.h>
 #include <net/netlink.h>
+#include <net/sock.h>
 #include <uapi/linux/batman_adv.h>
 
 #include "bat_algo.h"
@@ -37,8 +41,6 @@
 #include "soft-interface.h"
 #include "tp_meter.h"
 
-struct sk_buff;
-
 struct genl_family batadv_netlink_family = {
 	.id = GENL_ID_GENERATE,
 	.hdrsize = 0,
@@ -70,9 +72,25 @@ static struct nla_policy batadv_netlink_policy[NUM_BATADV_ATTR] = {
 	[BATADV_ATTR_TPMETER_TEST_TIME]	= { .type = NLA_U32 },
 	[BATADV_ATTR_TPMETER_BYTES]	= { .type = NLA_U64 },
 	[BATADV_ATTR_TPMETER_COOKIE]	= { .type = NLA_U32 },
+	[BATADV_ATTR_ACTIVE]		= { .type = NLA_FLAG },
 };
 
 /**
+ * batadv_netlink_get_ifindex - Extract an interface index from a message
+ * @nlh: Message header
+ * @attrtype: Attribute which holds an interface index
+ *
+ * Return: interface index, or 0.
+ */
+static int
+batadv_netlink_get_ifindex(const struct nlmsghdr *nlh, int attrtype)
+{
+	struct nlattr *attr = nlmsg_find_attr(nlh, GENL_HDRLEN, attrtype);
+
+	return attr ? nla_get_u32(attr) : 0;
+}
+
+/**
  * batadv_netlink_mesh_info_put - fill in generic information about mesh
  *  interface
  * @msg: netlink message to be sent back
@@ -381,6 +399,106 @@ out:
 	return ret;
 }
 
+/**
+ * batadv_netlink_dump_hardif_entry - Dump one hard interface into a message
+ * @msg: Netlink message to dump into
+ * @portid: Port making netlink request
+ * @seq: Sequence number of netlink message
+ * @hard_iface: Hard interface to dump
+ *
+ * Return: error code, or 0 on success
+ */
+static int
+batadv_netlink_dump_hardif_entry(struct sk_buff *msg, u32 portid, u32 seq,
+				 struct batadv_hard_iface *hard_iface)
+{
+	struct net_device *net_dev = hard_iface->net_dev;
+	void *hdr;
+
+	hdr = genlmsg_put(msg, portid, seq, &batadv_netlink_family, NLM_F_MULTI,
+			  BATADV_CMD_GET_HARDIFS);
+	if (!hdr)
+		return -EMSGSIZE;
+
+	if (nla_put_u32(msg, BATADV_ATTR_HARD_IFINDEX,
+			net_dev->ifindex) ||
+	    nla_put_string(msg, BATADV_ATTR_HARD_IFNAME,
+			   net_dev->name) ||
+	    nla_put(msg, BATADV_ATTR_HARD_ADDRESS, ETH_ALEN,
+		    net_dev->dev_addr))
+		goto nla_put_failure;
+
+	if (hard_iface->if_status == BATADV_IF_ACTIVE) {
+		if (nla_put_flag(msg, BATADV_ATTR_ACTIVE))
+			goto nla_put_failure;
+	}
+
+	genlmsg_end(msg, hdr);
+	return 0;
+
+ nla_put_failure:
+	genlmsg_cancel(msg, hdr);
+	return -EMSGSIZE;
+}
+
+/**
+ * batadv_netlink_dump_hardifs - Dump all hard interface into a messages
+ * @msg: Netlink message to dump into
+ * @cb: Parameters from query
+ *
+ * Return: error code, or length of reply message on success
+ */
+static int
+batadv_netlink_dump_hardifs(struct sk_buff *msg, struct netlink_callback *cb)
+{
+	struct net *net = sock_net(cb->skb->sk);
+	struct net_device *soft_iface;
+	struct batadv_hard_iface *hard_iface;
+	int ifindex;
+	int portid = NETLINK_CB(cb->skb).portid;
+	int seq = cb->nlh->nlmsg_seq;
+	int skip = cb->args[0];
+	int i = 0;
+
+	ifindex = batadv_netlink_get_ifindex(cb->nlh,
+					     BATADV_ATTR_MESH_IFINDEX);
+	if (!ifindex)
+		return -EINVAL;
+
+	soft_iface = dev_get_by_index(net, ifindex);
+	if (!soft_iface)
+		return -ENODEV;
+
+	if (!batadv_softif_is_valid(soft_iface)) {
+		dev_put(soft_iface);
+		return -ENODEV;
+	}
+
+	rcu_read_lock();
+
+	list_for_each_entry_rcu(hard_iface, &batadv_hardif_list, list) {
+		if (hard_iface->soft_iface != soft_iface)
+			continue;
+
+		if (i++ < skip)
+			continue;
+
+		if (batadv_netlink_dump_hardif_entry(msg, portid, seq,
+						     hard_iface)) {
+			i--;
+			break;
+		}
+	}
+
+	rcu_read_unlock();
+
+	dev_put(soft_iface);
+
+	cb->args[0] = i;
+
+	return msg->len;
+}
+
 static struct genl_ops batadv_netlink_ops[] = {
 	{
 		.cmd = BATADV_CMD_GET_MESH_INFO,
@@ -406,6 +524,12 @@ static struct genl_ops batadv_netlink_ops[] = {
 		.policy = batadv_netlink_policy,
 		.dumpit = batadv_algo_dump,
 	},
+	{
+		.cmd = BATADV_CMD_GET_HARDIFS,
+		.flags = GENL_ADMIN_PERM,
+		.policy = batadv_netlink_policy,
+		.dumpit = batadv_netlink_dump_hardifs,
+	},
 };
 
 /**
-- 
2.8.1
