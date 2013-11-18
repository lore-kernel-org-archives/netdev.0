From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Subject: [PATCH] libertas sdio: claim device before calling sdio_disable_func()
Date: Tue, 19 Nov 2013 01:45:08 +0400
Message-ID: <1384811108-28807-1-git-send-email-khoroshilov@ispras.ru>
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>,
	libertas-dev@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ldv-project@linuxtesting.org
To: "John W. Linville" <linville@tuxdriver.com>,
	Dan Williams <dcbw@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is a failure path in if_sdio_power_on(), where
sdio_disable_func() is called without claiming the device.

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
---
 drivers/net/wireless/libertas/if_sdio.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/libertas/if_sdio.c b/drivers/net/wireless/libertas/if_sdio.c
index 991238afd1b6..19c4477eb4c6 100644
--- a/drivers/net/wireless/libertas/if_sdio.c
+++ b/drivers/net/wireless/libertas/if_sdio.c
@@ -907,8 +907,8 @@ static int if_sdio_power_on(struct if_sdio_card *card)
 	sdio_release_host(func);
 	ret = if_sdio_prog_firmware(card);
 	if (ret) {
-		sdio_disable_func(func);
-		return ret;
+		sdio_claim_host(func);
+		goto disable;
 	}
 
 	return 0;
-- 
1.8.1.2
