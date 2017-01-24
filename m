From: Tobias Regnery <tobias.regnery@gmail.com>
Subject: [PATCH net 2/3] alx: fix fallback to msi or legacy interrupts
Date: Tue, 24 Jan 2017 14:34:23 +0100
Message-ID: <a39a76fd6f467732c7fc06cb72c7cc7f6561adfa.1485263833.git.tobias.regnery@gmail.com>
References: <cover.1485263833.git.tobias.regnery@gmail.com>
Cc: davem@davemloft.net, Tobias Regnery <tobias.regnery@gmail.com>
To: netdev@vger.kernel.org, jcliburn@gmail.com, chris.snook@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36314 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751027AbdAXNew (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 08:34:52 -0500
Received: by mail-wm0-f68.google.com with SMTP id r126so34734309wmr.3
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 05:34:51 -0800 (PST)
In-Reply-To: <cover.1485263833.git.tobias.regnery@gmail.com>
In-Reply-To: <cover.1485263833.git.tobias.regnery@gmail.com>
References: <cover.1485263833.git.tobias.regnery@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If requesting msi-x interrupts fails we should fall back to msi or
legacy interrupts. However alx_realloc_ressources don't call
alx_init_intr, so we fail to set the right number of tx queues.
This results in watchdog timeouts and a nonfunctional adapter.

Fixes: d768319cd427 ("alx: enable multiple tx queues")
Signed-off-by: Tobias Regnery <tobias.regnery@gmail.com>
---
 drivers/net/ethernet/atheros/alx/main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/atheros/alx/main.c b/drivers/net/ethernet/atheros/alx/main.c
index 765306bd78c2..75cbd46e429d 100644
--- a/drivers/net/ethernet/atheros/alx/main.c
+++ b/drivers/net/ethernet/atheros/alx/main.c
@@ -984,6 +984,7 @@ static int alx_realloc_resources(struct alx_priv *alx)
 	alx_free_rings(alx);
 	alx_free_napis(alx);
 	alx_disable_advanced_intr(alx);
+	alx_init_intr(alx, false);
 
 	err = alx_alloc_napis(alx);
 	if (err)
-- 
2.9.3
