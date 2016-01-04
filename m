From: Jia-Ju Bai <baijiaju1990@163.com>
Subject: [PATCH] rt2x00pci: Disable memory-write-invalidate when the driver exits
Date: Mon,  4 Jan 2016 15:55:38 +0800
Message-ID: <1451894138-3482-1-git-send-email-baijiaju1990@163.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Jia-Ju Bai <baijiaju1990@163.com>
To: sgruszka@redhat.com, helmut.schaa@googlemail.com,
	kvalo@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-13.163.com ([220.181.12.13]:43980 "EHLO m12-13.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751941AbcADH4N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jan 2016 02:56:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver calls pci_set_mwi to enable memory-write-invalidate when it
is initialized, but does not call pci_clear_mwi when it is removed. Many
other drivers calls pci_clear_mwi when pci_set_mwi is called, such as
r8169, 8139cp and e1000.

This patch adds pci_clear_mwi in error handling and removal procedure, 
which can fix the problem.

Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>
---
 drivers/net/wireless/rt2x00/rt2x00pci.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/wireless/rt2x00/rt2x00pci.c b/drivers/net/wireless/rt2x00/rt2x00pci.c
index d93db4b..eb6dbcd 100644
--- a/drivers/net/wireless/rt2x00/rt2x00pci.c
+++ b/drivers/net/wireless/rt2x00/rt2x00pci.c
@@ -149,6 +149,7 @@ exit_free_device:
 	ieee80211_free_hw(hw);
 
 exit_release_regions:
+	pci_clear_mwi(pci_dev);
 	pci_release_regions(pci_dev);
 
 exit_disable_device:
@@ -173,6 +174,7 @@ void rt2x00pci_remove(struct pci_dev *pci_dev)
 	/*
 	 * Free the PCI device data.
 	 */
+	pci_clear_mwi(pci_dev);
 	pci_disable_device(pci_dev);
 	pci_release_regions(pci_dev);
 }
-- 
1.7.9.5
