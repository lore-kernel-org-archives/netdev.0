From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH] net: Fix ucc_geth.c handling of phy 'interface' property.
Date: Mon, 27 Apr 2009 09:36:13 -0600
Message-ID: <20090427153612.5108.10877.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>,
	Andy Fleming <afleming@freescale.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	David Miller <davem@davemloft.net>, linuxpp
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.227]:63049 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752906AbZD0PgQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2009 11:36:16 -0400
Received: by rv-out-0506.google.com with SMTP id f9so1856328rvb.1
        for <netdev@vger.kernel.org>; Mon, 27 Apr 2009 08:36:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Grant Likely <grant.likely@secretlab.ca>

Previous rework to ucc_geth.c to add of_mdio support (net: Rework
ucc_geth driver to use of_mdio infrastructure) added a block of
code which broke older openfirmware device trees which use an
'interface' property in the phy node to describe the connection
between the MAC and the PHY.  This patch removes the offending blurb.

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---

 drivers/net/ucc_geth.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)


diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 195b490..d805d60 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3639,9 +3639,6 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 	prop = of_get_property(np, "phy-connection-type", NULL);
 	if (!prop) {
 		/* handle interface property present in old trees */
-		if (!phy)
-			return -ENODEV;
-
 		prop = of_get_property(phy, "interface", NULL);
 		if (prop != NULL) {
 			phy_interface = enet_to_phy_interface[*prop];

