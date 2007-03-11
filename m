From: Alfred Arnold <alfred@ccac.rwth-aachen.de>
Subject: Questions regarding kernel 2.6 3C59x driver on EISA systems
Date: Sun, 11 Mar 2007 18:57:58 +0100 (CET)
Message-ID: <Pine.NEB.4.58.0703111851570.15661@kepler.ccac.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from heisenberg.ccac.RWTH-Aachen.DE ([134.130.220.226]:3678 "EHLO
	heisenberg.ccac.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933920AbXCKSLr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Mar 2007 14:11:47 -0400
Received: from kepler.ccac.rwth-aachen.de (kepler.ccac.RWTH-Aachen.DE [134.130.220.230])
	by heisenberg.ccac.rwth-aachen.de (Postfix) with ESMTP id 79C6C30346
	for <netdev@vger.kernel.org>; Sun, 11 Mar 2007 18:53:05 +0100 (CET)
Received: from localhost (localhost [[UNIX: localhost]])
	by kepler.ccac.rwth-aachen.de (8.8.8/8.8.8) with ESMTP id SAA15666
	for <netdev@vger.kernel.org>; Sun, 11 Mar 2007 18:57:59 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I recently was able to get hold of a 3C597 card for my Jensen Alpha.
Compiling the driver for it however gives error messages about undefined
symbols:

pci_alloc_consistent
pci_free_consistent
pci_map_single
pci_map_unsingle

These functions do not exist on a pure EISA system (like the Jensen
Alpha), however the calls to these functions seem to be hardwired in the
driver, regardless of the card's interface type (PCI or EISA).  Seems to
me this driver hasn't been compiled on a pure EISA system for a while ;-)

I had some success by replacing these functions with

dma_alloc_coherent
dma_free_coherent
dma_map_single
dma_unmap_single

The driver will then load, correctly identify the card and at least send
packets (I still have trouble with interrupts, but that might be due to
the incomplete EISA setup of the Jensen).  I'm not sure however if this is
the correct change, I copied this from the AHA1742 driver.

Are the EISA 3C59x variants still supported at all?  If yes, this should
IMHO be fixed.  I can provide my patch, which is basically an #ifdef
CONFIG_PCI conditional, but this will probably not work in mixed PCI/EISA
systems.

I am using Linux kernel 2.6.20.1 .  I sent the same mail a week ago to
Andrew Morton (akpm@osdl.org), which is the address mentioned in the
'vortex.txt' documentation file.  I haven't received any answers since
then, however :-(

Best regards

Alfred Arnold

-- 
Alfred Arnold                   E-Mail: alfred@ccac.rwth-aachen.de
Computer Club at the            http://john.ccac.rwth-aachen.de:8000/alf/
Technical University            Phone: +49-241-406526
of Aachen                       Fax:   +49-241-406527
