From: Jeffy Chen <jeffy.chen@rock-chips.com>
Subject: [PATCH 3/3] mwifiex: wake system up when receives a wake irq
Date: Fri, 24 Feb 2017 14:24:31 +0800
Message-ID: <1487917471-5501-3-git-send-email-jeffy.chen@rock-chips.com>
References: <1487917471-5501-1-git-send-email-jeffy.chen@rock-chips.com>
Cc: Brian Norris <briannorris@chromium.org>,
        Rajat Jain <rajatja@google.com>,
        Jeffy Chen <jeffy.chen@rock-chips.com>,
        Kalle Valo <kvalo@codeaurora.org>, netdev@vger.kernel.org,
        linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
        Nishant Sarmukadam <nishants@marvell.com>
To: Amitkumar Karwar <akarwar@marvell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from regular1.263xmail.com ([211.150.99.134]:50701 "EHLO
        regular1.263xmail.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750873AbdBXGYx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Feb 2017 01:24:53 -0500
In-Reply-To: <1487917471-5501-1-git-send-email-jeffy.chen@rock-chips.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currrently we are disabling this wake irq after receiving it. If this
happens before we finish suspend and the pm event check is disabled,
the system will continue suspending, and this irq would not work again.

We may need to abort system suspend to avoid that.

Signed-off-by: Jeffy Chen <jeffy.chen@rock-chips.com>
---

 drivers/net/wireless/marvell/mwifiex/main.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/wireless/marvell/mwifiex/main.c b/drivers/net/wireless/marvell/mwifiex/main.c
index 5ebca1d..30f4994 100644
--- a/drivers/net/wireless/marvell/mwifiex/main.c
+++ b/drivers/net/wireless/marvell/mwifiex/main.c
@@ -17,6 +17,8 @@
  * this warranty disclaimer.
  */
 
+#include <linux/suspend.h>
+
 #include "main.h"
 #include "wmm.h"
 #include "cfg80211.h"
@@ -1509,6 +1511,7 @@ static irqreturn_t mwifiex_irq_wakeup_handler(int irq, void *priv)
 
 	/* Notify PM core we are wakeup source */
 	pm_wakeup_event(adapter->dev, 0);
+	pm_system_wakeup();
 
 	return IRQ_HANDLED;
 }
-- 
2.1.4
