From: Jeffy Chen <jeffy.chen@rock-chips.com>
Subject: [RFC PATCH v9 3/7] mwifiex: Disable wakeup irq handling for pcie
Date: Fri, 27 Oct 2017 15:17:35 +0800
Message-ID: <20171027071739.21927-4-jeffy.chen@rock-chips.com>
References: <20171027071739.21927-1-jeffy.chen@rock-chips.com>
Cc: linux-pm@vger.kernel.org, tony@atomide.com,
        shawn.lin@rock-chips.com, briannorris@chromium.org,
        rjw@rjwysocki.net, dianders@chromium.org,
        Jeffy Chen <jeffy.chen@rock-chips.com>,
        Xinming Hu <huxm@marvell.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Ganapathi Bhat <gbhat@marvell.com>,
        Amitkumar Karwar <amitkarwar@gmail.com>,
        linux-wireless@vger.kernel.org,
        Nishant Sarmukadam <nishants@marvell.com>,
        netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org, bhelgaas@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from regular1.263xmail.com ([211.150.99.136]:48804 "EHLO
        regular1.263xmail.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752114AbdJ0HTN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 03:19:13 -0400
In-Reply-To: <20171027071739.21927-1-jeffy.chen@rock-chips.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We are going to handle the wakeup irq in the pci core.

Signed-off-by: Jeffy Chen <jeffy.chen@rock-chips.com>
---

Changes in v9: None
Changes in v8: None
Changes in v7: None
Changes in v6: None
Changes in v5: None
Changes in v3: None
Changes in v2: None

 drivers/net/wireless/marvell/mwifiex/main.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/wireless/marvell/mwifiex/main.c b/drivers/net/wireless/marvell/mwifiex/main.c
index ee40b739b289..ba081c16f85c 100644
--- a/drivers/net/wireless/marvell/mwifiex/main.c
+++ b/drivers/net/wireless/marvell/mwifiex/main.c
@@ -1568,6 +1568,10 @@ static void mwifiex_probe_of(struct mwifiex_adapter *adapter)
 		goto err_exit;
 
 	adapter->dt_node = dev->of_node;
+
+	if (adapter->iface_type != MWIFIEX_PCIE)
+		goto err_exit;
+
 	adapter->irq_wakeup = irq_of_parse_and_map(adapter->dt_node, 0);
 	if (!adapter->irq_wakeup) {
 		dev_dbg(dev, "fail to parse irq_wakeup from device tree\n");
-- 
2.11.0
