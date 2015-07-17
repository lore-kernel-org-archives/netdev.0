From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH net] stmmac: fix setting of driver data in stmmac_dvr_probe
Date: Fri, 17 Jul 2015 23:48:17 +0200
Message-ID: <1437169697-20388-1-git-send-email-manabian@gmail.com>
Cc: netdev@vger.kernel.org, Joachim Eastwood <manabian@gmail.com>
To: davem@davemloft.net, peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f49.google.com ([209.85.215.49]:36169 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752007AbbGQVsk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2015 17:48:40 -0400
Received: by lagw2 with SMTP id w2so68019354lag.3
        for <netdev@vger.kernel.org>; Fri, 17 Jul 2015 14:48:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 803f8fc46274b ("stmmac: move driver data setting into
stmmac_dvr_probe") mistakenly set priv and not priv->dev as
driver data. This meant that the remove, resume and suspend
callbacks that fetched and tried to use this data would most
likely explode. Fix the issue by using the correct variable.

Fixes: 803f8fc46274b ("stmmac: move driver data setting into stmmac_dvr_probe")
Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
Hi,

I have no idea why I didn't notice (or anyone else for that
matter) this issue before now. Looking at 803f8fc46274b
it's pretty obvious and I should have spotted the mistake
when I sent the orignal patch. Anyway it's good to get this
fixed before 4.2 is released.

This should not conflict with any of the patches I sent for
net-next, btw.

 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 50f7a7a26821..864b476f7fd5 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2843,7 +2843,7 @@ int stmmac_dvr_probe(struct device *device,
 	if (res->mac)
 		memcpy(priv->dev->dev_addr, res->mac, ETH_ALEN);
 
-	dev_set_drvdata(device, priv);
+	dev_set_drvdata(device, priv->dev);
 
 	/* Verify driver arguments */
 	stmmac_verify_args();
-- 
1.8.0
