From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH] net: brcm80211: Delete unnecessary checks before two function
 calls
Date: Wed, 04 Feb 2015 20:40:23 +0100
Message-ID: <54D275A7.3050701@users.sourceforge.net>
References: <5307CAA2.8060406@users.sourceforge.net> <alpine.DEB.2.02.1402212321410.2043@localhost6.localdomain6> <530A086E.8010901@users.sourceforge.net> <alpine.DEB.2.02.1402231635510.1985@localhost6.localdomain6> <530A72AA.3000601@users.sourceforge.net> <alpine.DEB.2.02.1402240658210.2090@localhost6.localdomain6> <530B5FB6.6010207@users.sourceforge.net> <alpine.DEB.2.10.1402241710370.2074@hadrien> <530C5E18.1020800@users.sourceforge.net> <alpine.DEB.2.10.1402251014170.2080@hadrien> <530CD2C4.4050903@users.sourceforge.net> <alpine.DEB.2.10.1402251840450.7035@hadrien> <530CF8FF.8080600@users.sourceforge.net> <alpine.DEB.2.02.1402252117150.2047@localhost6.localdomain6> <530DD06F.4090703@users.sourceforge.net> <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6> <5317A59D.4@users.so
 urceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>
To: Arend van Spriel <arend@broadcom.com>,
	Brett Rudley <brudley@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	brcm80211-dev-list@broadcom.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5317A59D.4@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Wed, 4 Feb 2015 20:28:49 +0100

The functions brcmu_pkt_buf_free_skb() and usb_free_urb() test whether
their argument is NULL and then return immediately. Thus the test around
the call is not needed.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/wireless/brcm80211/brcmfmac/sdio.c | 3 +--
 drivers/net/wireless/brcm80211/brcmfmac/usb.c  | 2 +-
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/brcm80211/brcmfmac/sdio.c b/drivers/net/wireless/brcm80211/brcmfmac/sdio.c
index 99a3776..5b5520b 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/sdio.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/sdio.c
@@ -2543,8 +2543,7 @@ static void brcmf_sdio_bus_stop(struct device *dev)
 	brcmu_pktq_flush(&bus->txq, true, NULL, NULL);
 
 	/* Clear any held glomming stuff */
-	if (bus->glomd)
-		brcmu_pkt_buf_free_skb(bus->glomd);
+	brcmu_pkt_buf_free_skb(bus->glomd);
 	brcmf_sdio_free_glom(bus);
 
 	/* Clear rx control and wake any waiters */
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/usb.c b/drivers/net/wireless/brcm80211/brcmfmac/usb.c
index 4572def..10c684c 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/usb.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/usb.c
@@ -421,7 +421,7 @@ fail:
 	brcmf_err("fail!\n");
 	while (!list_empty(q)) {
 		req = list_entry(q->next, struct brcmf_usbreq, list);
-		if (req && req->urb)
+		if (req)
 			usb_free_urb(req->urb);
 		list_del(q->next);
 	}
-- 
2.2.2
