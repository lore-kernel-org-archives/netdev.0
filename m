From: Chris Wright <chrisw@sous-sol.org>
Subject: [patch 61/69] skge: crash on shutdown/suspend
Date: Mon, 21 May 2007 12:17:13 -0700
Message-ID: <20070521191753.807353000@sous-sol.org>
References: <20070521191612.800400000@sous-sol.org>
Cc: Justin Forbes <jmforbes@linuxtx.org>,
	Zwane Mwaikambo <zwane@arm.linux.org.uk>,
	"Theodore Ts'o" <tytso@mit.edu>,
	Randy Dunlap <rdunlap@xenotime.net>,
	Dave Jones <davej@redhat.com>,
	Chuck Wolber <chuckw@quantumlinux.com>,
	Chris Wedgwood <reviews@ml.cw.f00f.org>,
	Michael Krufky <mkrufky@linuxtv.org>,
	Chuck Ebbert <cebbert@redhat.com>,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	alan@lxorguk.ukuu.org.uk,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org, stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 216-99-217-87.dsl.aracnet.com ([216.99.217.87]:46481 "EHLO
	sous-sol.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765475AbXEUTWH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 May 2007 15:22:07 -0400
Content-Disposition: inline; filename=skge-shutdown.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-stable review patch.  If anyone has any objections, please let us know.
---------------------

From: Stephen Hemminger <shemminger@linux-foundation.org>

If device fails during module startup for some reason (like unsupported chip
version) then driver would crash dereferencing a null pointer, on shutdown
or suspend/resume.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
Signed-off-by: Chris Wright <chrisw@sous-sol.org>

---
 drivers/net/skge.c |    9 +++++++++
 1 file changed, 9 insertions(+)

--- linux-2.6.21.1.orig/drivers/net/skge.c
+++ linux-2.6.21.1/drivers/net/skge.c
@@ -3794,6 +3794,9 @@ static int skge_suspend(struct pci_dev *
 	struct skge_hw *hw  = pci_get_drvdata(pdev);
 	int i, err, wol = 0;
 
+	if (!hw)
+		return 0;
+
 	err = pci_save_state(pdev);
 	if (err)
 		return err;
@@ -3822,6 +3825,9 @@ static int skge_resume(struct pci_dev *p
 	struct skge_hw *hw  = pci_get_drvdata(pdev);
 	int i, err;
 
+	if (!hw)
+		return 0;
+
 	err = pci_set_power_state(pdev, PCI_D0);
 	if (err)
 		goto out;
@@ -3860,6 +3866,9 @@ static void skge_shutdown(struct pci_dev
 	struct skge_hw *hw  = pci_get_drvdata(pdev);
 	int i, wol = 0;
 
+	if (!hw)
+		return;
+
 	for (i = 0; i < hw->ports; i++) {
 		struct net_device *dev = hw->dev[i];
 		struct skge_port *skge = netdev_priv(dev);

-- 
