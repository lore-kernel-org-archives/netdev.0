From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 14969] New: b44: WOL does not work in
 suspended state
Date: Thu, 7 Jan 2010 14:17:19 -0800
Message-ID: <20100107141719.a2303ad9.akpm@linux-foundation.org>
References: <bug-14969-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, ossi@kde.org,
	Gary Zambrano <zambrano@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:45946 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754410Ab0AGWSR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 17:18:17 -0500
In-Reply-To: <bug-14969-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Fri, 1 Jan 2010 12:26:16 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=14969
> 
>            Summary: b44: WOL does not work in suspended state
>            Product: Drivers
>            Version: 2.5
>     Kernel Version: 2.6.32.2
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>         ReportedBy: ossi@kde.org
>         Regression: No
> 
> 
> WOL works fine if the system is powered down. it does not work with echo
> mem/disk > /sys/power/state. for disk, it does not matter whether
> /sys/power/disk is platform or shutdown.
> 
> # lspci -vv
> 00:00.0 Host bridge: Intel Corporation 82845G/GL[Brookdale-G]/GE/PE DRAM
> Controller/Host-Hub Interface (rev 03)
>         Subsystem: ASUSTeK Computer Inc. Device 80b1
>         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort-
> <MAbort+ >SERR- <PERR- INTx-
>         Latency: 0
>         Region 0: Memory at f8000000 (32-bit, prefetchable) [size=64M]
>         Capabilities: [e4] Vendor Specific Information <?>
>         Kernel driver in use: agpgart-intel
> ...
> 02:05.0 Ethernet controller: Broadcom Corporation BCM4401 100Base-T (rev 01)
>         Subsystem: ASUSTeK Computer Inc. A7V8X motherboard
>         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort-
> <MAbort- >SERR- <PERR- INTx-
>         Latency: 32
>         Interrupt: pin A routed to IRQ 11
>         Region 0: Memory at ee000000 (32-bit, non-prefetchable) [size=8K]
>         Capabilities: [40] Power Management version 2
>                 Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA
> PME(D0+,D1+,D2+,D3hot+,D3cold+)
>                 Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=2 PME-
>         Kernel driver in use: b44
> 
> as becomes obvious from the pci dump, and is explained by reading the code, the
> driver does not set up the hardware for WOL until the device is closed. maybe
> this path is not taken at all when hibernating/suspending?
> 
> related bugs for other nics are: bug 8381, bug 8637, ...
> 
> 
> on a somewhat related note,
>   cat /sys/class/net/eth0/device/power/wakeup
> outputs just an empty line instead of enabled/disabled (like it does for the
> non-b44 eth1).

