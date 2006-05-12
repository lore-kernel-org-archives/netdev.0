From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: 2.6.16.13 e1000 reports incorrect PCI-X bus speed?
Date: Fri, 12 May 2006 14:33:53 -0700
Message-ID: <4464FF41.7060000@intel.com>
References: <4464FB01.6070206@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr20.intel.com ([134.134.136.19]:51924 "EHLO
	orsfmr005.jf.intel.com") by vger.kernel.org with ESMTP
	id S1750736AbWELVdy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 May 2006 17:33:54 -0400
Received: from orsfmr101.jf.intel.com (orsfmr101.jf.intel.com [10.7.209.17])
	by orsfmr005.jf.intel.com (8.12.10/8.12.10/d: major-outer.mc,v 1.1 2004/09/17 17:50:56 root Exp $) with ESMTP id k4CLXrtQ028670
	for <netdev@vger.kernel.org>; Fri, 12 May 2006 21:33:53 GMT
Received: from [134.134.3.74] (ahkok-mobl.jf.intel.com.jf.intel.com [134.134.3.74])
	by orsfmr101.jf.intel.com (8.12.10/8.12.10/d: major-inner.mc,v 1.2 2004/09/17 18:05:01 root Exp $) with ESMTP id k4CLXrjv022888
	for <netdev@vger.kernel.org>; Fri, 12 May 2006 21:33:53 GMT
To: netdev@vger.kernel.org
In-Reply-To: <4464FB01.6070206@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Greear wrote:
> I'm running a slightly modified 2.6.16.13 kernel on FC5-amd64.  The 
> motherboard
> is SuperMicro H8SSL dual-core AMD system.  According to super-micro web 
> site,
> the PCI-X slot is 133Mhz.  I'm using a 4-port pro/1000 NIC.
> 
> dmesg shows a listing of 120Mhz:
> 
> Intel(R) PRO/1000 Network Driver - version 6.3.9-k4-NAPI
> Copyright (c) 1999-2005 Intel Corporation.
> GSI 18 sharing vector 0xB9 and IRQ 18
> ACPI: PCI Interrupt 0000:03:04.0[A] -> GSI 20 (level, low) -> IRQ 18
> e1000: 0000:03:04.0: e1000_probe: (PCI-X:120MHz:64-bit) 00:04:23:ad:41:bc
> e1000: eth2: e1000_probe: Intel(R) PRO/1000 Network Connection
> GSI 19 sharing vector 0xC1 and IRQ 19
> ACPI: PCI Interrupt 0000:03:04.1[B] -> GSI 21 (level, low) -> IRQ 19
> e1000: 0000:03:04.1: e1000_probe: (PCI-X:120MHz:64-bit) 00:04:23:ad:41:bd
> e1000: eth3: e1000_probe: Intel(R) PRO/1000 Network Connection
> GSI 20 sharing vector 0xC9 and IRQ 20
> ACPI: PCI Interrupt 0000:03:06.0[A] -> GSI 22 (level, low) -> IRQ 20
> e1000: 0000:03:06.0: e1000_probe: (PCI-X:120MHz:64-bit) 00:04:23:ad:41:be
> e1000: eth4: e1000_probe: Intel(R) PRO/1000 Network Connection
> GSI 21 sharing vector 0xD1 and IRQ 21
> ACPI: PCI Interrupt 0000:03:06.1[B] -> GSI 23 (level, low) -> IRQ 21
> e1000: 0000:03:06.1: e1000_probe: (PCI-X:120MHz:64-bit) 00:04:23:ad:41:bf
> e1000: eth5: e1000_probe: Intel(R) PRO/1000 Network Connection
> 
> ethtool -d eth3 shows 66Mhz:
> ....
> 0x00008: STATUS (Device status register) 0x00003B87
>       Duplex:                            full
>       Link up:                           link config
>       TBI mode:                          disabled
>       Link speed:                        1000Mb/s
>       Bus type:                          PCI-X
>       Bus speed:                         66MHz
>       Bus width:                         64-bit
> 
> Any idea why I see the slower bus speed reported?

ethtool currently doesn't know about some bus speeds, and will report a wrong
speed. Here's what ethtool currently uses: (ethtool-3/e1000.c)

327                 (reg & E1000_STATUS_PCIX_MODE) ?
328                         ((reg & E1000_STATUS_PCIX_SPEED_133) ? "133MHz" :
329                         (reg & E1000_STATUS_PCIX_SPEED_100) ? "100MHz" :
330                         "66MHz")>              :

obviously 120 is missing, but PCI-E speeds are also missing (2500gbps). The
output of the e1000 module is correct.

Auke

