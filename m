From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH] brcmfmac: drop unused fields from struct brcmf_pub
Date: Fri, 23 Sep 2016 15:27:46 +0200
Message-ID: <20160923132759.21875-1-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <rafal@milecki.pl>,
        Arend van Spriel <arend.vanspriel@broadcom.com>,
        Franky Lin <franky.lin@broadcom.com>,
        Hante Meuleman <hante.meuleman@broadcom.com>,
        Pieter-Paul Giesberts <pieter-paul.giesberts@broadcom.com>,
        "Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
        Colin Ian King <colin.king@canonical.com>,
        linux-wireless@vger.kernel.org (open list:BROADCOM BRCM80211
        IEEE802.11n WIRELESS DRIVER),
        brcm80211-dev-list.pdl@broadcom.com (open list:BROADCOM BRCM80211
        IEEE802.11n WIRELESS DRIVER),
        netdev@vger.kernel.org (open list:NETWORKING DRIVERS),
        linux-kernel@vger.kernel.org (open list)
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rafał Miłecki <rafal@milecki.pl>

They seem to be there from the first day. We calculate these values but
never use them.

Signed-off-by: Rafał Miłecki <rafal@milecki.pl>
---
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c     | 3 ---
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.h     | 4 ----
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/fwsignal.c | 2 --
 3 files changed, 9 deletions(-)

diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c
index 65e8c87..27cd50a 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c
@@ -519,9 +519,6 @@ int brcmf_net_attach(struct brcmf_if *ifp, bool rtnl_locked)
 	ndev->needed_headroom += drvr->hdrlen;
 	ndev->ethtool_ops = &brcmf_ethtool_ops;
 
-	drvr->rxsz = ndev->mtu + ndev->hard_header_len +
-			      drvr->hdrlen;
-
 	/* set the mac address */
 	memcpy(ndev->dev_addr, ifp->mac_addr, ETH_ALEN);
 
diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.h b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.h
index 8fa34ca..f16cfc9 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.h
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.h
@@ -112,15 +112,11 @@ struct brcmf_pub {
 
 	/* Internal brcmf items */
 	uint hdrlen;		/* Total BRCMF header length (proto + bus) */
-	uint rxsz;		/* Rx buffer size bus module should use */
 
 	/* Dongle media info */
 	char fwver[BRCMF_DRIVER_FIRMWARE_VERSION_LEN];
 	u8 mac[ETH_ALEN];		/* MAC address obtained from dongle */
 
-	/* Multicast data packets sent to dongle */
-	unsigned long tx_multicast;
-
 	struct mac_address addresses[BRCMF_MAX_IFS];
 
 	struct brcmf_if *iflist[BRCMF_MAX_IFS];
diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/fwsignal.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/fwsignal.c
index 9f9024a..a190f53 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/fwsignal.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/fwsignal.c
@@ -2104,8 +2104,6 @@ int brcmf_fws_process_skb(struct brcmf_if *ifp, struct sk_buff *skb)
 	if ((skb->priority == 0) || (skb->priority > 7))
 		skb->priority = cfg80211_classify8021d(skb, NULL);
 
-	drvr->tx_multicast += !!multicast;
-
 	if (fws->avoid_queueing) {
 		rc = brcmf_proto_txdata(drvr, ifp->ifidx, 0, skb);
 		if (rc < 0)
-- 
2.9.3
