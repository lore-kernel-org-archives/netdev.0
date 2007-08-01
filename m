From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [REGRESSION] tg3 dead after s2ram
Date: Wed, 01 Aug 2007 10:47:46 -0700
Message-ID: <1185990466.5552.34.camel@dell>
References: <20070731174522.b141178a.akpm@linux-foundation.org>
 <1185954811.5552.7.camel@dell>
 <200708011001.24384.joachim.deguara@amd.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Andrew Morton" <akpm@linux-foundation.org>,
	"lkml List" <linux-kernel@vger.kernel.org>,
	"Michal Piotrowski" <michal.k.k.piotrowski@gmail.com>,
	"netdev" <netdev@vger.kernel.org>, linux-acpi@vger.kernel.org
To: "Joachim Deguara" <joachim.deguara@amd.com>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <200708011001.24384.joachim.deguara@amd.com>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-08-01 at 10:01 +0200, Joachim Deguara wrote:

> Here are the lspci outputs for the tg3

You have 2 Broadcom devices in your system.  07:00.0 is a wireless
device, I think.  8:4.0 is the tg3 device.

It's clear that the tg3 device is still in D3 state after resume and
that explains why all register accesses fail.  tg3_resume() should put
the device back in D0 state in a very straight forward way and I don't
see how that can fail.  It worked for me when I tested it last night.
Can you add some printk() to tg3_resume() to see what's happening?  Let
me know if you want me to send you some debug patches to do that.

Thanks.

Here's the before and after for 8:4.0:

> 
> Before
>
> 08:04.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5788 Gigabit 
> Ethernet (rev 03)
> 	Subsystem: Acer Incorporated [ALI] Unknown device 010e
> 	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- 
> SERR- FastB2B-
> 	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- 
> <MAbort- >SERR- <PERR-
> 	Latency: 0 (16000ns min)
> 	Interrupt: pin A routed to IRQ 22
> 	Region 0: Memory at d0300000 (32-bit, non-prefetchable) [size=64K]
> 	Expansion ROM at <ignored> [disabled]
> 	Capabilities: [48] Power Management version 2
> 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot+,D3cold+)
> 		Status: D0 PME-Enable- DSel=0 DScale=1 PME-
> 	Capabilities: [50] Vital Product Data
> 	Capabilities: [58] Message Signalled Interrupts: Mask- 64bit+ Queue=0/3 
> Enable-
> 		Address: ffff6bfe7fffffb8  Data: fec7
> 00: e4 14 9c 16 06 00 b0 02 03 00 00 02 00 00 00 00
> 10: 00 00 30 d0 00 00 00 00 00 00 00 00 00 00 00 00
> 20: 00 00 00 00 00 00 00 00 07 00 00 00 25 10 0e 01
> 30: 00 00 ff ff 48 00 00 00 00 00 00 00 0a 01 40 00
> 40: 00 00 00 00 00 00 00 00 01 50 02 c0 00 20 00 00
> 50: 03 58 fc 00 6f bf be 7f 05 00 86 00 b8 ff ff 7f
> 60: fe 6b ff ff c7 fe 00 00 98 00 03 30 00 00 3f 76
> 70: f6 10 00 00 20 00 00 80 14 04 00 00 00 00 00 00
> 80: 85 6b d0 36 03 40 00 0c 34 00 13 04 82 90 09 04
> 90: 09 97 00 01 00 00 00 00 00 00 00 00 eb 01 00 00
> a0: 00 00 00 00 23 01 00 00 00 00 00 00 cb 00 00 00
> b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 
> After
> 
> 08:04.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5788 Gigabit 
> Ethernet (rev 03)
> 	Subsystem: Acer Incorporated [ALI] Unknown device 010e
> 	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- 
> SERR- FastB2B-
> 	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- 
> <MAbort- >SERR- <PERR-
> 	Interrupt: pin A routed to IRQ 22
> 	Region 0: Memory at d0300000 (32-bit, non-prefetchable) [disabled] [size=64K]
> 	Expansion ROM at <ignored> [disabled]
> 	Capabilities: [48] Power Management version 2
> 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot+,D3cold+)
> 		Status: D0 PME-Enable+ DSel=0 DScale=1 PME-
> 	Capabilities: [50] Vital Product Data
> 	Capabilities: [58] Message Signalled Interrupts: Mask- 64bit+ Queue=0/3 
> Enable-
> 		Address: ffff6bfe7fffffb8  Data: fec7
> 00: e4 14 9c 16 00 00 b0 02 03 00 00 02 00 00 00 00
> 10: 00 00 30 d0 00 00 00 00 00 00 00 00 00 00 00 00
> 20: 00 00 00 00 00 00 00 00 07 00 00 00 25 10 0e 01
> 30: 00 00 ff ff 48 00 00 00 00 00 00 00 0a 01 40 00
> 40: 00 00 00 00 00 00 00 00 01 50 02 c0 00 21 00 64
> 50: 03 58 fc 00 6f bf be 7f 05 00 86 00 b8 ff ff 7f
> 60: fe 6b ff ff c7 fe 00 00 9a 00 03 30 00 00 00 00
> 70: 76 10 00 00 40 00 00 00 50 00 00 00 00 00 00 00
> 80: 03 58 fc 00 00 00 00 00 00 00 00 00 fe 90 09 04
> 90: 01 07 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 


