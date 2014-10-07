From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1 net-next] wimax: convert printk to pr_foo()
Date: Tue,  7 Oct 2014 22:12:03 +0200
Message-ID: <1412712724-4100-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>,
	Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>,
	linux-wimax@intel.com, "David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use current logging functions and add module name prefix.

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
Compiled but untested.

 net/wimax/id-table.c       | 2 +-
 net/wimax/op-msg.c         | 9 ++++-----
 net/wimax/op-reset.c       | 3 +--
 net/wimax/op-rfkill.c      | 3 +--
 net/wimax/op-state-get.c   | 3 +--
 net/wimax/stack.c          | 7 +++----
 net/wimax/wimax-internal.h | 6 ++++++
 7 files changed, 17 insertions(+), 16 deletions(-)

diff --git a/net/wimax/id-table.c b/net/wimax/id-table.c
index 72273ab..a21508d 100644
--- a/net/wimax/id-table.c
+++ b/net/wimax/id-table.c
@@ -137,7 +137,7 @@ void wimax_id_table_release(void)
 #endif
 	spin_lock(&wimax_id_table_lock);
 	list_for_each_entry(wimax_dev, &wimax_id_table, id_table_node) {
-		printk(KERN_ERR "BUG: %s wimax_dev %p ifindex %d not cleared\n",
+		pr_err("BUG: %s wimax_dev %p ifindex %d not cleared\n",
 		       __func__, wimax_dev, wimax_dev->net_dev->ifindex);
 		WARN_ON(1);
 	}
diff --git a/net/wimax/op-msg.c b/net/wimax/op-msg.c
index c278b33..54aa146 100644
--- a/net/wimax/op-msg.c
+++ b/net/wimax/op-msg.c
@@ -189,7 +189,7 @@ const void *wimax_msg_data_len(struct sk_buff *msg, size_t *size)
 	nla = nlmsg_find_attr(nlh, sizeof(struct genlmsghdr),
 			      WIMAX_GNL_MSG_DATA);
 	if (nla == NULL) {
-		printk(KERN_ERR "Cannot find attribute WIMAX_GNL_MSG_DATA\n");
+		pr_err("Cannot find attribute WIMAX_GNL_MSG_DATA\n");
 		return NULL;
 	}
 	*size = nla_len(nla);
@@ -211,7 +211,7 @@ const void *wimax_msg_data(struct sk_buff *msg)
 	nla = nlmsg_find_attr(nlh, sizeof(struct genlmsghdr),
 			      WIMAX_GNL_MSG_DATA);
 	if (nla == NULL) {
-		printk(KERN_ERR "Cannot find attribute WIMAX_GNL_MSG_DATA\n");
+		pr_err("Cannot find attribute WIMAX_GNL_MSG_DATA\n");
 		return NULL;
 	}
 	return nla_data(nla);
@@ -232,7 +232,7 @@ ssize_t wimax_msg_len(struct sk_buff *msg)
 	nla = nlmsg_find_attr(nlh, sizeof(struct genlmsghdr),
 			      WIMAX_GNL_MSG_DATA);
 	if (nla == NULL) {
-		printk(KERN_ERR "Cannot find attribute WIMAX_GNL_MSG_DATA\n");
+		pr_err("Cannot find attribute WIMAX_GNL_MSG_DATA\n");
 		return -EINVAL;
 	}
 	return nla_len(nla);
@@ -343,8 +343,7 @@ int wimax_gnl_doit_msg_from_user(struct sk_buff *skb, struct genl_info *info)
 	d_fnstart(3, NULL, "(skb %p info %p)\n", skb, info);
 	result = -ENODEV;
 	if (info->attrs[WIMAX_GNL_MSG_IFIDX] == NULL) {
-		printk(KERN_ERR "WIMAX_GNL_MSG_FROM_USER: can't find IFIDX "
-		       "attribute\n");
+		pr_err("WIMAX_GNL_MSG_FROM_USER: can't find IFIDX attribute\n");
 		goto error_no_wimax_dev;
 	}
 	ifindex = nla_get_u32(info->attrs[WIMAX_GNL_MSG_IFIDX]);
diff --git a/net/wimax/op-reset.c b/net/wimax/op-reset.c
index eb45807..a420791 100644
--- a/net/wimax/op-reset.c
+++ b/net/wimax/op-reset.c
@@ -107,8 +107,7 @@ int wimax_gnl_doit_reset(struct sk_buff *skb, struct genl_info *info)
 	d_fnstart(3, NULL, "(skb %p info %p)\n", skb, info);
 	result = -ENODEV;
 	if (info->attrs[WIMAX_GNL_RESET_IFIDX] == NULL) {
-		printk(KERN_ERR "WIMAX_GNL_OP_RFKILL: can't find IFIDX "
-			"attribute\n");
+		pr_err("WIMAX_GNL_OP_RFKILL: can't find IFIDX attribute\n");
 		goto error_no_wimax_dev;
 	}
 	ifindex = nla_get_u32(info->attrs[WIMAX_GNL_RESET_IFIDX]);
diff --git a/net/wimax/op-rfkill.c b/net/wimax/op-rfkill.c
index 403078d..7d73054 100644
--- a/net/wimax/op-rfkill.c
+++ b/net/wimax/op-rfkill.c
@@ -421,8 +421,7 @@ int wimax_gnl_doit_rfkill(struct sk_buff *skb, struct genl_info *info)
 	d_fnstart(3, NULL, "(skb %p info %p)\n", skb, info);
 	result = -ENODEV;
 	if (info->attrs[WIMAX_GNL_RFKILL_IFIDX] == NULL) {
-		printk(KERN_ERR "WIMAX_GNL_OP_RFKILL: can't find IFIDX "
-			"attribute\n");
+		pr_err("WIMAX_GNL_OP_RFKILL: can't find IFIDX attribute\n");
 		goto error_no_wimax_dev;
 	}
 	ifindex = nla_get_u32(info->attrs[WIMAX_GNL_RFKILL_IFIDX]);
diff --git a/net/wimax/op-state-get.c b/net/wimax/op-state-get.c
index 995c08c..e6788d2 100644
--- a/net/wimax/op-state-get.c
+++ b/net/wimax/op-state-get.c
@@ -49,8 +49,7 @@ int wimax_gnl_doit_state_get(struct sk_buff *skb, struct genl_info *info)
 	d_fnstart(3, NULL, "(skb %p info %p)\n", skb, info);
 	result = -ENODEV;
 	if (info->attrs[WIMAX_GNL_STGET_IFIDX] == NULL) {
-		printk(KERN_ERR "WIMAX_GNL_OP_STATE_GET: can't find IFIDX "
-			"attribute\n");
+		pr_err("WIMAX_GNL_OP_STATE_GET: can't find IFIDX attribute\n");
 		goto error_no_wimax_dev;
 	}
 	ifindex = nla_get_u32(info->attrs[WIMAX_GNL_STGET_IFIDX]);
diff --git a/net/wimax/stack.c b/net/wimax/stack.c
index ec8b577..3f816e2 100644
--- a/net/wimax/stack.c
+++ b/net/wimax/stack.c
@@ -191,8 +191,8 @@ void __check_new_state(enum wimax_st old_state, enum wimax_st new_state,
 		       unsigned int allowed_states_bm)
 {
 	if (WARN_ON(((1 << new_state) & allowed_states_bm) == 0)) {
-		printk(KERN_ERR "SW BUG! Forbidden state change %u -> %u\n",
-			old_state, new_state);
+		pr_err("SW BUG! Forbidden state change %u -> %u\n",
+		       old_state, new_state);
 	}
 }
 
@@ -602,8 +602,7 @@ int __init wimax_subsys_init(void)
 						      wimax_gnl_ops,
 						      wimax_gnl_mcgrps);
 	if (unlikely(result < 0)) {
-		printk(KERN_ERR "cannot register generic netlink family: %d\n",
-		       result);
+		pr_err("cannot register generic netlink family: %d\n", result);
 		goto error_register_family;
 	}
 
diff --git a/net/wimax/wimax-internal.h b/net/wimax/wimax-internal.h
index b445b82..733c4bf 100644
--- a/net/wimax/wimax-internal.h
+++ b/net/wimax/wimax-internal.h
@@ -30,6 +30,12 @@
 #define __WIMAX_INTERNAL_H__
 #ifdef __KERNEL__
 
+#ifdef pr_fmt
+#undef pr_fmt
+#endif
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/device.h>
 #include <net/wimax.h>
 
-- 
1.9.3
