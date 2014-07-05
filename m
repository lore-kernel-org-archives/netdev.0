From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: [PATCH 0/5] defxx: Fixes for 64-bit host support
Date: Sat, 5 Jul 2014 15:14:13 +0100 (BST)
Message-ID: <alpine.LFD.2.11.1407020439490.15455@eddie.linux-mips.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Robert Coerver <Robert.Coerver@ll.mit.edu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([78.24.191.182]:59876 "EHLO
	cvs.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751309AbaGEOOQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jul 2014 10:14:16 -0400
Received: from localhost.localdomain ([127.0.0.1]:48334 "EHLO
        localhost.localdomain" rhost-flags-OK-OK-OK-OK)
        by eddie.linux-mips.org with ESMTP id S6859943AbaGEOONKeCh6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 5 Jul 2014 16:14:13 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

 This mini patch series addresses issues with 64-bit host support for FDDI 
interface boards supported by the defxx driver where DMA mapping 
synchronisation is required on swiotlb systems.  While PDQ, the DMA engine 
chip used with these boards, supports 48-bit addressing that would 
normally suffice for typical 64-bit systems in existence, the host bus 
interface chips used by individual implementations have their limitations 
as follows:

* DEFTA or DEC FDDIcontroller/TURBOchannel -- there's no host bus 
  interface chip, the PDQ connects to TURBOchannel directly; TURBOchannel 
  supports DMA addressing of up to 16GB (34-bit addressing), however no 
  TURBOchannel system has ever been made that supports more than 1GB of 
  RAM, so in reality no remapping is ever required,

* DEFEA or DEC FDDIcontroller/EISA -- the ESIC EISA interface chip only 
  supports 32-bit addressing, all accesses beyond 4GB have to be remapped,

* DEFPA or DEC FDDIcontroller/PCI -- the PFI PCI interface chip rev. 1 & 2 
  only support 32-bit addressing, they have 32 AD lines only both on the 
  PDQ and the PCI side, and consequently no Dual Address Cycle support, so 
  all accesses beyond 4GB have to be remapped; the range of addressing 
  supported by PFI rev. 3 is currently not certain, however the chip is 
  backwards compatible with earlier revisions and will work with code that 
  supports them.

Some other issues discovered in the course of correcting 64-bit support 
have been fixed as well.  Each of the patches is functionally 
self-contained and can be applied independentely, although there may be 
mechanical dependencies making it necessary to apply patches in order.

 The driver suffers from non-standard formatting and while I did my best 
with these bug fixes to follow our coding style, I found some pieces 
hopeless, checkpatch.pl will complain.  I plan to reformat the whole 
driver, that will inevitably require factoring out some pieces into 
separate functions, but that's going to be a major effort and therefore I 
want to do this separately, with no functional changes made at the same 
time.  If anyone has specific suggestions as to how to reformat any of the 
pieces submitted here for a better layout, then I'll be happy to take them 
into account.

 And last but not least many thanks to Robert Coerver, who was the most 
recent person to report this problem with the driver and was kind enough 
to patiently try a few revisions of the driver update on his system as I 
was finding and addressing issues.

  Maciej
