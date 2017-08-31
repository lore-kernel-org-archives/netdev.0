From: Samuel Mendoza-Jonas <sam@mendozajonas.com>
Subject: [PATCH net-next] net/ncsi: Define {add,kill}_vid callbacks for !CONFIG_NET_NCSI
Date: Thu, 31 Aug 2017 13:38:46 +1000
Message-ID: <20170831033846.23538-1-sam@mendozajonas.com>
Cc: Samuel Mendoza-Jonas <sam@mendozajonas.com>,
        Joel Stanley <joel@jms.id.au>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Gavin Shan <gwshan@linux.vnet.ibm.com>
To: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        OpenBMC Maillist <openbmc@lists.ozlabs.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patch "net/ncsi: Configure VLAN tag filter" defined two new callback
functions in include/net/ncsi.h, but neglected the !CONFIG_NET_NCSI
case. This can cause a build error if these are referenced elsewhere
without NCSI enabled, for example in ftgmac100:

>>> ERROR: "ncsi_vlan_rx_kill_vid" [drivers/net/ethernet/faraday/ftgmac100.ko] undefined!
>>> ERROR: "ncsi_vlan_rx_add_vid" [drivers/net/ethernet/faraday/ftgmac100.ko] undefined!

Add definitions for !CONFIG_NET_NCSI to bring it into line with the rest
of ncsi.h

Signed-off-by: Samuel Mendoza-Jonas <sam@mendozajonas.com>
---
 include/net/ncsi.h | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/include/net/ncsi.h b/include/net/ncsi.h
index 1f96af46df49..2b13b6b91a4d 100644
--- a/include/net/ncsi.h
+++ b/include/net/ncsi.h
@@ -36,6 +36,14 @@ int ncsi_start_dev(struct ncsi_dev *nd);
 void ncsi_stop_dev(struct ncsi_dev *nd);
 void ncsi_unregister_dev(struct ncsi_dev *nd);
 #else /* !CONFIG_NET_NCSI */
+int ncsi_vlan_rx_add_vid(struct net_device *dev, __be16 proto, u16 vid)
+{
+	return -ENOTTY;
+}
+int ncsi_vlan_rx_kill_vid(struct net_device *dev, __be16 proto, u16 vid)
+{
+	return -ENOTTY;
+}
 static inline struct ncsi_dev *ncsi_register_dev(struct net_device *dev,
 					void (*notifier)(struct ncsi_dev *nd))
 {
-- 
2.14.1
