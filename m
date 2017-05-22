From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 2/2] ieee802154: ca8210: Delete an error message for a failed
 memory allocation in ca8210_skb_rx()
Date: Mon, 22 May 2017 08:14:38 +0200
Message-ID: <a0c71307-4777-fd52-9f4c-cafd0f4d43a0@users.sourceforge.net>
References: <55fddbc7-28c4-8866-67d3-ff1ff1a4eeb7@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: linuxdev@cascoda.com, linux-wpan@vger.kernel.org,
        netdev@vger.kernel.org, Alexander Aring <aar@pengutronix.de>,
        Harry Morris <h.morris@cascoda.com>,
        Stefan Schmidt <stefan@osg.samsung.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <55fddbc7-28c4-8866-67d3-ff1ff1a4eeb7@users.sourceforge.net>
Content-Language: en-GB
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Mon, 22 May 2017 08:03:17 +0200

Omit an extra message for a memory allocation failure in this function.

This issue was detected by using the Coccinelle software.

Link: http://events.linuxfoundation.org/sites/events/files/slides/LCJ16-Refactor_Strings-WSang_0.pdf
Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/ieee802154/ca8210.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ieee802154/ca8210.c b/drivers/net/ieee802154/ca8210.c
index 25ed11bb5ed3..f6df75e80a60 100644
--- a/drivers/net/ieee802154/ca8210.c
+++ b/drivers/net/ieee802154/ca8210.c
@@ -1808,10 +1808,9 @@ static int ca8210_skb_rx(
 
 	/* Allocate mtu size buffer for every rx packet */
 	skb = dev_alloc_skb(IEEE802154_MTU + sizeof(hdr));
-	if (!skb) {
-		dev_crit(&priv->spi->dev, "dev_alloc_skb failed\n");
+	if (!skb)
 		return -ENOMEM;
-	}
+
 	skb_reserve(skb, sizeof(hdr));
 
 	msdulen = data_ind[22]; /* msdu_length */
-- 
2.13.0

