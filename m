From: Simon Horman <horms+renesas@verge.net.au>
Subject: [PATCH net-next 3/3] net: sh_eth: implement R-Car Gen[12] fallback compatibility strings
Date: Tue, 17 Oct 2017 09:47:47 +0200
Message-ID: <20171017074747.24159-4-horms+renesas@verge.net.au>
References: <20171017074747.24159-1-horms+renesas@verge.net.au>
Cc: Magnus Damm <magnus.damm@gmail.com>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org,
        Simon Horman <horms+renesas@verge.net.au>
To: David Miller <davem@davemloft.net>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:41349 "EHLO
        kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754177AbdJQHsF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 03:48:05 -0400
In-Reply-To: <20171017074747.24159-1-horms+renesas@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement fallback compatibility strings for R-Car Gen 1 and 2.

In the case of Renesas R-Car hardware we know that there are generations of
SoCs, f.e. Gen 1 and 2. But beyond that its not clear what the relationship
between IP blocks might be. For example, I believe that r8a7790 is older
than r8a7791 but that doesn't imply that the latter is a descendant of the
former or vice versa.

We can, however, by examining the documentation and behaviour of the
hardware at run-time observe that the current driver implementation appears
to be compatible with the IP blocks on SoCs within a given generation.

For the above reasons and convenience when enabling new SoCs a
per-generation fallback compatibility string scheme being adopted for
drivers for Renesas SoCs.

Note that R-Car Gen2 and RZ/G1 have many compatible IP blocks.  The
approach that has been consistently taken for other IP blocks is to name
common code, compatibility strings and so on after Rcar Gen2.

Signed-off-by: Simon Horman <horms+renesas@verge.net.au>
---
 drivers/net/ethernet/renesas/sh_eth.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index c9f92fc8555e..7e060aa9fbed 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -3095,6 +3095,8 @@ static const struct of_device_id sh_eth_match_table[] = {
 	{ .compatible = "renesas,ether-r8a7793", .data = &rcar_gen2_data },
 	{ .compatible = "renesas,ether-r8a7794", .data = &rcar_gen2_data },
 	{ .compatible = "renesas,ether-r7s72100", .data = &r7s72100_data },
+	{ .compatible = "renesas,rcar-gen1-ether", .data = &rcar_gen1_data },
+	{ .compatible = "renesas,rcar-gen2-ether", .data = &rcar_gen2_data },
 	{ }
 };
 MODULE_DEVICE_TABLE(of, sh_eth_match_table);
-- 
2.11.0
