From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH net] dm9000: Return an ERR_PTR() in all error conditions of dm9000_parse_dt()
Date: Fri, 19 Sep 2014 16:16:25 +0200
Message-ID: <1411136185-28658-1-git-send-email-tklauser@distanz.ch>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:51056 "EHLO mail.zhinst.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755848AbaISOQd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Sep 2014 10:16:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In one error condition dm9000_parse_dt() returns NULL, however the
return value is checked using IS_ERR() in dm9000_probe(), leading to the
error not being properly propagated if CONFIG_OF is not enabled or the
device tree data is not available. Fix this by also returning an
ERR_PTR() in this case.

Fixes: 0b8bf1baabe5 (net: dm9000: Allow instantiation using device tree)
Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/ethernet/davicom/dm9000.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethernet/davicom/dm9000.c
index 9b33057..70089c2 100644
--- a/drivers/net/ethernet/davicom/dm9000.c
+++ b/drivers/net/ethernet/davicom/dm9000.c
@@ -1399,7 +1399,7 @@ static struct dm9000_plat_data *dm9000_parse_dt(struct device *dev)
 	const void *mac_addr;
 
 	if (!IS_ENABLED(CONFIG_OF) || !np)
-		return NULL;
+		return ERR_PTR(-ENXIO);
 
 	pdata = devm_kzalloc(dev, sizeof(*pdata), GFP_KERNEL);
 	if (!pdata)
-- 
2.0.1
