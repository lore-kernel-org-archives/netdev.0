From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch 2.6.14-rc4] orinoco: remove redundance skb length check before padding
Date: Tue, 18 Oct 2005 21:30:58 -0400
Message-ID: <10182005213058.12015@bilbo.tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, proski@gnu.org, hermes@gibson.dropbear.id.au,
	orinoco-devel@lists.sourceforge.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932440AbVJSBgI@vger.kernel.org>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Checking the skb->len value before calling skb_padto is redundant.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---

 drivers/net/wireless/orinoco.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wireless/orinoco.c b/drivers/net/wireless/orinoco.c
--- a/drivers/net/wireless/orinoco.c
+++ b/drivers/net/wireless/orinoco.c
@@ -505,11 +505,9 @@ static int orinoco_xmit(struct sk_buff *
 
 	/* Check packet length, pad short packets, round up odd length */
 	len = max_t(int, ALIGN(skb->len, 2), ETH_ZLEN);
-	if (skb->len < len) {
-		skb = skb_padto(skb, len);
-		if (skb == NULL)
-			goto fail;
-	}
+	skb = skb_padto(skb, len);
+	if (skb == NULL)
+		goto fail;
 	len -= ETH_HLEN;
 
 	eh = (struct ethhdr *)skb->data;
