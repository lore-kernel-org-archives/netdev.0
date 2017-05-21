From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 01/10] qede: Allow WoL to activate by default
Date: Sun, 21 May 2017 12:10:52 +0300
Message-ID: <1495357860-28280-2-git-send-email-Yuval.Mintz@cavium.com>
References: <1495357860-28280-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0059.outbound.protection.outlook.com ([104.47.42.59]:29376
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752421AbdEUJLS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 21 May 2017 05:11:18 -0400
In-Reply-To: <1495357860-28280-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When management firmware declares that the device is WoL-capable,
the default driver behavior would be to allow the management firmware
to take the decision of whether it's actually needed or not.

Problem is ethtool interface doesn't have a 'default' kind
of option, and user would see the interface WoL as disabled,
which doesn't accurately reflect the actual configuration.
More-so, if the user actually wants to explicitly disable WoL he'd have
to first enable it [otherwise ethtool would block the command].

Instead of allowing management to make the decision, enable WoL by
default on all devices capable of it.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qede/qede_main.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index 38b77bb..4a46052 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -618,6 +618,12 @@ static struct qede_dev *qede_alloc_etherdev(struct qed_dev *cdev,
 	memset(&edev->stats, 0, sizeof(edev->stats));
 	memcpy(&edev->dev_info, info, sizeof(*info));
 
+	/* As ethtool doesn't have the ability to show WoL behavior as
+	 * 'default', if device supports it declare it's enabled.
+	 */
+	if (edev->dev_info.common.wol_support)
+		edev->wol_enabled = true;
+
 	INIT_LIST_HEAD(&edev->vlan_list);
 
 	return edev;
-- 
1.9.3
