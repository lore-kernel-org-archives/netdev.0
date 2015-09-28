From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH bluetooth-next 1/4] netlink: add nla_get for le32 and le64
Date: Mon, 28 Sep 2015 09:00:23 +0200
Message-ID: <1443423626-3609-2-git-send-email-alex.aring@gmail.com>
References: <1443423626-3609-1-git-send-email-alex.aring@gmail.com>
Cc: kernel@pengutronix.de, netdev@vger.kernel.org,
	phoebe.buckheister@itwm.fraunhofer.de,
	Alexander Aring <alex.aring@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: linux-wpan@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:35417 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753914AbbI1HCQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2015 03:02:16 -0400
In-Reply-To: <1443423626-3609-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds missing inline wrappers for nla_get_le32 and
nla_get_le64. The 802.15.4 MAC byteorder is little endian and we keep
the byteorder for fields like address configuration in the same
byteorder as it comes from the MAC layer.

To provide these fields for nl802154 userspace applications, we need
these inline wrappers for netlink.

Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Alexander Aring <alex.aring@gmail.com>
---
 include/net/netlink.h | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/include/net/netlink.h b/include/net/netlink.h
index 2a5dbcc..0e31727 100644
--- a/include/net/netlink.h
+++ b/include/net/netlink.h
@@ -1004,6 +1004,15 @@ static inline __be32 nla_get_be32(const struct nlattr *nla)
 }
 
 /**
+ * nla_get_le32 - return payload of __le32 attribute
+ * @nla: __le32 netlink attribute
+ */
+static inline __le32 nla_get_le32(const struct nlattr *nla)
+{
+	return *(__le32 *) nla_data(nla);
+}
+
+/**
  * nla_get_u16 - return payload of u16 attribute
  * @nla: u16 netlink attribute
  */
@@ -1066,6 +1075,15 @@ static inline __be64 nla_get_be64(const struct nlattr *nla)
 }
 
 /**
+ * nla_get_le64 - return payload of __le64 attribute
+ * @nla: __le64 netlink attribute
+ */
+static inline __le64 nla_get_le64(const struct nlattr *nla)
+{
+	return *(__le64 *) nla_data(nla);
+}
+
+/**
  * nla_get_s32 - return payload of s32 attribute
  * @nla: s32 netlink attribute
  */
-- 
2.5.3
