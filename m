From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: 8139too in >=2.6.26: SIOCSIFFLAGS: Device or resource busy
Date: Thu, 11 Dec 2008 21:18:37 +0100
Message-ID: <20081211201837.GA25911@electric-eye.fr.zoreil.com>
References: <6f67b0190812100251u511d0aect4d082541977335d9@mail.gmail.com> <20081210210435.GA30537@electric-eye.fr.zoreil.com> <6f67b0190812110405y4f8b2498t6ae9a97a3faf4d5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Christoph Gysin <christoph.gysin@fr33z3.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:35942 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757250AbYLKUSc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2008 15:18:32 -0500
Content-Disposition: inline
In-Reply-To: <6f67b0190812110405y4f8b2498t6ae9a97a3faf4d5@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(please don't take it private-only)

Christoph Gysin <christoph.gysin@fr33z3.org> :
> 2008/12/10 Francois Romieu <romieu@fr.zoreil.com>:
[...]
> > Indeed. Assuming you are using the same kernel .config, can you compare
> > the dmesg from boot of 2.6.25 against 2.6.26 ?
> 
> Same kernel .config, dmesg output from 2.6.25:
> 
> $ modprobe 8139too debug=1
> $ dmesg
> 8139too Fast Ethernet driver 0.9.28
> rtl8139_init_board: PIO region size == 0x100
> rtl8139_init_board: MMIO region size == 0x100
> rtl8139_init_board: chipset id (1950351360) == index 8, 'RTL-8100B/8139D'
> rtl8139_init_board: PCI PM wakeup
> rtl8139_init_one: about to register device named eth%d (cf044000)...
> eth0: RealTek RTL8139 at 0xd001e000, 00:03:2d:0e:8c:2f, IRQ 15
> eth0:  Identified 8139 chip type 'RTL-8100B/8139D'

I was not clear enough: can you do a diff of the complete boot messages ?
For instance:
$ dmesg > dmesg-2.6.25
[change kernel]
$ dmesg > dmesg-2.6.26
$ diff -upN dmesg-2.6.25 dmesg-2.6.26

Rationale:
1. the 8139too driver underwent almost no change between 2.6.25 and 2.6.26
2. rtl8139_open can only fail because of request_irq

It is not clear that the issue is in the 8139too driver itself.

-- 
Ueimor
