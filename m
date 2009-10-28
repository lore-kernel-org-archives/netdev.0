From: Ben Dooks <ben@simtec.co.uk>
Subject: Re: [PATCH V2]NET/KS8695: add support NAPI for Rx
Date: Wed, 28 Oct 2009 10:57:50 +0000
Message-ID: <4AE823AE.4040409@simtec.co.uk>
References: <1256653422.2148.23.camel@myhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: "Figo.zhang" <figo1802@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aeryn.fluff.org.uk ([87.194.8.8]:54207 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751904AbZJ1K55 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 06:57:57 -0400
In-Reply-To: <1256653422.2148.23.camel@myhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Figo.zhang wrote:
> Add support NAPI Rx API for KS8695NET driver.
> 
> v2, change the Rx function to NAPI.
> 
> in <KS8695X Integrated Multi-port Gateway Solution Register Description
>  v1.0>:
> 
> Interrupt Enable Register (offset 0xE204)
> Bit29 : WAN MAC Receive Interrupt Enable
> Bit16 : LAN MAC Receive Interrupt Enable
> 
> Interrupt Status Register (Offset 0xF208)
> Bit29: WAN MAC Receive Status
> Bit16: LAN MAC Receive Status
> 
> see arch/arm/mach-ks8695/devices.c:
> ks8695_wan_resources[] and ks8695_lan_resources[]
> have IORESOURCE_IRQ , it have define the RX irq,
> for wan, irq = 29; for lan ,irq = 16.
> so we can do this read the interrupt status:
> 
> unsigned long mask_bit = 1 << ksp->rx_irq;
> status = readl(KS8695_IRQ_VA + KS8695_INTST);

It would be nice to see some form of API addition to
the interrupt system to ack interrupts that have been
handled like this, since the irq layer is already
tracking the necessary IRQ->handler mappings.

-- 
Ben Dooks, Software Engineer, Simtec Electronics

http://www.simtec.co.uk/
