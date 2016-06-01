From: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Subject: [PATCH net-next] ravb: Remove manual pause frame transmit
Date: Thu,  2 Jun 2016 01:41:05 +0900
Message-ID: <1464799265-27431-1-git-send-email-ykaneko0929@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>,
	linux-renesas-soc@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33959 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932337AbcFAQmA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 12:42:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Masaru Nagai <masaru.nagai.vx@renesas.com>

Writing a non-zero value to the manual PAUSE frame register (MPR) starts
the transmission of a PAUSE frame.
A PAUSE frame is sent in ravb_emac_init(), but it is not expected behavior.

Signed-off-by: Masaru Nagai <masaru.nagai.vx@renesas.com>
Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
---

This patch is based on the master branch of David Miller's next networking
tree.

 drivers/net/ethernet/renesas/ravb_main.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
index 867caf6..37dd068 100644
--- a/drivers/net/ethernet/renesas/ravb_main.c
+++ b/drivers/net/ethernet/renesas/ravb_main.c
@@ -362,8 +362,6 @@ static void ravb_emac_init(struct net_device *ndev)
 	ravb_write(ndev,
 		   (ndev->dev_addr[4] << 8)  | (ndev->dev_addr[5]), MALR);
 
-	ravb_write(ndev, 1, MPR);
-
 	/* E-MAC status register clear */
 	ravb_write(ndev, ECSR_ICD | ECSR_MPD, ECSR);
 
-- 
1.9.1
