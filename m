From: paul.moore@hp.com
Subject: [PATCH v2 5/8] Netlink: add nla_validate_nested()
Date: Mon, 25 Sep 2006 14:04:17 -0400
Message-ID: <20060925180642.032407000@hp.com>
References: <20060925180412.715069000@hp.com>
Cc: tgraf@suug.ch, jmorris@redhat.com, sds@epoch.ncsc.mil,
	Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:27852 "EHLO atlrel6.hp.com")
	by vger.kernel.org with ESMTP id S1751428AbWIYSGo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2006 14:06:44 -0400
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Content-Disposition: inline; filename=netlink-new_nlattr_iface
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a new function, nla_validate_nested(), to validate nested Netlink
attributes.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---
 include/net/netlink.h |   19 +++++++++++++++++++
 1 files changed, 19 insertions(+)

Index: net-2.6.19/include/net/netlink.h
===================================================================
--- net-2.6.19.orig/include/net/netlink.h
+++ net-2.6.19/include/net/netlink.h
@@ -146,6 +146,7 @@
  *   nla_ok(nla, remaining)		does nla fit into remaining bytes?
  *   nla_next(nla, remaining)		get next netlink attribute
  *   nla_validate()			validate a stream of attributes
+ *   nla_validate_nested()		validate a stream of nested attributes
  *   nla_find()				find attribute in stream of attributes
  *   nla_find_nested()			find attribute in nested attributes
  *   nla_parse()			parse and validate stream of attrs
@@ -951,6 +952,24 @@ static inline int nla_nest_cancel(struct
 }
 
 /**
+ * nla_validate_nested - Validate a stream of nested attributes
+ * @start: container attribute
+ * @maxtype: maximum attribute type to be expected
+ * @policy: validation policy
+ *
+ * Validates all attributes in the nested attribute stream against the
+ * specified policy. Attributes with a type exceeding maxtype will be
+ * ignored. See documenation of struct nla_policy for more details.
+ *
+ * Returns 0 on success or a negative error code.
+ */
+static inline int nla_validate_nested(struct nlattr *start, int maxtype,
+				      struct nla_policy *policy)
+{
+	return nla_validate(nla_data(start), nla_len(start), maxtype, policy);
+}
+
+/**
  * nla_for_each_attr - iterate over a stream of attributes
  * @pos: loop counter, set to current attribute
  * @head: head of attribute stream

--
paul moore
linux security @ hp
