From: "Ravinandan Arakali" <ravinandan.arakali@neterion.com>
Subject: pci_enable_msix throws up error
Date: Thu, 4 May 2006 16:16:13 -0700
Message-ID: <MAEEKMLDLDFEGKHNIJHIOECKCEAA.ravinandan.arakali@neterion.com>
Reply-To: <ravinandan.arakali@neterion.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Ananda. Raju" <ananda.raju@neterion.com>,
	<netdev@vger.kernel.org>,
	"Leonid Grossman" <Leonid.Grossman@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:8628 "EHLO
	barracuda.mail.s2io.com") by vger.kernel.org with ESMTP
	id S1751469AbWEDXQE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 May 2006 19:16:04 -0400
To: <linux-kernel@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,
I am seeing the following problem with MSI/MSI-X.

Note: I am copying netdev since other network drivers use
this feature and somebody on the list could throw light.

Our 10G network card(Xframe II) supports MSI and MSI-X.
When I load/unload the driver with MSI support followed
by an attempt to load with MSI-X, I get the following
message from pci_enable_msix:

"Can't enable MSI-X.  Device already has an MSI vector assigned"

I seem to be doing the correct things when unloading the
MSI driver. Basically, I do free_irq() followed by pci_disable_msi().
Any idea what I am missing ?

Further analysis:
Looking at the code, the following check(when it finds a match) in
msi_lookup_vector(called by pci_enable_msix) seems to throw up this
message:
if (!msi_desc[vector] || msi_desc[vector]->dev != dev ||
    msi_desc[vector]->msi_attrib.type != type ||
    msi_desc[vector]->msi_attrib.default_vector != dev->irq)

pci_enable_msi, on successful completion will populate the
fields in msi_desc. But neither pci_disable_msi nor free_irq
seems to undo/unpopulate the msi_desc table.
Could this be the cause for the problem ?

Thanks,
Ravi


