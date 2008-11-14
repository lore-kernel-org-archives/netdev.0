From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 1/2] e1000e: fix warn_on reload after phy_id error
Date: Fri, 14 Nov 2008 08:45:07 -0800
Message-ID: <20081114164507.5342.19559.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.emeryville.ca.mail.comcast.net ([76.96.30.80]:60426 "EHLO
	QMTA08.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750918AbYKNQp0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2008 11:45:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the driver fails to initialize the first time due to the failure in the
phy_id check the kernel triggers a warn_on on the second try to load the
driver because the driver did not free the msi/x resources in the first
load because of the previous failure in phy_id check.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/netdev.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 2c8dffd..f6ebebb 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -5009,6 +5009,7 @@ err_hw_init:
 err_sw_init:
 	if (adapter->hw.flash_address)
 		iounmap(adapter->hw.flash_address);
+	e1000e_reset_interrupt_capability(adapter);
 err_flashmap:
 	iounmap(adapter->hw.hw_addr);
 err_ioremap:

