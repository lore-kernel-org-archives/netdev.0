From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: PROBLEM: network interface regularly stops working
Date: Tue, 5 Jun 2007 22:37:09 +0200
Message-ID: <20070605203709.GA26645@electric-eye.fr.zoreil.com>
References: <200706051208.40929.kazjote@stud.ics.p.lodz.pl> <20070605111506.GA16401@electric-eye.fr.zoreil.com> <200706052147.02376.kazjote@stud.ics.p.lodz.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Kacper Bielecki <kazjote@stud.ics.p.lodz.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:33260 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765520AbXFEUkX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jun 2007 16:40:23 -0400
Content-Disposition: inline
In-Reply-To: <200706052147.02376.kazjote@stud.ics.p.lodz.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kacper Bielecki <kazjote@stud.ics.p.lodz.pl> :
[...]
> The motherboadr is ASRock ConRoe945G-DVI

Same model as my current test machine.

It uses a boring el-cheapo PIV though.

> After installing kernel 2.6.22-rc4 with patches 0001..0013 (there wasn't 0000 
> patch) the problem is not solved. I still get the same behaviour.

I did not look too closely at your report first, but:

> [   61.374301] fglrx: module license 'Proprietary. (C) 2002 - ATI Technologies, Starnberg, GERMANY' taints kernel.
> [   61.375872] [fglrx] Maximum main memory to use for locked dma buffers: 921 MBytes.
> [   61.376132] [fglrx] module loaded - fglrx 8.37.6 [May 25 2007] on minor 0
> [   61.413699] ACPI: PCI Interrupt 0000:03:00.0[A] -> GSI 16 (level, low) -> IRQ 16
> [   63.283042] [fglrx] total      GART = 130023424
> [   63.283047] [fglrx] free       GART = 114032640
> [   63.283049] [fglrx] max single GART = 114032640
> [   63.283051] [fglrx] total      LFB  = 268304384
> [   63.283053] [fglrx] free       LFB  = 256765952
> [   63.283055] [fglrx] max single LFB  = 256765952
> [   63.283057] [fglrx] total      Inv  = 0
> [   63.283059] [fglrx] free       Inv  = 0
> [   63.283061] [fglrx] max single Inv  = 0
> [   63.283063] [fglrx] total      TIM  = 0

Can you reproduce the problem if this module is not loaded at all ?

Please understand "loaded" as "it's loaded but it is not used" as well
as "it was loaded but I unloaded it before testing".

> Restarting interface doesn't solve the problem.

Neither do an 'ifconfig down/rmmod/modprobe/ifconfig up' cycle ?

[...]
> I don't know what else can help so I attach some information about system.

A 'cat /proc/interrupts', a few seconds of 'vmstat 1' a
'for i in $(seq 1 5); do ethtool -S eth0; sleep 1; done' after the watchdog
event and a good bunch of patience.

-- 
Ueimor
