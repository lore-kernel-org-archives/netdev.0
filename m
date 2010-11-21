From: Joe Perches <joe@perches.com>
Subject: [PATCH 57/62] libertas: Use static const
Date: Sat, 20 Nov 2010 18:38:58 -0800
Message-ID: <0faf86e7288c88cc96902b01bfd06ef81d399e65.1290305776.git.joe@perches.com>
References: <cover.1290305773.git.joe@perches.com>
Cc: "John W. Linville" <linville@tuxdriver.com>,
	libertas-dev@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Dan Williams <dcbw@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1290305773.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using static const generally increases object text and decreases data size.
It also generally decreases overall object size.

   text	   data	    bss	    dec	    hex	filename
   3650	     56	    704	   4410	   113a	drivers/net/wireless/libertas/rx.o.new
   3695	     56	    704	   4455	   1167	drivers/net/wireless/libertas/rx.o.old
  27328	    964	   5240	  33532	   82fc	drivers/net/wireless/libertas/cfg.o.new
  27328	    964	   5240	  33532	   82fc	drivers/net/wireless/libertas/cfg.o.old

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/libertas/cfg.c |    2 +-
 drivers/net/wireless/libertas/rx.c  |    4 +++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/libertas/cfg.c b/drivers/net/wireless/libertas/cfg.c
index 373930a..3f21fcb 100644
--- a/drivers/net/wireless/libertas/cfg.c
+++ b/drivers/net/wireless/libertas/cfg.c
@@ -2062,7 +2062,7 @@ static void lbs_cfg_set_regulatory_hint(struct lbs_private *priv)
 	};
 
 	/* Section 5.17.2 */
-	static struct region_code_mapping regmap[] = {
+	static const struct region_code_mapping regmap[] = {
 		{"US ", 0x10}, /* US FCC */
 		{"CA ", 0x20}, /* Canada */
 		{"EU ", 0x30}, /* ETSI   */
diff --git a/drivers/net/wireless/libertas/rx.c b/drivers/net/wireless/libertas/rx.c
index a4d0bca..a2b1df2 100644
--- a/drivers/net/wireless/libertas/rx.c
+++ b/drivers/net/wireless/libertas/rx.c
@@ -55,7 +55,9 @@ int lbs_process_rxed_packet(struct lbs_private *priv, struct sk_buff *skb)
 	struct rxpd *p_rx_pd;
 	int hdrchop;
 	struct ethhdr *p_ethhdr;
-	const u8 rfc1042_eth_hdr[] = { 0xaa, 0xaa, 0x03, 0x00, 0x00, 0x00 };
+	static const u8 rfc1042_eth_hdr[] = {
+		0xaa, 0xaa, 0x03, 0x00, 0x00, 0x00
+	};
 
 	lbs_deb_enter(LBS_DEB_RX);
 
-- 
1.7.3.2.245.g03276.dirty
