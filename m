From: Patrick McHardy <kaber@trash.net>
Subject: [NETLINK 03/06]: Add nla_append()
Date: Tue, 22 Jan 2008 15:56:12 +0100 (MET)
Message-ID: <20080122145546.6862.81861.sendpatchset@localhost.localdomain>
References: <20080122145542.6862.23693.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:50742 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752051AbYAVO4N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2008 09:56:13 -0500
In-Reply-To: <20080122145542.6862.23693.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[NETLINK]: Add nla_append()

Used to append data to a message without a header or padding.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 8a6648ddc22e03bbdf6675780c917e8c8519f205
tree 39c68f8b7aea4e94c227fe421031e0969dac92ef
parent 4cf7dba2c890608fee47fe46487c79abf322dc82
author Patrick McHardy <kaber@trash.net> Tue, 22 Jan 2008 15:49:30 +0100
committer Patrick McHardy <kaber@trash.net> Tue, 22 Jan 2008 15:49:30 +0100

 include/net/netlink.h |    3 +++
 net/netlink/attr.c    |   19 +++++++++++++++++++
 2 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/include/net/netlink.h b/include/net/netlink.h
index a5e6d0e..a5506c4 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -91,6 +91,7 @@
  *   nla_reserve_nohdr(skb, len)	reserve room for an attribute w/o hdr
  *   nla_put(skb, type, len, data)	add attribute to skb
  *   nla_put_nohdr(skb, len, data)	add attribute w/o hdr
+ *   nla_append(skb, len, data)		append data to skb
  *
  * Attribute Construction for Basic Types:
  *   nla_put_u8(skb, type, value)	add u8 attribute to skb
@@ -254,6 +255,8 @@ extern int		nla_put(struct sk_buff *skb, int attrtype,
 				int attrlen, const void *data);
 extern int		nla_put_nohdr(struct sk_buff *skb, int attrlen,
 				      const void *data);
+extern int		nla_append(struct sk_buff *skb, int attrlen,
+				   const void *data);
 
 /**************************************************************************
  * Netlink Messages
diff --git a/net/netlink/attr.c b/net/netlink/attr.c
index ec39d12..feb326f 100644
--- a/net/netlink/attr.c
+++ b/net/netlink/attr.c
@@ -430,6 +430,24 @@ int nla_put_nohdr(struct sk_buff *skb, int attrlen, const void *data)
 	return 0;
 }
 
+/**
+ * nla_append - Add a netlink attribute without header or padding
+ * @skb: socket buffer to add attribute to
+ * @attrlen: length of attribute payload
+ * @data: head of attribute payload
+ *
+ * Returns -1 if the tailroom of the skb is insufficient to store
+ * the attribute payload.
+ */
+int nla_append(struct sk_buff *skb, int attrlen, const void *data)
+{
+	if (unlikely(skb_tailroom(skb) < NLA_ALIGN(attrlen)))
+		return -1;
+
+	memcpy(skb_put(skb, attrlen), data, attrlen);
+	return 0;
+}
+
 EXPORT_SYMBOL(nla_validate);
 EXPORT_SYMBOL(nla_parse);
 EXPORT_SYMBOL(nla_find);
@@ -445,3 +463,4 @@ EXPORT_SYMBOL(nla_put_nohdr);
 EXPORT_SYMBOL(nla_memcpy);
 EXPORT_SYMBOL(nla_memcmp);
 EXPORT_SYMBOL(nla_strcmp);
+EXPORT_SYMBOL(nla_append);
