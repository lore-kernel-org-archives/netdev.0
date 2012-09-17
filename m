From: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
Subject: [PATCH v3 1/5] dt: introduce of_get_child_by_name to get child node by name.
Date: Mon, 17 Sep 2012 09:57:29 +0100
Message-ID: <1347872249-3671-1-git-send-email-srinivas.kandagatla@st.com>
Cc: benh@kernel.crashing.org, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org, jassi.brar@samsung.com,
	afleming@freescale.com, srinivas.kandagatla@st.com,
	grant.likely@secretlab.ca
To: robherring2@gmail.com, bergner@us.ibm.com,
	devicetree-discuss@lists.ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog105.obsmtp.com ([207.126.144.119]:51123 "EHLO
	eu1sys200aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753492Ab2IQJBQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2012 05:01:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Srinivas Kandagatla <srinivas.kandagatla@st.com>

This patch introduces of_get_child_by_name function to get a child node
by its name in a given parent node.

Without this patch each driver code has to iterate the parent and do
a string compare, However having of_get_child_by_name libary function would
avoid code duplication, errors and is more convenient.

Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>
---
 drivers/of/base.c  |   25 +++++++++++++++++++++++++
 include/linux/of.h |    2 ++
 2 files changed, 27 insertions(+), 0 deletions(-)

diff --git a/drivers/of/base.c b/drivers/of/base.c
index d4a1c9a..7391f8a 100644
--- a/drivers/of/base.c
+++ b/drivers/of/base.c
@@ -391,6 +391,31 @@ struct device_node *of_get_next_available_child(const struct device_node *node,
 EXPORT_SYMBOL(of_get_next_available_child);
 
 /**
+ *	of_get_child_by_name - Find the child node by name for a given parent
+ *	@node:	parent node
+ *	@name:	child name to look for.
+ *
+ *      This function looks for child node for given matching name
+ *
+ *	Returns a node pointer if found, with refcount incremented, use
+ *	of_node_put() on it when done.
+ *	Returns NULL if node is not found.
+ */
+
+struct device_node *of_get_child_by_name(const struct device_node *node,
+				const char *name)
+{
+	struct device_node *child;
+
+	for_each_child_of_node(node, child)
+		if (child->name && (of_node_cmp(child->name, name) == 0)
+			&& of_node_get(child))
+			break;
+	return child;
+}
+EXPORT_SYMBOL(of_get_child_by_name);
+
+/**
  *	of_find_node_by_path - Find a node matching a full OF path
  *	@path:	The full path to match
  *
diff --git a/include/linux/of.h b/include/linux/of.h
index 1b11632..7b8e3cd 100644
--- a/include/linux/of.h
+++ b/include/linux/of.h
@@ -192,6 +192,8 @@ extern struct device_node *of_get_next_child(const struct device_node *node,
 					     struct device_node *prev);
 extern struct device_node *of_get_next_available_child(
 	const struct device_node *node, struct device_node *prev);
+extern struct device_node *of_get_child_by_name(const struct device_node *node,
+					const char *name);
 
 #define for_each_child_of_node(parent, child) \
 	for (child = of_get_next_child(parent, NULL); child != NULL; \
-- 
1.7.0.4
