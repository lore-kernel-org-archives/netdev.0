From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: [PATCH] brcmfmac: avoid gcc-5.1 warning
Date: Tue, 12 May 2015 23:54:25 +0200
Message-ID: <2201884.BixNBcLJhn@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Pieter-Paul Giesberts <pieterpg-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, brcm80211-dev-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
	Brett Rudley <brudley-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Franky Lin <frankyl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Hante Meuleman <meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Arend Van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

gcc-5.0 gained a new warning in the fwsignal portion of the brcmfmac
driver:

drivers/net/wireless/brcm80211/brcmfmac/fwsignal.c: In function 'brcmf_fws_txs_process':
drivers/net/wireless/brcm80211/brcmfmac/fwsignal.c:1478:8: warning: 'skb' may be used uninitialized in this function [-Wmaybe-uninitialized]

This is a false positive, and marking the brcmf_fws_hanger_poppkt function
as 'static inline' makes the warning go away. I have checked the object
file output and while a little code gets moved around, the size of
the binary remains identical.

Signed-off-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
---
Found while building the ARM imx_v6_v7_defconfig configuration with gcc-5.
We try to get all ARM defconfigs to build without warnings normally.

diff --git a/drivers/net/wireless/brcm80211/brcmfmac/fwsignal.c b/drivers/net/wireless/brcm80211/brcmfmac/fwsignal.c
index f0dda0ecd23b..5017eaa4af45 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/fwsignal.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/fwsignal.c
@@ -635,7 +635,7 @@ static int brcmf_fws_hanger_pushpkt(struct brcmf_fws_hanger *h,
 	return 0;
 }
 
-static int brcmf_fws_hanger_poppkt(struct brcmf_fws_hanger *h,
+static inline int brcmf_fws_hanger_poppkt(struct brcmf_fws_hanger *h,
 					  u32 slot_id, struct sk_buff **pktout,
 					  bool remove_item)
 {

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
