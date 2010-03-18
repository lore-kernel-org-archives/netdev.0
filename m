From: Amit Salecha <amit.salecha@qlogic.com>
Subject: RE: [PATCH] netxen: The driver doesn't work on NX_P3_B1 so cause
 probe to fail.
Date: Thu, 18 Mar 2010 03:55:35 -0500
Message-ID: <99737F4847ED0A48AECC9F4A1974A4B80CFEFED04B@MNEXMB2.qlogic.org>
References: <m1y6hqdol4.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ameen Rahman <ameen.rahman@qlogic.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:18002 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751385Ab0CRIzk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Mar 2010 04:55:40 -0400
In-Reply-To: <m1y6hqdol4.fsf@fess.ebiederm.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry for all the problem you faced.

But you shouldn't add support of device which is not supported.
Netxen is now owned by Qlogic. You should first contact Qlogic to solve your problem.
Qlogic will take needed action based on problem.

Please write to me, with detail problem description.

-----Original Message-----
From: Eric W. Biederman [mailto:ebiederm@xmission.com] 
Sent: Thursday, March 18, 2010 1:55 PM
To: David Miller
Cc: netdev@vger.kernel.org; Amit Salecha
Subject: [PATCH] netxen: The driver doesn't work on NX_P3_B1 so cause probe to fail.


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

