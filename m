From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [Bugme-new] [Bug 9990] New: tg3: eth0: The system may be re-ordering memory-mapped I/O cycles
Date: Thu, 14 Feb 2008 13:56:27 -0500
Message-ID: <20080214185627.GK856@gospo.usersys.redhat.com>
References: <bug-9990-10286@http.bugzilla.kernel.org/> <20080214102425.0fc8e3c1.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	ralf.hildebrandt@charite.de
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:52373 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757191AbYBNS5P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Feb 2008 13:57:15 -0500
Content-Disposition: inline
In-Reply-To: <20080214102425.0fc8e3c1.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 14, 2008 at 10:24:25AM -0800, Andrew Morton wrote:
> On Thu, 14 Feb 2008 01:59:12 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:
> 
> > http://bugzilla.kernel.org/show_bug.cgi?id=9990
> > 
> >            Summary: tg3: eth0: The system may be re-ordering memory-mapped
> >                     I/O cycles
> >            Product: Drivers
> >            Version: 2.5
> >      KernelVersion: 2.6.24-git18
> >           Platform: All
> >         OS/Version: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: normal
> >           Priority: P1
> >          Component: Network
> >         AssignedTo: jgarzik@pobox.com
> >         ReportedBy: ralf.hildebrandt@charite.de
> > 
> > 
> > Latest working kernel version: 2.6.24
> > Earliest failing kernel version: 2.6.24-git18
> > Distribution: Debian/testing
> > Hardware Environment:
> > Software Environment:
> > Problem Description:
> > 
> > Feb 11 13:11:52 www kernel: [   12.015569] tg3: eth0: Link is up at 100 Mbps,
> > full duplex.
> > Feb 11 13:11:52 www kernel: [   12.015633] tg3: eth0: Flow control is on for TX
> > and on for RX.
> > Feb 11 13:33:44 www kernel: [ 1328.538204] tg3: eth0: The system may be
> > re-ordering memory-mapped I/O cycles to the network
> > device, attempting to recover. Please report the problem to the driver
> > maintainer and include system chipset information.
> > Feb 11 13:33:44 www kernel: [ 1328.667255] tg3: eth0: Link is down.
> > Feb 11 13:33:46 www kernel: [ 1330.560734] tg3: eth0: Link is up at 100 Mbps,
> > full duplex.
> > Feb 11 13:33:46 www kernel: [ 1330.560734] tg3: eth0: Flow control is on for TX
> > and on for RX.
> > 
> > After that, the machine rebooted (panic?)
> > 
> > Feb 11 13:35:14 www kernel: klogd 1.5.0#1.1, log source = /proc/kmsg started.
> > 
> > lspci -vvv info:
> > 02:02.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5704 Gigabit
> > Ethernet (rev 10)
> >         Subsystem: Compaq Computer Corporation NC7782 Gigabit Server Adapter
> > (PCI-X, 10,100,1000-T)
> >         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+
> > Stepping- SERR+ FastB2B- DisINTx-
> >         Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
> > <TAbort- <MAbort- >SERR- <PERR- INTx-
> >         Latency: 64 (16000ns min), Cache Line Size: 64 bytes
> >         Interrupt: pin A routed to IRQ 19
> >         Region 0: Memory at fdf70000 (64-bit, non-prefetchable) [size=64K]
> >         [virtual] Expansion ROM at 88140000 [disabled] [size=64K]
> >         Capabilities: [40] PCI-X non-bridge device
> >                 Command: DPERE- ERO- RBC=2048 OST=1
> >                 Status: Dev=02:02.0 64bit+ 133MHz+ SCD- USC- DC=simple
> > DMMRBC=2048 DMOST=1 DMCRS=16 RSCEM- 266MHz- 533MHz-
> >         Capabilities: [48] Power Management version 2
> >                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
> > PME(D0-,D1-,D2-,D3hot+,D3cold+)
> >                 Status: D0 PME-Enable+ DSel=0 DScale=1 PME-
> >         Capabilities: [50] Vital Product Data <?>
> >         Capabilities: [58] Message Signalled Interrupts: Mask- 64bit+ Queue=0/3
> > Enable-
> >                 Address: fd7ffd6fdf7deeb8  Data: bdfd
> >         Kernel driver in use: tg3
> >         Kernel modules: tg3
> > 
> > 02:02.1 Ethernet controller: Broadcom Corporation NetXtreme BCM5704 Gigabit
> > Ethernet (rev 10)
> >         Subsystem: Compaq Computer Corporation NC7782 Gigabit Server Adapter
> > (PCI-X, 10,100,1000-T)
> >         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+
> > Stepping- SERR+ FastB2B- DisINTx-
> >         Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
> > <TAbort- <MAbort- >SERR- <PERR- INTx-
> >         Latency: 64 (16000ns min), Cache Line Size: 64 bytes
> >         Interrupt: pin B routed to IRQ 20
> >         Region 0: Memory at fdf60000 (64-bit, non-prefetchable) [size=64K]
> >         Capabilities: [40] PCI-X non-bridge device
> >                 Command: DPERE- ERO+ RBC=512 OST=1
> >                 Status: Dev=02:02.1 64bit+ 133MHz+ SCD- USC- DC=simple
> > DMMRBC=2048 DMOST=1 DMCRS=16 RSCEM- 266MHz- 533MHz-
> >         Capabilities: [48] Power Management version 2
> >                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
> > PME(D0-,D1-,D2-,D3hot+,D3cold+)
> >                 Status: D0 PME-Enable- DSel=0 DScale=1 PME-
> >         Capabilities: [50] Vital Product Data <?>
> >         Capabilities: [58] Message Signalled Interrupts: Mask- 64bit+ Queue=0/3
> > Enable-
> >                 Address: f73feeefffffe7f8  Data: 9bcd
> >         Kernel driver in use: tg3
> >         Kernel modules: tg3
> > 
> > 
> > Steps to reproduce:
> > 
> > 

That should be a simple matter of adding the right pci-ids to
tg3_get_invariants -- hopefully Ralf will respond and we can get that
knocked out quickly.

