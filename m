From: Kevin Baradon <kevin.baradon@gmail.com>
Subject: Re: [PATCH] net/ethernet/jme: disable ASPM
Date: Wed, 10 Oct 2012 22:50:49 +0200
Message-ID: <20121010225049.024c94cb@laptop-kevin.kbaradon.com>
References: <1349722956-14159-1-git-send-email-kevin.baradon@gmail.com>
 <20121008.152426.1524908667081347879.davem@davemloft.net>
 <20121008193316.GA13684@srcf.ucam.org>
 <20121008.153953.2134806395029777705.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mjg59@srcf.ucam.org, cooldavid@cooldavid.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:52388 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752933Ab2JJUuy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2012 16:50:54 -0400
Received: by mail-wi0-f178.google.com with SMTP id hr7so1330145wib.1
        for <netdev@vger.kernel.org>; Wed, 10 Oct 2012 13:50:53 -0700 (PDT)
In-Reply-To: <20121008.153953.2134806395029777705.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le Mon, 08 Oct 2012 15:39:53 -0400 (EDT),
David Miller <davem@davemloft.net> a =C3=A9crit :

> From: Matthew Garrett <mjg59@srcf.ucam.org>
> Date: Mon, 8 Oct 2012 20:33:16 +0100
>=20
> > On Mon, Oct 08, 2012 at 03:24:26PM -0400, David Miller wrote:
> >=20
> >> This should be a PCI quirk shouldn't it?
> >=20
> > No, it's a driver-level policy decision.
>=20
> Then at a bare minimum this change should be using one of the ASPM
> helpers provided by drivers/pci/pcie/aspm.c such as
> pci_disable_link_state().

pci_disable_link_state() is already used in this patch.
Am I missing something else?

Below you will find updated patch with corrected indentation.

-- >8 --
Subject: [PATCH] net/ethernet/jme: disable ASPM

Based on patch from Matthew Garrett <mjg@redhat.com> (https://lkml.org/=
lkml/2011/11/11/168).

http://driveragent.com/archive/30421/7-0-14 indicates that ASPM is
disabled on the 250 and 260. Duplicate for sanity.

=46ixes random RX engine hangs I experienced with JMC250 on Clevo W270H=
U.

Signed-off-by: Kevin Baradon <kevin.baradon@gmail.com>
Cc: Guo-Fu Tseng <cooldavid@cooldavid.org>
Cc: Matthew Garrett <mjg@redhat.com>
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/jme.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/jme.c b/drivers/net/ethernet/jme.c
index c911d88..f8064df 100644
--- a/drivers/net/ethernet/jme.c
+++ b/drivers/net/ethernet/jme.c
@@ -27,6 +27,7 @@
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/pci.h>
+#include <linux/pci-aspm.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
@@ -2973,6 +2974,9 @@ jme_init_one(struct pci_dev *pdev,
 	/*
 	 * set up PCI device basics
 	 */
+	pci_disable_link_state(pdev, PCIE_LINK_STATE_L0S | PCIE_LINK_STATE_L1=
 |
+			       PCIE_LINK_STATE_CLKPM);
+
 	rc =3D pci_enable_device(pdev);
 	if (rc) {
 		pr_err("Cannot enable PCI device\n");
--=20
1.7.10.4
