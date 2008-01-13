From: "Andrew Paprocki" <andrew@ishiboo.com>
Subject: sky2 driver stopped working after upgrading from 2.6.18-4
Date: Sun, 13 Jan 2008 03:24:31 -0500
Message-ID: <76366b180801130024j78225c66j17974245e86a183f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Stephen Hemminger" <shemminger@osdl.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.179]:26406 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751173AbYAMIYc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jan 2008 03:24:32 -0500
Received: by wa-out-1112.google.com with SMTP id v27so2890831wah.23
        for <netdev@vger.kernel.org>; Sun, 13 Jan 2008 00:24:31 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have never been able to get my Yukon-EC Ultra (0xb4) rev 2 working
on anything past 2.6.18-4 that I've tried. (All ~.20+)

Below is the debug output from the driver on both versions. Notice the
'phy interrupt status' that each version prints out in case it is
involved in the problem:

2.6.18-4:  sky2 eth0: phy interrupt status 0x1c40 0xbf48
2.6.23.13: sky2 eth0: phy interrupt status 0x1c40 0xbf08

Things I've tried:
- disabling MSI
- building git head (2.4.24-rc7) to get the latest driver (same problem)
- manually changing some sky2.c code back to 18-4 code to see if I
could produce different behavior

Things I see:
- the right-hand green LED never lights up using the new code, it
blinks under the old code
- when I manually config an IP and ping, it reports a single packet
response w/ 0.000ms time and then nothing else

I added a printk into gm_phy_write() and this is what prints out under
2.6.23.13:

ACPI: PCI Interrupt 0000:02:00.0[A] -> GSI 18 (level, low) -> IRQ 20
PCI: Setting latency timer of device 0000:02:00.0 to 64
sky2 0000:02:00.0: v1.18 addr 0xfddfc000 irq 20 Yukon-EC Ultra (0xb4) rev 2
<NULL>: reg 0x0012 val 0x0000
sky2 eth0: addr 00:0a:48:00:0a:53
sky2 eth0: enabling interface
eth0: reg 0x0010 val 0x2860
eth0: reg 0x0009 val 0x0300
eth0: reg 0x0004 val 0x0de1
eth0: reg 0x0000 val 0x9200
eth0: reg 0x0016 val 0x0003
eth0: reg 0x0010 val 0x1877
eth0: reg 0x0012 val 0x4100
eth0: reg 0x0016 val 0x0000
eth0: reg 0x0016 val 0x00ff
eth0: reg 0x0018 val 0xaa99
eth0: reg 0x0017 val 0x2011
eth0: reg 0x0018 val 0xa204
eth0: reg 0x0017 val 0x2002
eth0: reg 0x0016 val 0x0000
eth0: reg 0x0012 val 0x0800
sky2 eth0: phy interrupt status 0x1c40 0xbf48
eth0: reg 0x0012 val 0x6400
eth0: reg 0x0016 val 0x0003
eth0: reg 0x0010 val 0x1007
eth0: reg 0x0016 val 0x0000
sky2 eth0: Link is up at 1000 Mbps, full duplex, flow control both

Please let me know if there is any more useful information I can dig up.

Thanks,
-Andrew

------------------------------------------------------------------------

Linux 2.6.18-4

$ modprobe -r sky2
sky2 eth0: disabling interface
ACPI: PCI interrupt for device 0000:02:00.0 disabled

$ modprobe sky2 debug=16
PCI: Enabling device 0000:02:00.0 (0000 -> 0003)
ACPI: PCI Interrupt 0000:02:00.0[A] -> GSI 18 (level, low) -> IRQ 201
PCI: Setting latency timer of device 0000:02:00.0 to 64
sky2 v1.5 addr 0xfddfc000 irq 201 Yukon-EC Ultra (0xb4) rev 2
sky2 eth0: addr 00:0a:48:00:0a:53
sky2 eth0: enabling interface
ADDRCONF(NETDEV_UP): eth0: link is not ready
sky2 eth0: phy interrupt status 0x1c40 0xbf48
sky2 eth0: Link is up at 1000 Mbps, full duplex, flow control both
ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
eth0: tx queued, slot 0, len 90
eth0: tx done, up to 1
eth0: tx queued, slot 1, len 342
eth0: tx done, up to 2
sky2 eth0: rx slot 0 status 0x1560100 len 342
eth0: tx queued, slot 2, len 42
sky2 eth0: rx slot 1 status 0x3c0100 len 60
eth0: tx queued, slot 3, len 81
eth0: tx done, up to 3
sky2 eth0: rx slot 2 status 0x6d0100 len 109
eth0: tx done, up to 5
eth0: tx queued, slot 5, len 81
sky2 eth0: rx slot 3 status 0xbd0100 len 189
eth0: tx done, up to 7
... <continues for pages>

------------------------------------------------------------------------

Linux 2.6.23.13

$ modprobe -r sky2
sky2 eth0: disabling interface
ACPI: PCI interrupt for device 0000:02:00.0 disabled

$ modprobe sky2 debug=16
ACPI: PCI Interrupt 0000:02:00.0[A] -> GSI 18 (level, low) -> IRQ 20
PCI: Setting latency timer of device 0000:02:00.0 to 64
sky2 0000:02:00.0: v1.18 addr 0xfddfc000 irq 20 Yukon-EC Ultra (0xb4) rev 2
sky2 eth0: addr 00:0a:48:00:0a:53
sky2 eth0: enabling interface
sky2 eth0: phy interrupt status 0x1c40 0xbf08
sky2 eth0: Link is up at 1000 Mbps, full duplex, flow control both
sky2 eth0: rx slot 0 status 0x3c0300 len 60
sky2 eth0: rx slot 1 status 0xf30300 len 243
sky2 eth0: rx slot 2 status 0xf30300 len 243
sky2 eth0: rx slot 3 status 0x3c0300 len 60
sky2 eth0: rx slot 4 status 0x3c0300 len 60
... <hangs here, nothing else prints out from sky2>

------------------------------------------------------------------------

(printed from under 2.6.18-4)
# lspci -vv -s 02:00.0
02:00.0 Ethernet controller: Marvell Technology Group Ltd. Unknown
device 4364 (rev 12)
        Subsystem: Marvell Technology Group Ltd. Unknown device 5621
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
        Latency: 0, Cache Line Size: 4 bytes
        Interrupt: pin A routed to IRQ 225
        Region 0: Memory at fddfc000 (64-bit, non-prefetchable) [size=16K]
        Region 2: I/O ports at ee00 [size=256]
        [virtual] Expansion ROM at fdc00000 [disabled] [size=128K]
        Capabilities: [48] Power Management version 3
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA
PME(D0+,D1+,D2+,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=1 PME-
        Capabilities: [50] Vital Product Data
        Capabilities: [5c] Message Signalled Interrupts: Mask- 64bit+
Queue=0/0 Enable+
                Address: 00000000fee00000  Data: 40e1
        Capabilities: [e0] Express Legacy Endpoint IRQ 0
                Device: Supported: MaxPayload 128 bytes, PhantFunc 0, ExtTag-
                Device: Latency L0s unlimited, L1 unlimited
                Device: AtnBtn- AtnInd- PwrInd-
                Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
                Device: RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
                Device: MaxPayload 128 bytes, MaxReadReq 512 bytes
                Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s L1, Port 3
                Link: Latency L0s <256ns, L1 unlimited
                Link: ASPM Disabled RCB 128 bytes CommClk+ ExtSynch-
                Link: Speed 2.5Gb/s, Width x1
        Capabilities: [100] Advanced Error Reporting
