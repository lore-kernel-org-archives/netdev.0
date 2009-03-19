From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH 1/9] of: add of_parse_phandle() helper for parsing phandle
	properties
Date: Wed, 18 Mar 2009 23:00:15 -0600
Message-ID: <20090319050015.11320.61641.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	afleming@freescale.com, avorontsov@ru.mvista.com,
	davem@davemloft.net, galak@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.183]:12515 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752113AbZCSFAU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 01:00:20 -0400
Received: by wa-out-1112.google.com with SMTP id j5so245042wah.21
        for <netdev@vger.kernel.org>; Wed, 18 Mar 2009 22:00:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Grant Likely <grant.likely@secretlab.ca>

of_parse_phandle() is a helper function to read and parse a phandle
property and return a pointer to the resulting device_node.

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---

 drivers/of/base.c  |   23 +++++++++++++++++++++++
 include/linux/of.h |    3 +++
 2 files changed, 26 insertions(+), 0 deletions(-)


diff --git a/drivers/of/base.c b/drivers/of/base.c
index cd17092..1eaada4 100644
--- a/drivers/of/base.c
+++ b/drivers/of/base.c
@@ -494,6 +494,29 @@ int of_modalias_node(struct device_node *node, char *modalias, int len)
 EXPORT_SYMBOL_GPL(of_modalias_node);
 
 /**
+ * of_parse_phandle - Resolve a phandle property to a device_node pointer
+ * @np: Pointer to device node holding phandle property
+ * @phandle_name: Name of property holding a phandle value
+ * @index: For properties holding a table of phandles, this is the index into
+ *         the table
+ *
+ * Returns the device_node pointer pointed to by the phandle, or NULL
+ */
+struct device_node *
+of_parse_phandle(struct device_node *np, const char *phandle_name, int index)
+{
+	const phandle *phandle;
+	int size;
+
+	phandle = of_get_property(np, phandle_name, &size);
+	if ((!phandle) || (size < sizeof(*phandle) * (index + 1)))
+		return NULL;
+
+	return of_find_node_by_phandle(phandle[index]);
+}
+EXPORT_SYMBOL(of_parse_phandle);
+
+/**
  * of_parse_phandles_with_args - Find a node pointed by phandle in a list
  * @np:		pointer to a device tree node containing a list
  * @list_name:	property name that contains a list
diff --git a/include/linux/of.h b/include/linux/of.h
index 6a7efa2..7be2d10 100644
--- a/include/linux/of.h
+++ b/include/linux/of.h
@@ -77,6 +77,9 @@ extern int of_n_size_cells(struct device_node *np);
 extern const struct of_device_id *of_match_node(
 	const struct of_device_id *matches, const struct device_node *node);
 extern int of_modalias_node(struct device_node *node, char *modalias, int len);
+extern struct device_node *of_parse_phandle(struct device_node *np,
+					    const char *phandle_name,
+					    int index);
 extern int of_parse_phandles_with_args(struct device_node *np,
 	const char *list_name, const char *cells_name, int index,
 	struct device_node **out_node, const void **out_args);

