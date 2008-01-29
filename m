From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: sis190 build breakage
Date: Tue, 29 Jan 2008 23:27:48 +0100
Message-ID: <20080129222748.GD15445@electric-eye.fr.zoreil.com>
References: <20080129215023.GA24152@stro.at> <20080129220310.GC15445@electric-eye.fr.zoreil.com> <20080129222719.GS1446@baikonur.stro.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: maximilian attems <max@stro.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:34186 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753531AbYA2Woe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2008 17:44:34 -0500
Content-Disposition: inline
In-Reply-To: <20080129222719.GS1446@baikonur.stro.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

maximilian attems <max@stro.at> :
[...]
> probably i should to get interesting info.

Don't bother.

$ less +/devinitdata Documentation/pci.txt
[...]
Tips on when/where to use the above attributes:
        o The module_init()/module_exit() functions (and all
          initialization functions called _only_ from these)
          should be marked __init/__exit.

        o Do not mark the struct pci_driver.

        o The ID table array should be marked __devinitdata.

Could our documentation be wrong ?

diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
index b570402..2e9e88b 100644
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -326,7 +326,7 @@ static const struct {
 	{ "SiS 191 PCI Gigabit Ethernet adapter" },
 };
 
-static struct pci_device_id sis190_pci_tbl[] __devinitdata = {
+static struct pci_device_id sis190_pci_tbl[] = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_SI, 0x0190), 0, 0, 0 },
 	{ PCI_DEVICE(PCI_VENDOR_ID_SI, 0x0191), 0, 0, 1 },
 	{ 0, },
