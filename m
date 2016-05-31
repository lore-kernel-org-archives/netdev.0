From: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Subject: [PATCH net-next v2] ravb: Add ESF in RCR for enabling separation filter
Date: Wed,  1 Jun 2016 03:01:28 +0900
Message-ID: <1464717688-28146-1-git-send-email-ykaneko0929@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>,
	linux-renesas-soc@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:35068 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755659AbcEaSBx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2016 14:01:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Masaru Nagai <masaru.nagai.vx@renesas.com>

The H/W manual recommends B'10 or B'11 in a value of the separation
filtering select bits in the receive configuration register (RCR.ESF).
When B'10 is set, frames from non-matching streams are discarded.
When B'11 is set, frames from non-matching streams are processed in
reception queue 0 (best effort).
This patch sets B'11 in ESF.

[ykaneko0929@gmail.com: revised this commit message]
Signed-off-by: Masaru Nagai <masaru.nagai.vx@renesas.com>
Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
---

This patch is based on the master branch of David Miller's next networking
tree.

v2 [Yoshihiro Kaneko]
  - Revised the commit message
  - Added Acked-by

 drivers/net/ethernet/renesas/ravb_main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
index 867caf6..1ceadbf 100644
--- a/drivers/net/ethernet/renesas/ravb_main.c
+++ b/drivers/net/ethernet/renesas/ravb_main.c
@@ -402,7 +402,8 @@ static int ravb_dmac_init(struct net_device *ndev)
 #endif
 
 	/* Set AVB RX */
-	ravb_write(ndev, RCR_EFFS | RCR_ENCF | RCR_ETS0 | 0x18000000, RCR);
+	ravb_write(ndev,
+		   RCR_EFFS | RCR_ENCF | RCR_ETS0 | RCR_ESF | 0x18000000, RCR);
 
 	/* Set FIFO size */
 	ravb_write(ndev, TGC_TQP_AVBMODE1 | 0x00222200, TGC);
-- 
1.9.1
