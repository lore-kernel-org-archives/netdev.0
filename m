From: "Michael Chan" <mchan@broadcom.com>
Subject: [TG3 1/8]: Save MSI state before suspend.
Date: Tue, 13 Feb 2007 12:13:32 -0800
Message-ID: <1171397612.18944.25.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3394 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751775AbXBMTaG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Feb 2007 14:30:06 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TG3]: Save MSI state before suspend.

This fixes the following problem:

http://bugzilla.kernel.org/show_bug.cgi?id=7969

The MSI state needs to be saved during suspend.  PCI state saved
during tg3_init_one() does not contain valid MSI state because
MSI hasn't been enabled.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index e136bae..0b5b8e7 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -12016,6 +12016,9 @@ static int tg3_suspend(struct pci_dev *p
 	tp->tg3_flags &= ~TG3_FLAG_INIT_COMPLETE;
 	tg3_full_unlock(tp);
 
+	/* Save MSI address and data for resume.  */
+	pci_save_state(pdev);
+
 	err = tg3_set_power_state(tp, pci_choose_state(pdev, state));
 	if (err) {
 		tg3_full_lock(tp, 0);


