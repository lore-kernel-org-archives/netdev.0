From: "Denis Kirjanov <kirjanov@gmail.com" <kirjanov@gmail.com>
Subject: [PATCH] bfin_mac: fix memleak in mii_bus{probe|remove}
Date: Tue, 18 May 2010 13:28:39 +0400
Message-ID: <20100518092839.GA21791@coldcone>
Reply-To: kirjanov@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: michael.hennerich@analog.com, sonic.zhang@analog.com,
	cooloney@kernel.org, uclinux-dist-devel@blackfin.uclinux.org,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:64886 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752762Ab0ERJ0s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 05:26:48 -0400
Received: by fxm10 with SMTP id 10so828939fxm.19
        for <netdev@vger.kernel.org>; Tue, 18 May 2010 02:26:46 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix memory leak with miibus->irq

Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>
---

drivers/net/bfin_mac.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index 39a54ba..7a17b8a 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -1627,6 +1627,7 @@ static int __devinit bfin_mii_bus_probe(struct platform_device *pdev)
 
 out_err_mdiobus_register:
 	mdiobus_free(miibus);
+	kfree(miibus->irq);
 out_err_alloc:
 	peripheral_free_list(pin_req);
 
@@ -1638,6 +1639,7 @@ static int __devexit bfin_mii_bus_remove(struct platform_device *pdev)
 	struct mii_bus *miibus = platform_get_drvdata(pdev);
 	platform_set_drvdata(pdev, NULL);
 	mdiobus_unregister(miibus);
+	kfree(miibus->irq);
 	mdiobus_free(miibus);
 	peripheral_free_list(pin_req);
 	return 0;
