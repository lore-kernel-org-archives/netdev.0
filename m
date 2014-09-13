From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 4/4 linux-next] brcm80211: use container_of to resolve dma_info from dma_pub
Date: Sat, 13 Sep 2014 22:38:29 +0200
Message-ID: <1410640709-18295-5-git-send-email-fabf@skynet.be>
References: <1410640709-18295-1-git-send-email-fabf@skynet.be>
Cc: davem@davemloft.net, Fabian Frederick <fabf@skynet.be>,
	Brett Rudley <brudley@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, brcm80211-dev-list@broadcom.com,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay011.isp.belgacom.be ([195.238.6.178]:46062 "EHLO
	mailrelay011.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752368AbaIMUjt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Sep 2014 16:39:49 -0400
In-Reply-To: <1410640709-18295-1-git-send-email-fabf@skynet.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use container_of instead of casting first structure member.

Compiled but untested.

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 drivers/net/wireless/brcm80211/brcmsmac/dma.c | 38 +++++++++++++--------------
 1 file changed, 19 insertions(+), 19 deletions(-)

diff --git a/drivers/net/wireless/brcm80211/brcmsmac/dma.c b/drivers/net/wireless/brcm80211/brcmsmac/dma.c
index 4fb9635..796f5f9 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/dma.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/dma.c
@@ -746,7 +746,7 @@ dma64_dd_upd(struct dma_info *di, struct dma64desc *ddring,
 /* !! may be called with core in reset */
 void dma_detach(struct dma_pub *pub)
 {
-	struct dma_info *di = (struct dma_info *)pub;
+	struct dma_info *di = container_of(pub, struct dma_info, dma);
 
 	brcms_dbg_dma(di->core, "%s:\n", di->name);
 
@@ -842,7 +842,7 @@ static void _dma_rxenable(struct dma_info *di)
 
 void dma_rxinit(struct dma_pub *pub)
 {
-	struct dma_info *di = (struct dma_info *)pub;
+	struct dma_info *di = container_of(pub, struct dma_info, dma);
 
 	brcms_dbg_dma(di->core, "%s:\n", di->name);
 
@@ -924,7 +924,7 @@ static struct sk_buff *_dma_getnextrxp(struct dma_info *di, bool forceall)
  */
 int dma_rx(struct dma_pub *pub, struct sk_buff_head *skb_list)
 {
-	struct dma_info *di = (struct dma_info *)pub;
+	struct dma_info *di = container_of(pub, struct dma_info, dma);
 	struct sk_buff_head dma_frames;
 	struct sk_buff *p, *next;
 	uint len;
@@ -1022,7 +1022,7 @@ static bool dma64_txidle(struct dma_info *di)
  */
 bool dma_rxfill(struct dma_pub *pub)
 {
-	struct dma_info *di = (struct dma_info *)pub;
+	struct dma_info *di = container_of(pub, struct dma_info, dma);
 	struct sk_buff *p;
 	u16 rxin, rxout;
 	u32 flags = 0;
@@ -1106,7 +1106,7 @@ bool dma_rxfill(struct dma_pub *pub)
 
 void dma_rxreclaim(struct dma_pub *pub)
 {
-	struct dma_info *di = (struct dma_info *)pub;
+	struct dma_info *di = container_of(pub, struct dma_info, dma);
 	struct sk_buff *p;
 
 	brcms_dbg_dma(di->core, "%s:\n", di->name);
@@ -1126,7 +1126,7 @@ void dma_counterreset(struct dma_pub *pub)
 /* get the address of the var in order to change later */
 unsigned long dma_getvar(struct dma_pub *pub, const char *name)
 {
-	struct dma_info *di = (struct dma_info *)pub;
+	struct dma_info *di = container_of(pub, struct dma_info, dma);
 
 	if (!strcmp(name, "&txavail"))
 		return (unsigned long)&(di->dma.txavail);
@@ -1137,7 +1137,7 @@ unsigned long dma_getvar(struct dma_pub *pub, const char *name)
 
 void dma_txinit(struct dma_pub *pub)
 {
-	struct dma_info *di = (struct dma_info *)pub;
+	struct dma_info *di = container_of(pub, struct dma_info, dma);
 	u32 control = D64_XC_XE;
 
 	brcms_dbg_dma(di->core, "%s:\n", di->name);
@@ -1170,7 +1170,7 @@ void dma_txinit(struct dma_pub *pub)
 
 void dma_txsuspend(struct dma_pub *pub)
 {
-	struct dma_info *di = (struct dma_info *)pub;
+	struct dma_info *di = container_of(pub, struct dma_info, dma);
 
 	brcms_dbg_dma(di->core, "%s:\n", di->name);
 
@@ -1182,7 +1182,7 @@ void dma_txsuspend(struct dma_pub *pub)
 
 void dma_txresume(struct dma_pub *pub)
 {
-	struct dma_info *di = (struct dma_info *)pub;
+	struct dma_info *di = container_of(pub, struct dma_info, dma);
 
 	brcms_dbg_dma(di->core, "%s:\n", di->name);
 
@@ -1194,7 +1194,7 @@ void dma_txresume(struct dma_pub *pub)
 
 bool dma_txsuspended(struct dma_pub *pub)
 {
-	struct dma_info *di = (struct dma_info *)pub;
+	struct dma_info *di = container_of(pub, struct dma_info, dma);
 
 	return (di->ntxd == 0) ||
 	       ((bcma_read32(di->core,
@@ -1204,7 +1204,7 @@ bool dma_txsuspended(struct dma_pub *pub)
 
 void dma_txreclaim(struct dma_pub *pub, enum txd_range range)
 {
-	struct dma_info *di = (struct dma_info *)pub;
+	struct dma_info *di = container_of(pub, struct dma_info, dma);
 	struct sk_buff *p;
 
 	brcms_dbg_dma(di->core, "%s: %s\n",
@@ -1225,7 +1225,7 @@ void dma_txreclaim(struct dma_pub *pub, enum txd_range range)
 
 bool dma_txreset(struct dma_pub *pub)
 {
-	struct dma_info *di = (struct dma_info *)pub;
+	struct dma_info *di = container_of(pub, struct dma_info, dma);
 	u32 status;
 
 	if (di->ntxd == 0)
@@ -1252,7 +1252,7 @@ bool dma_txreset(struct dma_pub *pub)
 
 bool dma_rxreset(struct dma_pub *pub)
 {
-	struct dma_info *di = (struct dma_info *)pub;
+	struct dma_info *di = container_of(pub, struct dma_info, dma);
 	u32 status;
 
 	if (di->nrxd == 0)
@@ -1377,7 +1377,7 @@ static void dma_update_txavail(struct dma_info *di)
 int dma_txfast(struct brcms_c_info *wlc, struct dma_pub *pub,
 	       struct sk_buff *p)
 {
-	struct dma_info *di = (struct dma_info *)pub;
+	struct dma_info *di = container_of(pub, struct dma_info, dma);
 	struct brcms_ampdu_session *session = &di->ampdu_session;
 	struct ieee80211_tx_info *tx_info;
 	bool is_ampdu;
@@ -1427,7 +1427,7 @@ int dma_txfast(struct brcms_c_info *wlc, struct dma_pub *pub,
 
 void dma_txflush(struct dma_pub *pub)
 {
-	struct dma_info *di = (struct dma_info *)pub;
+	struct dma_info *di = container_of(pub, struct dma_info, dma);
 	struct brcms_ampdu_session *session = &di->ampdu_session;
 
 	if (!skb_queue_empty(&session->skb_list))
@@ -1436,7 +1436,7 @@ void dma_txflush(struct dma_pub *pub)
 
 int dma_txpending(struct dma_pub *pub)
 {
-	struct dma_info *di = (struct dma_info *)pub;
+	struct dma_info *di = container_of(pub, struct dma_info, dma);
 	return ntxdactive(di, di->txin, di->txout);
 }
 
@@ -1446,7 +1446,7 @@ int dma_txpending(struct dma_pub *pub)
  */
 void dma_kick_tx(struct dma_pub *pub)
 {
-	struct dma_info *di = (struct dma_info *)pub;
+	struct dma_info *di = container_of(pub, struct dma_info, dma);
 	struct brcms_ampdu_session *session = &di->ampdu_session;
 
 	if (!skb_queue_empty(&session->skb_list) && dma64_txidle(di))
@@ -1465,7 +1465,7 @@ void dma_kick_tx(struct dma_pub *pub)
  */
 struct sk_buff *dma_getnexttxp(struct dma_pub *pub, enum txd_range range)
 {
-	struct dma_info *di = (struct dma_info *)pub;
+	struct dma_info *di = container_of(pub, struct dma_info, dma);
 	u16 start, end, i;
 	u16 active_desc;
 	struct sk_buff *txp;
@@ -1547,7 +1547,7 @@ struct sk_buff *dma_getnexttxp(struct dma_pub *pub, enum txd_range range)
 void dma_walk_packets(struct dma_pub *dmah, void (*callback_fnc)
 		      (void *pkt, void *arg_a), void *arg_a)
 {
-	struct dma_info *di = (struct dma_info *) dmah;
+	struct dma_info *di = container_of(dmah, struct dma_info, dma);
 	uint i =   di->txin;
 	uint end = di->txout;
 	struct sk_buff *skb;
-- 
1.8.4.5
