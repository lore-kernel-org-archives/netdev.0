From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] net: ethernet: nb8800: fix error return code in nb8800_open()
Date: Mon, 17 Oct 2016 15:31:58 +0000
Message-ID: <1476718318-28428-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, netdev@vger.kernel.org
To: jarod@redhat.com, sf84@laposte.net, peter.chen@nxp.com,
        mans@mansr.com, tremyfr@gmail.com, arnd@arndb.de,
        f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36699 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932625AbcJQPcI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 11:32:08 -0400
Received: by mail-pf0-f196.google.com with SMTP id r16so12995879pfg.3
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2016 08:32:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

Fix to return error code -ENODEV from the of_phy_connect() error
handling case instead of 0, as done elsewhere in this function.

Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 drivers/net/ethernet/aurora/nb8800.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/aurora/nb8800.c b/drivers/net/ethernet/aurora/nb8800.c
index 453dc09..99c4055 100644
--- a/drivers/net/ethernet/aurora/nb8800.c
+++ b/drivers/net/ethernet/aurora/nb8800.c
@@ -975,8 +975,10 @@ static int nb8800_open(struct net_device *dev)
 	phydev = of_phy_connect(dev, priv->phy_node,
 				nb8800_link_reconfigure, 0,
 				priv->phy_mode);
-	if (!phydev)
+	if (!phydev) {
+		err = -ENODEV;
 		goto err_free_irq;
+	}
 
 	nb8800_pause_adv(dev);
