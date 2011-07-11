From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH v2 04/46] net/wireless: p54: remove useless
 dma_sync_single_for_device(DMA_FROM_DEVICE)
Date: Mon, 11 Jul 2011 02:52:46 +0200 (CEST)
Message-ID: <86c8bde08b005ca7eb4806ea77aec1f3212d63fc.1310339688.git.mirq-linux@rere.qmqm.pl>
References: <cover.1310339688.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christian Lamparter <chunkeey@googlemail.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:43649 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751794Ab1GKAwt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Jul 2011 20:52:49 -0400
In-Reply-To: <cover.1310339688.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also constify pointers used in frame parsers to verify assumptions.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/wireless/p54/p54pci.c |    2 --
 drivers/net/wireless/p54/txrx.c   |   22 +++++++++++-----------
 2 files changed, 11 insertions(+), 13 deletions(-)

diff --git a/drivers/net/wireless/p54/p54pci.c b/drivers/net/wireless/p=
54/p54pci.c
index 1b75317..4491d33 100644
--- a/drivers/net/wireless/p54/p54pci.c
+++ b/drivers/net/wireless/p54/p54pci.c
@@ -229,8 +229,6 @@ static void p54p_check_rx_ring(struct ieee80211_hw =
*dev, u32 *index,
 			desc->host_addr =3D cpu_to_le32(0);
 		} else {
 			skb_trim(skb, 0);
-			pci_dma_sync_single_for_device(priv->pdev, dma_addr,
-				priv->common.rx_mtu + 32, PCI_DMA_FROMDEVICE);
 			desc->len =3D cpu_to_le16(priv->common.rx_mtu + 32);
 		}
=20
diff --git a/drivers/net/wireless/p54/txrx.c b/drivers/net/wireless/p54=
/txrx.c
index 042842e..b7ecd89 100644
--- a/drivers/net/wireless/p54/txrx.c
+++ b/drivers/net/wireless/p54/txrx.c
@@ -325,7 +325,7 @@ static void p54_pspoll_workaround(struct p54_common=
 *priv, struct sk_buff *skb)
=20
 static int p54_rx_data(struct p54_common *priv, struct sk_buff *skb)
 {
-	struct p54_rx_data *hdr =3D (struct p54_rx_data *) skb->data;
+	const struct p54_rx_data *hdr =3D (void *)skb->data;
 	struct ieee80211_rx_status *rx_status =3D IEEE80211_SKB_RXCB(skb);
 	u16 freq =3D le16_to_cpu(hdr->freq);
 	size_t header_len =3D sizeof(*hdr);
@@ -387,8 +387,8 @@ static int p54_rx_data(struct p54_common *priv, str=
uct sk_buff *skb)
=20
 static void p54_rx_frame_sent(struct p54_common *priv, struct sk_buff =
*skb)
 {
-	struct p54_hdr *hdr =3D (struct p54_hdr *) skb->data;
-	struct p54_frame_sent *payload =3D (struct p54_frame_sent *) hdr->dat=
a;
+	const struct p54_hdr *hdr =3D (void *)skb->data;
+	const struct p54_frame_sent *payload =3D (void *)hdr->data;
 	struct ieee80211_tx_info *info;
 	struct p54_hdr *entry_hdr;
 	struct p54_tx_data *entry_data;
@@ -481,8 +481,8 @@ static void p54_rx_frame_sent(struct p54_common *pr=
iv, struct sk_buff *skb)
 static void p54_rx_eeprom_readback(struct p54_common *priv,
 				   struct sk_buff *skb)
 {
-	struct p54_hdr *hdr =3D (struct p54_hdr *) skb->data;
-	struct p54_eeprom_lm86 *eeprom =3D (struct p54_eeprom_lm86 *) hdr->da=
ta;
+	const struct p54_hdr *hdr =3D (void *)skb->data;
+	const struct p54_eeprom_lm86 *eeprom =3D (void *)hdr->data;
 	struct sk_buff *tmp;
=20
 	if (!priv->eeprom)
@@ -504,8 +504,8 @@ static void p54_rx_eeprom_readback(struct p54_commo=
n *priv,
=20
 static void p54_rx_stats(struct p54_common *priv, struct sk_buff *skb)
 {
-	struct p54_hdr *hdr =3D (struct p54_hdr *) skb->data;
-	struct p54_statistics *stats =3D (struct p54_statistics *) hdr->data;
+	const struct p54_hdr *hdr =3D (void *)skb->data;
+	const struct p54_statistics *stats =3D (void *)hdr->data;
 	struct sk_buff *tmp;
 	u32 tsf32;
=20
@@ -529,8 +529,8 @@ static void p54_rx_stats(struct p54_common *priv, s=
truct sk_buff *skb)
=20
 static void p54_rx_trap(struct p54_common *priv, struct sk_buff *skb)
 {
-	struct p54_hdr *hdr =3D (struct p54_hdr *) skb->data;
-	struct p54_trap *trap =3D (struct p54_trap *) hdr->data;
+	const struct p54_hdr *hdr =3D (void *)skb->data;
+	const struct p54_trap *trap =3D (void *)hdr->data;
 	u16 event =3D le16_to_cpu(trap->event);
 	u16 freq =3D le16_to_cpu(trap->frequency);
=20
@@ -565,7 +565,7 @@ static void p54_rx_trap(struct p54_common *priv, st=
ruct sk_buff *skb)
=20
 static int p54_rx_control(struct p54_common *priv, struct sk_buff *skb=
)
 {
-	struct p54_hdr *hdr =3D (struct p54_hdr *) skb->data;
+	const struct p54_hdr *hdr =3D (void *)skb->data;
=20
 	switch (le16_to_cpu(hdr->type)) {
 	case P54_CONTROL_TYPE_TXDONE:
@@ -595,7 +595,7 @@ static int p54_rx_control(struct p54_common *priv, =
struct sk_buff *skb)
 int p54_rx(struct ieee80211_hw *dev, struct sk_buff *skb)
 {
 	struct p54_common *priv =3D dev->priv;
-	u16 type =3D le16_to_cpu(*((__le16 *)skb->data));
+	u16 type =3D le16_to_cpu(*(const __le16 *)skb->data);
=20
 	if (type & P54_HDR_FLAG_CONTROL)
 		return p54_rx_control(priv, skb);
--=20
1.7.5.4

