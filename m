From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net-next 01/10] net: etherdevice: add address inherit helper
Date: Fri, 23 Aug 2013 11:35:04 +0200
Message-ID: <1377250513-3662-2-git-send-email-bjorn@mork.no>
References: <1377250513-3662-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:40736 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753444Ab3HWJfw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Aug 2013 05:35:52 -0400
In-Reply-To: <1377250513-3662-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some etherdevices inherit their address from a parent or
master device. The addr_assign_type should be updated along
with the address in these cases.  Adding a helper function
to simplify this.

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 include/linux/etherdevice.h |   19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
index c623861..49b6695 100644
--- a/include/linux/etherdevice.h
+++ b/include/linux/etherdevice.h
@@ -199,6 +199,25 @@ static inline void eth_hw_addr_random(struct net_d=
evice *dev)
 }
=20
 /**
+ * eth_hw_addr_inherit - Copy dev_addr from another net_device
+ * @dst: pointer to net_device to copy dev_addr to
+ * @src: pointer to net_device to copy dev_addr from
+ *
+ * Copy the Ethernet address from one net_device to another along with
+ * the addr_assign_type.
+ */
+static inline int eth_hw_addr_inherit(struct net_device *dst,
+				      struct net_device *src)
+{
+	if (dst->addr_len !=3D src->addr_len)
+		return -EINVAL;
+
+	dst->addr_assign_type =3D src->addr_assign_type;
+	memcpy(dst->dev_addr, src->dev_addr, dst->addr_len);
+	return 0;
+}
+
+/**
  * compare_ether_addr - Compare two Ethernet addresses
  * @addr1: Pointer to a six-byte array containing the Ethernet address
  * @addr2: Pointer other six-byte array containing the Ethernet addres=
s
--=20
1.7.10.4
