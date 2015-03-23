From: cliff_clark@selinc.com
Subject: [PATCH] ucc_geth: Intialize link state to down before register_netdev
Date: Mon, 23 Mar 2015 09:47:41 -0700
Message-ID: <OF3CCCBC69.C8C0BA7E-ON88257E11.005C1D2B-88257E11.005C420A@selinc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@vger.kernel.org
To: Li Yang <leoli@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from valiant.selinc.com ([74.117.214.141]:45556 "EHLO
	valiant.selinc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752285AbbCWR3f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 13:29:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ucc_geth was indicating link up after a port is administratively enabled 
even 
when nothing is plugged in.  This causes user-space tools to see a 
spurious link 
up the first time after boot.  
  
Signed-off-by: Cliff Clark <cliff_clark@selinc.com>
---
 drivers/net/ethernet/freescale/ucc_geth.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/freescale/ucc_geth.c 
b/drivers/net/ethernet/freescale/ucc_geth.c
index 357e8b57..56b774d 100644
--- a/drivers/net/ethernet/freescale/ucc_geth.c
+++ b/drivers/net/ethernet/freescale/ucc_geth.c
@@ -3893,6 +3893,9 @@ static int ucc_geth_probe(struct platform_device* 
ofdev)
        ugeth->phy_interface = phy_interface;
        ugeth->max_speed = max_speed;
 
+       /* Carrier starts down, phylib will bring it up */
+       netif_carrier_off(dev);
+
        err = register_netdev(dev);
        if (err) {
                if (netif_msg_probe(ugeth))
-- 
1.9.1
