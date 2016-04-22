From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 7/9] libnl: add nla_put_u64_64bit() helper
Date: Fri, 22 Apr 2016 17:31:22 +0200
Message-ID: <1461339084-3849-8-git-send-email-nicolas.dichtel@6wind.com>
References: <1461339084-3849-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	linux-wpan@vger.kernel.org, aar@pengutronix.de,
	pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	pshelar@nicira.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, netfilter-devel@vger.kernel.org,
	dev@openvswitch.org, steffen.klassert@secunet.com,
	herbert@gondor.apana.org.au, bsingharora@gmail.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:53585 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753993AbcDVPcE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2016 11:32:04 -0400
In-Reply-To: <1461339084-3849-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With this function, nla_data() is aligned on a 64-bit area.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/net/netlink.h | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/include/net/netlink.h b/include/net/netlink.h
index 113b483b6ee8..e589cb3dccee 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -858,6 +858,19 @@ static inline int nla_put_u64(struct sk_buff *skb, int attrtype, u64 value)
 }
 
 /**
+ * nla_put_u64_64bit - Add a u64 netlink attribute to a skb and align it
+ * @skb: socket buffer to add attribute to
+ * @attrtype: attribute type
+ * @value: numeric value
+ * @padattr: attribute type for the padding
+ */
+static inline int nla_put_u64_64bit(struct sk_buff *skb, int attrtype,
+				    u64 value, int padattr)
+{
+	return nla_put_64bit(skb, attrtype, sizeof(u64), &value, padattr);
+}
+
+/**
  * nla_put_be64 - Add a __be64 netlink attribute to a socket buffer and align it
  * @skb: socket buffer to add attribute to
  * @attrtype: attribute type
-- 
2.8.1
