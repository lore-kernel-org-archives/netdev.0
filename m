From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: [PATCH net v3 6/6] net: stmmac: squelch sparse warning with casts
Date: Tue, 29 Jul 2014 17:06:47 -0500
Message-ID: <1406671607-27368-7-git-send-email-vbridgers2013@gmail.com>
References: <1406671607-27368-1-git-send-email-vbridgers2013@gmail.com>
Cc: dinguyen@altera.com, davem@davemloft.net, vbridgers2013@gmail.com,
	vbridger@altera.com
To: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	peppe.cavallaro@st.com, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	linux@arm.linux.org.uk, linux-arm-kernel@lists.infradead.org,
	robh+dt@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:56215 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754302AbaG2WKp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2014 18:10:45 -0400
In-Reply-To: <1406671607-27368-1-git-send-email-vbridgers2013@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add casts to squelch the following sparse warnings so we can see
the ones that matter when they occur.

stmmac_platform.c:260:20: warning: incorrect type in argument 1
			  (different address spaces)
stmmac_platform.c:260:20:    expected void const *static extern
			  [signed] [long] [typedef] [tls] inline [safe] ptr
stmmac_platform.c:260:20:    got void [noderef] <asn:2>*[assigned] addr
stmmac_platform.c:261:32: warning: incorrect type in argument 1
			  (different address spaces)
stmmac_platform.c:261:32:    expected void const *static extern
			  [signed] [long] [typedef] [tls] inline [safe] ptr
stmmac_platform.c:261:32:    got void [noderef] <asn:2>*[assigned] addr

Signed-off-by: Vince Bridgers <vbridgers2013@gmail.com>
---
V3: Add minor sparse warning correction as part of series
V2: Not present in prior submissions
---
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index bb524a9..228003b 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -257,8 +257,8 @@ static int stmmac_pltfr_probe(struct platform_device *pdev)
 
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	addr = devm_ioremap_resource(dev, res);
-	if (IS_ERR(addr))
-		return PTR_ERR(addr);
+	if (IS_ERR((void __force *)addr))
+		return PTR_ERR((void __force *)addr);
 
 	plat_dat = dev_get_platdata(&pdev->dev);
 	if (pdev->dev.of_node) {
-- 
1.7.9.5
