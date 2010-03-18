From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] netxen: The driver doesn't work on NX_P3_B1 so cause probe to fail.
Date: Thu, 18 Mar 2010 01:24:39 -0700
Message-ID: <m1y6hqdol4.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>,
	Amit Kumar Salecha <amit.salecha@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:59018 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751381Ab0CRIYo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Mar 2010 04:24:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I haven't been able to get link up on a NX_P3_B1 since 2.6.31.  The
driver complains about a firmware hang instead.  When I asked I was
told rev 0x41 was a preproduction rev.  So disable support in the
driver so no one is surprised the code doesn't work.

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---
 drivers/net/netxen/netxen_nic_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 08780ef..9a7a0f3 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -1246,8 +1246,8 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	int pci_func_id = PCI_FUNC(pdev->devfn);
 	uint8_t revision_id;
 
-	if (pdev->revision >= NX_P3_A0 && pdev->revision < NX_P3_B1) {
-		pr_warning("%s: chip revisions between 0x%x-0x%x"
+	if (pdev->revision >= NX_P3_A0 && pdev->revision <= NX_P3_B1) {
+		pr_warning("%s: chip revisions between 0x%x-0x%x "
 				"will not be enabled.\n",
 				module_name(THIS_MODULE), NX_P3_A0, NX_P3_B1);
 		return -ENODEV;
-- 
1.6.6.1

