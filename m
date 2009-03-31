From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH 01/14] of: add of_parse_phandle() helper for parsing phandle
	properties
Date: Tue, 31 Mar 2009 02:26:49 -0600
Message-ID: <20090331082648.1427.42546.stgit@localhost.localdomain>
References: <20090331075537.1427.7819.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: olof@lixom.net, afleming@freescale.com, galak@kernel.crashing.org,
	Anton Vorontsov <avorontsov@ru.mvista.com>,
	Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
To: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.236]:58055 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751599AbZCaI0x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2009 04:26:53 -0400
Received: by rv-out-0506.google.com with SMTP id f9so2906140rvb.1
        for <netdev@vger.kernel.org>; Tue, 31 Mar 2009 01:26:51 -0700 (PDT)
In-Reply-To: <20090331075537.1427.7819.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Grant Likely <grant.likely@secretlab.ca>

of_parse_phandle() is a helper function to read and parse a phandle
property and return a pointer to the resulting device_node.

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
CC: Michael Ellerman <michael@ellerman.id.au>
---

 drivers/of/base.c  |   24 ++++++++++++++++++++++++
 include/linux/of.h |    3 +++
 2 files changed, 27 insertions(+), 0 deletions(-)


diff --git a/drivers/of/base.c b/drivers/of/base.c
index cd17092..104b8c0 100644
--- a/drivers/of/base.c
+++ b/drivers/of/base.c
@@ -494,6 +494,30 @@ int of_modalias_node(struct device_node *node, char *modalias, int len)
 EXPORT_SYMBOL_GPL(of_modalias_node);
 
 /**
+ * of_parse_phandle - Resolve a phandle property to a device_node pointer
+ * @np: Pointer to device node holding phandle property
+ * @phandle_name: Name of property holding a phandle value
+ * @index: For properties holding a table of phandles, this is the index into
+ *         the table
+ *
+ * Returns the device_node pointer with refcount incremented.  Use
+ * of_node_put() on it when done.
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

