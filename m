From: Matthew Garrett <mjg@redhat.com>
Subject: [PATCH v2 1/2] e1000e: Only disable ASPM on 82573L devices
Date: Thu, 11 Feb 2010 11:29:26 -0500
Message-ID: <1265905767-3884-1-git-send-email-mjg@redhat.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Matthew Garrett <mjg@redhat.com>
To: e1000-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cavan.codon.org.uk ([93.93.128.6]:46201 "EHLO
	cavan.codon.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756374Ab0BKQ3f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2010 11:29:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 82537 errata and comment in e1000e_disable_l1aspm both agree that
only 82537L devices are affected. Limit the L1 disable to them.

Signed-off-by: Matthew Garrett <mjg@redhat.com>
---
 drivers/net/e1000e/netdev.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 57f149b..27eed81 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -4642,6 +4642,10 @@ static void e1000e_disable_l1aspm(struct pci_dev *pdev)
 	 * Unfortunately this feature saves about 1W power consumption when
 	 * active.
 	 */
+
+	if (pdev->device != E1000_DEV_ID_82573L)
+		return;
+
 	pos = pci_find_capability(pdev, PCI_CAP_ID_EXP);
 	pci_read_config_word(pdev, pos + PCI_EXP_LNKCTL, &val);
 	if (val & 0x2) {
-- 
1.6.6.1

