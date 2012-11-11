From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Pull request for 'davem-next.r8169' branch
Date: Mon, 12 Nov 2012 00:01:28 +0100
Message-ID: <20121111230128.GA1848@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Kirill Smelkov <kirr@mns.spb.ru>,
	Dayanidhi Sreenivasan <dayanidhi.sreenivasan@gmail.com>,
	Hayes Wang <hayeswang@realtek.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:39939 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750810Ab2KKXYc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Nov 2012 18:24:32 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please pull from branch 'davem-next.r8169' in repository

git://violet.fr.zoreil.com/romieu/linux davem-next.r8169

to get the changes below.

Distance from 'davem-next' (d4185bbf62a5d8d777ee445db1581beb17882a07)
---------------------------------------------------------------------

810f4893e93b4e074be6b7a7cc6a36a1f2c51aa8
ac50974b37f2763aa8c6e6626e17694af468b9ad

Diffstat
--------

 drivers/net/ethernet/realtek/r8169.c | 10 ++--------
 1 file changed, 2 insertions(+), 8 deletions(-)

Shortlog
--------

Dayanidhi Sreenivasan (1):
      r8169: remove unused macros.

Kirill Smelkov (1):
      r8169: Drop tp arg from rtl8169_tx_vlan_tag()

Patch
-----

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 50a55fb..248f883 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -84,17 +84,12 @@ static const int multicast_filter_limit = 32;
 #define R8169_NAPI_WEIGHT	64
 #define NUM_TX_DESC	64	/* Number of Tx descriptor registers */
 #define NUM_RX_DESC	256	/* Number of Rx descriptor registers */
-#define RX_BUF_SIZE	1536	/* Rx Buffer size */
 #define R8169_TX_RING_BYTES	(NUM_TX_DESC * sizeof(struct TxDesc))
 #define R8169_RX_RING_BYTES	(NUM_RX_DESC * sizeof(struct RxDesc))
 
 #define RTL8169_TX_TIMEOUT	(6*HZ)
 #define RTL8169_PHY_TIMEOUT	(10*HZ)
 
-#define RTL_EEPROM_SIG		cpu_to_le32(0x8129)
-#define RTL_EEPROM_SIG_MASK	cpu_to_le32(0xffff)
-#define RTL_EEPROM_SIG_ADDR	0x0000
-
 /* write/read MMIO register */
 #define RTL_W8(reg, val8)	writeb ((val8), ioaddr + (reg))
 #define RTL_W16(reg, val16)	writew ((val16), ioaddr + (reg))
@@ -1819,8 +1814,7 @@ static int rtl8169_set_features(struct net_device *dev,
 }
 
 
-static inline u32 rtl8169_tx_vlan_tag(struct rtl8169_private *tp,
-				      struct sk_buff *skb)
+static inline u32 rtl8169_tx_vlan_tag(struct sk_buff *skb)
 {
 	return (vlan_tx_tag_present(skb)) ?
 		TxVlanTag | swab16(vlan_tx_tag_get(skb)) : 0x00;
@@ -5821,7 +5815,7 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 	tp->tx_skb[entry].len = len;
 	txd->addr = cpu_to_le64(mapping);
 
-	opts[1] = cpu_to_le32(rtl8169_tx_vlan_tag(tp, skb));
+	opts[1] = cpu_to_le32(rtl8169_tx_vlan_tag(skb));
 	opts[0] = DescOwn;
 
 	rtl8169_tso_csum(tp, skb, opts);
-- 
Ueimor
