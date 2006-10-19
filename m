From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: sky2 crash
Date: Thu, 19 Oct 2006 09:30:45 -0700
Message-ID: <20061019093045.3c04d162@dxpl.pdx.osdl.net>
References: <20061019151032.GA6102@cm.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:49077 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1946201AbWJSQbA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2006 12:31:00 -0400
To: Shane <shane@cm.nu>
In-Reply-To: <20061019151032.GA6102@cm.nu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 19 Oct 2006 08:10:33 -0700
Shane <shane@cm.nu> wrote:

> Hello,
> 
> I am experiencing an intermittent crash with a Gigabit
> controler using the sky2 driver under load.  Confirmed on
> 2.6.19-rc2 but also present with 2.6.18.  After the lockup,
> the system works as normally but the sky2 interface no
> longer processes traffic.  Here's the printk output:
> NETDEV WATCHDOG: eth0: transmit timed out
> sky2 eth0: tx timeout
> sky2 eth0: transmit ring 401 .. 378 report=403 done=403
> sky2 status report lost?

See below, most likely lost IRQ.

> BUG: soft lockup detected on CPU#0!
>  [<781447d5>]  [<78128ad6>]  [<78113b91>]  [<7810390b>]
> [<782b2477>]  [<f8986e43>]  [<7825fc69>]  [<7825fce5>]
> [<78128a30>]  [<78124eb1>]  [<78124f49>]  [<78113b96>]
> [<7810390b>]  [<78101265>]  [<78101281>]  [<78101d4f>]
> [<7837578c>]  [<783751e0>]  =======================
> 
> And the controler:
> 03:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8053 PCI-E Gigabit
>  Ethernet Controller (rev 22)
>         Subsystem: Giga-byte Technology Marvell 88E8053 Gigabit Ethernet Control
> ler (Gigabyte)
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Step
> ping- SERR- FastB2B-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort-
> <MAbort- >SERR- <PERR-
>         Latency: 0, Cache Line Size: 32 bytes
>         Interrupt: pin A routed to IRQ 218
>         Region 0: Memory at e8000000 (64-bit, non-prefetchable) [size=16K]
>         Region 2: I/O ports at 8000 [size=256]
>         [virtual] Expansion ROM at 88000000 [disabled] [size=128K]
>         Capabilities: [48] Power Management version 2
>                 Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot
> +,D3cold+)
>                 Status: D0 PME-Enable- DSel=0 DScale=1 PME-
>         Capabilities: [50] Vital Product Data
>         Capabilities: [5c] Message Signalled Interrupts: Mask- 64bit+ Queue=0/1
> Enable+
>                 Address: 00000000fee0300c  Data: 4142
>         Capabilities: [e0] Express Legacy Endpoint IRQ 0
>                 Device: Supported: MaxPayload 128 bytes, PhantFunc 0, ExtTag-
>                 Device: Latency L0s unlimited, L1 unlimited
>                 Device: AtnBtn- AtnInd- PwrInd-
>                 Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
>                 Device: RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
>                 Device: MaxPayload 128 bytes, MaxReadReq 512 bytes
>                 Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s, Port 0
>                 Link: Latency L0s <256ns, L1 unlimited
>                 Link: ASPM Disabled RCB 128 bytes CommClk- ExtSynch-
>                 Link: Speed 2.5Gb/s, Width x1
>         Capabilities: [100] Advanced Error Reporting
> 
> The system is a dual core Conroe system running with 2gb of
> ram and a memory split of 2gb/2gb.  Kernel preemption is
> voluntary.  I can disable preempt but it may take a day or
> two for the lockup to show up again.
> 
> Also, the mtu on this iface is set to 9k btu and the lockup
> seems more frequent at a good network load.
> 
> Shane
> 

1. What is the interrupt usage: cat /proc/interrupts

2. Try with the workaround for lost IRQ's
	modprobe sky2 idle_timeout=100

