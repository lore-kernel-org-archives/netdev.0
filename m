From: Jens Gehrlein <sew_s@tqs.de>
Subject: SMC921x: problems with LAN9215i connected to i.MX31
Date: Fri, 30 May 2008 08:37:22 +0200
Message-ID: <483FA0A2.1080707@tqs.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev ML <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tqs.de ([62.157.136.17]:3288 "EHLO mail.tqs.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753694AbYE3HCR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 May 2008 03:02:17 -0400
Received: from tq-mailsrv.tq-net.de (tq-mailsrv.tqs.de [172.20.1.2])
	by mail.tqs.de (Postfix) with ESMTP id A45D0189D5
	for <netdev@vger.kernel.org>; Fri, 30 May 2008 08:37:21 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

on our board we connected a LAN9215i to the Freescale i.MX31 ARM 
processor. Bus width: 16 bits. No DMA. Kernel 2.6.22. Driver: smc911x.c 
plus patches since then. Both processor and ethernet controller in 
little endian mode.

Ethereal showed scrambled or shifted data in the Ethernet frame. I 
couldn't identify a certain scheme.

I think, this is caused by the macros SMC_PULL_DATA (-> __raw_writesl 
and SMC_PUSH_DATA (-> __raw_readsl) to read/write the FIFOs. Single word 
accesses, e.g. identifying the controller are okay.

I temporarily replaced the macros by simple copy routines in C, which 
access the chip using 32 bit pointers. The processor automatically 
converts the word in two 16 bit accesses. And voila, it works. 
Unfortunately, I had to insert udelay(1) between each word :-(

Has somebody experience/tested with this processor/ethernet controller 
combination?

Does somebody know, how the assembler routines 
__raw_readsl/__raw_writesl work, so that analysis becomes easier? I 
didn't find any documentation.

What's the state of the new smsc driver Steve Glendinning announced some 
days ago on this list? A first look showed that it uses these assembler 
routines, too.

Thanks and best regards,
Jens


P.S.: is line wrapping okay (Thunderbird)?
