From: Yan Burman <yanb@mellanox.com>
Subject: [PATCH net-next] net: ethool: Document struct ethtool_flow_ext
Date: Thu, 13 Dec 2012 17:20:59 +0200
Message-ID: <1355412059-25663-1-git-send-email-yanb@mellanox.com>
Cc: Yan Burman <yanb@mellanox.com>
To: "Or Gerlitz" <ogerlitz@mellanox.com>,
	"Amir Vadai" <amirv@mellanox.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	"Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog113.obsmtp.com ([207.126.144.135]:40668 "HELO
	eu1sys200aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755360Ab2LMP4u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2012 10:56:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add documentation for struct ethtool_flow_ext especially in regard
to what flags are needed for which fields.

Signed-off-by: Yan Burman <yanb@mellanox.com>
---
 include/uapi/linux/ethtool.h | 16 ++++++++++++++--
 1 file changed, 14 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index be8c41e..0c9b448 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -503,9 +503,20 @@ union ethtool_flow_union {
 	__u8					hdata[52];
 };
 
+/**
+ * struct ethtool_flow_ext - additional RX flow fields
+ * @h_dest: destination MAC address
+ * @vlan_etype: VLAN EtherType
+ * @vlan_tci: VLAN tag control information
+ * @data: user defined data
+ *
+ * Note, @vlan_etype, @vlan_tci, and @data are only valid if %FLOW_EXT
+ * is set in &struct ethtool_rx_flow_spec @flow_type.
+ * @h_dest is valid if %FLOW_MAC_EXT is set.
+ */
 struct ethtool_flow_ext {
 	__u8		padding[2];
-	unsigned char	h_dest[ETH_ALEN];	/* destination eth addr	*/
+	unsigned char	h_dest[ETH_ALEN];
 	__be16		vlan_etype;
 	__be16		vlan_tci;
 	__be32		data[2];
@@ -519,7 +530,8 @@ struct ethtool_flow_ext {
  * @m_u: Masks for flow field bits to be matched
  * @m_ext: Masks for additional field bits to be matched
  *	Note, all additional fields must be ignored unless @flow_type
- *	includes the %FLOW_EXT flag.
+ *	includes the %FLOW_EXT or %FLOW_MAC_EXT flag
+ *	(see &struct ethtool_flow_ext description).
  * @ring_cookie: RX ring/queue index to deliver to, or %RX_CLS_FLOW_DISC
  *	if packets should be discarded
  * @location: Location of rule in the table.  Locations must be
-- 
1.7.11.3
