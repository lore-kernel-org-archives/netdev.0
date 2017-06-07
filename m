From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH v2] net: mvpp2: do not bypass the mvpp22_port_mii_set function
Date: Wed,  7 Jun 2017 08:17:50 +0200
Message-ID: <20170607061750.28516-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        gregory.clement@free-electrons.com, mw@semihalf.com,
        linux@armlinux.org.uk, linux-arm-kernel@lists.infradead.org
To: davem@davemloft.net, netdev@vger.kernel.org,
        thomas.petazzoni@free-electrons.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:33206 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751207AbdFGGSD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2017 02:18:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mvpp22_port_mii_set() function was added by 2697582144dd, but the
function directly returns without doing anything. This return was used
when debugging and wasn't removed before sending the patch. Fix this.

Fixes: 2697582144dd ("net: mvpp2: handle misc PPv2.1/PPv2.2 differences")
Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
Acked-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---

Since v1:
  - Added the Fixes tag.
  - Added Thomas' Acked-by.

 drivers/net/ethernet/marvell/mvpp2.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 9b875d776b29..70bca2a6fb02 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -4186,8 +4186,6 @@ static void mvpp22_port_mii_set(struct mvpp2_port *port)
 {
 	u32 val;
 
-	return;
-
 	/* Only GOP port 0 has an XLG MAC */
 	if (port->gop_id == 0) {
 		val = readl(port->base + MVPP22_XLG_CTRL3_REG);
-- 
2.9.4
