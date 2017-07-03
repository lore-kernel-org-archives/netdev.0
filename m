From: Jeffy Chen <jeffy.chen@rock-chips.com>
Subject: [PATCH] mwifiex: uninit wakeup info when failed to add card
Date: Mon,  3 Jul 2017 15:54:30 +0800
Message-ID: <1499068470-8022-1-git-send-email-jeffy.chen@rock-chips.com>
Cc: briannorris@google.com, Jeffy Chen <jeffy.chen@rock-chips.com>,
        Xinming Hu <huxm@marvell.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Ganapathi Bhat <gbhat@marvell.com>,
        Amitkumar Karwar <amitkarwar@gmail.com>,
        linux-kernel@vger.kernel.org,
        Nishant Sarmukadam <nishants@marvell.com>,
        netdev@vger.kernel.org
To: linux-wireless@vger.kernel.org, akarwar@marvell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from regular1.263xmail.com ([211.150.99.132]:33907 "EHLO
        regular1.263xmail.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750980AbdGCHys (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Jul 2017 03:54:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We inited wakeup info at the beginning of mwifiex_add_card, so we need
to uninit it in the error handling.

It's much the same as what we did in:
36908c4 mwifiex: uninit wakeup info when removing device

Signed-off-by: Jeffy Chen <jeffy.chen@rock-chips.com>

---

 drivers/net/wireless/marvell/mwifiex/main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/wireless/marvell/mwifiex/main.c b/drivers/net/wireless/marvell/mwifiex/main.c
index f2600b8..17d2cbe 100644
--- a/drivers/net/wireless/marvell/mwifiex/main.c
+++ b/drivers/net/wireless/marvell/mwifiex/main.c
@@ -1655,6 +1655,8 @@ mwifiex_add_card(void *card, struct completion *fw_done,
 		mwifiex_shutdown_drv(adapter);
 	}
 err_kmalloc:
+	if (adapter->irq_wakeup >= 0)
+		device_init_wakeup(adapter->dev, false);
 	mwifiex_free_adapter(adapter);
 
 err_init_sw:
-- 
2.1.4
