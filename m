From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH] e1000e: fix warn_on reload after phy_id error
Date: Fri, 07 Nov 2008 16:27:39 -0800
Message-ID: <20081108002739.17508.60954.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.emeryville.ca.mail.comcast.net ([76.96.30.24]:41410 "EHLO
	QMTA02.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751353AbYKHA2K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2008 19:28:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the driver fails to initialize the first time due to the failure in the
phy_id check the kernel triggers a warn_on on the second try to load the
driver because the driver did not free the msi/x resources in the first
load because of the previous failure in phy_id check.
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

