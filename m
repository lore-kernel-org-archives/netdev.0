From: Peter Senna Tschudin <peter.senna@gmail.com>
Subject: [PATCH 19/20] drivers/net/ethernet/marvell/skge.c: fix error return code
Date: Wed,  3 Oct 2012 18:18:10 +0200
Message-ID: <1349281090-10013-20-git-send-email-peter.senna@gmail.com>
Cc: kernel-janitors@vger.kernel.org, shemminger@vyatta.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: mlindner@marvell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:43600 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965090Ab2JCQSh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2012 12:18:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Senna Tschudin <peter.senna@gmail.com>

Convert a nonnegative error return code to a negative one, as returned
elsewhere in the function.

A simplified version of the semantic match that finds this problem is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
(
if@p1 (\(ret < 0\|ret != 0\))
 { ... return ret; }
|
ret@p1 = 0
)
... when != ret = e1
    when != &ret
*if(...)
{
  ... when != ret = e2
      when forall
 return ret;
}
// </smpl>

Signed-off-by: Peter Senna Tschudin <peter.senna@gmail.com>

---
 drivers/net/ethernet/marvell/skge.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/skge.c b/drivers/net/ethernet/marvell/skge.c
index 5a30bf8..91836b5 100644
--- a/drivers/net/ethernet/marvell/skge.c
+++ b/drivers/net/ethernet/marvell/skge.c
@@ -3945,8 +3945,10 @@ static int __devinit skge_probe(struct pci_dev *pdev,
 		skge_board_name(hw), hw->chip_rev);
 
 	dev = skge_devinit(hw, 0, using_dac);
-	if (!dev)
+	if (!dev) {
+		err = -ENOMEM;
 		goto err_out_led_off;
+	}
 
 	/* Some motherboards are broken and has zero in ROM. */
 	if (!is_valid_ether_addr(dev->dev_addr))
