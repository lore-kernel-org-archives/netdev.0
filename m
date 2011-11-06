From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH] rtl8192e: Don't copy huge struct by value (and make it
 const).
Date: Mon, 7 Nov 2011 00:21:26 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1111070017220.5763@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrea Merello <andreamrl@tiscali.it>,
	Mike McCormack <mikem@ring3k.org>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Greg Kroah-Hartman <gregkh@suse.de>, netdev@vger.kernel.org
To: devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

rtllib_is_shortslot() takes one argument - a struct that's more than a
kilobyte large. It should take a pointer instead of copying such a
huge struct - and the argument might as well be declared 'const' now
that we are at it, since it is not modified. This patch makes these
changes.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 drivers/staging/rtl8192e/rtllib.h         |    2 +-
 drivers/staging/rtl8192e/rtllib_softmac.c |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/staging/rtl8192e/rtllib.h b/drivers/staging/rtl8192e/rtllib.h
index de25975..3a52120 100644
--- a/drivers/staging/rtl8192e/rtllib.h
+++ b/drivers/staging/rtl8192e/rtllib.h
@@ -2804,7 +2804,7 @@ extern int rtllib_wx_set_gen_ie(struct rtllib_device *ieee, u8 *ie, size_t len);
 
 /* rtllib_softmac.c */
 extern short rtllib_is_54g(struct rtllib_network *net);
-extern short rtllib_is_shortslot(struct rtllib_network net);
+extern short rtllib_is_shortslot(const struct rtllib_network *net);
 extern int rtllib_rx_frame_softmac(struct rtllib_device *ieee,
 				   struct sk_buff *skb,
 				   struct rtllib_rx_stats *rx_stats, u16 type,
diff --git a/drivers/staging/rtl8192e/rtllib_softmac.c b/drivers/staging/rtl8192e/rtllib_softmac.c
index b508685..fa774cf 100644
--- a/drivers/staging/rtl8192e/rtllib_softmac.c
+++ b/drivers/staging/rtl8192e/rtllib_softmac.c
@@ -28,9 +28,9 @@ short rtllib_is_54g(struct rtllib_network *net)
 	return (net->rates_ex_len > 0) || (net->rates_len > 4);
 }
 
-short rtllib_is_shortslot(struct rtllib_network net)
+short rtllib_is_shortslot(const struct rtllib_network *net)
 {
-	return net.capability & WLAN_CAPABILITY_SHORT_SLOT_TIME;
+	return net->capability & WLAN_CAPABILITY_SHORT_SLOT_TIME;
 }
 
 /* returns the total length needed for pleacing the RATE MFIE
-- 
1.7.7.2


-- 
Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.
