From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 9990] New: tg3: eth0: The system may be
 re-ordering memory-mapped I/O cycles
Date: Thu, 14 Feb 2008 10:24:25 -0800
Message-ID: <20080214102425.0fc8e3c1.akpm@linux-foundation.org>
References: <bug-9990-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	ralf.hildebrandt@charite.de
To: Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:44634 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754019AbYBNSZE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2008 13:25:04 -0500
In-Reply-To: <bug-9990-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 14 Feb 2008 01:59:12 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=9990
> 
>            Summary: tg3: eth0: The system may be re-ordering memory-mapped
>                     I/O cycles
>            Product: Drivers
>            Version: 2.5
>      KernelVersion: 2.6.24-git18
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: jgarzik@pobox.com
>         ReportedBy: ralf.hildebrandt@charite.de
> 
> 
> Latest working kernel version: 2.6.24
> Earliest failing kernel version: 2.6.24-git18
> Distribution: Debian/testing
> Hardware Environment:
> Software Environment:
> Problem Description:
> 
> Feb 11 13:11:52 www kernel: [   12.015569] tg3: eth0: Link is up at 100 Mbps,
> full duplex.
> Feb 11 13:11:52 www kernel: [   12.015633] tg3: eth0: Flow control is on for TX
> and on for RX.
> Feb 11 13:33:44 www kernel: [ 1328.538204] tg3: eth0: The system may be
> re-ordering memory-mapped I/O cycles to the network
> device, attempting to recover. Please report the problem to the driver
> maintainer and include system chipset information.
> Feb 11 13:33:44 www kernel: [ 1328.667255] tg3: eth0: Link is down.
> Feb 11 13:33:46 www kernel: [ 1330.560734] tg3: eth0: Link is up at 100 Mbps,
> full duplex.
> Feb 11 13:33:46 www kernel: [ 1330.560734] tg3: eth0: Flow control is on for TX
> and on for RX.
> 
> After that, the machine rebooted (panic?)
> 
> Feb 11 13:35:14 www kernel: klogd 1.5.0#1.1, log source = /proc/kmsg started.
> 
> lspci -vvv info:
> 02:02.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5704 Gigabit
> Ethernet (rev 10)
>         Subsystem: Compaq Computer Corporation NC7782 Gigabit Server Adapter
> (PCI-X, 10,100,1000-T)
>         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+
> Stepping- SERR+ FastB2B- DisINTx-
>         Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 64 (16000ns min), Cache Line Size: 64 bytes
>         Interrupt: pin A routed to IRQ 19
>         Region 0: Memory at fdf70000 (64-bit, non-prefetchable) [size=64K]
>         [virtual] Expansion ROM at 88140000 [disabled] [size=64K]
>         Capabilities: [40] PCI-X non-bridge device
>                 Command: DPERE- ERO- RBC=2048 OST=1
>                 Status: Dev=02:02.0 64bit+ 133MHz+ SCD- USC- DC=simple
> DMMRBC=2048 DMOST=1 DMCRS=16 RSCEM- 266MHz- 533MHz-
>         Capabilities: [48] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
> PME(D0-,D1-,D2-,D3hot+,D3cold+)
>                 Status: D0 PME-Enable+ DSel=0 DScale=1 PME-
>         Capabilities: [50] Vital Product Data <?>
>         Capabilities: [58] Message Signalled Interrupts: Mask- 64bit+ Queue=0/3
> Enable-
>                 Address: fd7ffd6fdf7deeb8  Data: bdfd
>         Kernel driver in use: tg3
>         Kernel modules: tg3
> 
> 02:02.1 Ethernet controller: Broadcom Corporation NetXtreme BCM5704 Gigabit
> Ethernet (rev 10)
>         Subsystem: Compaq Computer Corporation NC7782 Gigabit Server Adapter
> (PCI-X, 10,100,1000-T)
>         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+
> Stepping- SERR+ FastB2B- DisINTx-
>         Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 64 (16000ns min), Cache Line Size: 64 bytes
>         Interrupt: pin B routed to IRQ 20
>         Region 0: Memory at fdf60000 (64-bit, non-prefetchable) [size=64K]
>         Capabilities: [40] PCI-X non-bridge device
>                 Command: DPERE- ERO+ RBC=512 OST=1
>                 Status: Dev=02:02.1 64bit+ 133MHz+ SCD- USC- DC=simple
> DMMRBC=2048 DMOST=1 DMCRS=16 RSCEM- 266MHz- 533MHz-
>         Capabilities: [48] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
> PME(D0-,D1-,D2-,D3hot+,D3cold+)
>                 Status: D0 PME-Enable- DSel=0 DScale=1 PME-
>         Capabilities: [50] Vital Product Data <?>
>         Capabilities: [58] Message Signalled Interrupts: Mask- 64bit+ Queue=0/3
> Enable-
>                 Address: f73feeefffffe7f8  Data: 9bcd
>         Kernel driver in use: tg3
>         Kernel modules: tg3
> 
> 
> Steps to reproduce:
> 
> 
