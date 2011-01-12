From: Stephen Clark <sclark46@earthlink.net>
Subject: Re: panic in tg3 driver
Date: Wed, 12 Jan 2011 08:53:36 -0500
Message-ID: <4D2DB260.7080509@earthlink.net>
References: <4D2334B5.1060408@earthlink.net> <4D2A371A.40103@earthlink.net> <20110110192216.GA23741@mcarlson.broadcom.com> <4D2B6652.7040607@earthlink.net> <20110111020055.GA25351@mcarlson.broadcom.com> <4D2C64EF.1080905@earthlink.net> <20110112030652.GA27164@mcarlson.broadcom.com>
Reply-To: sclark46@earthlink.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-mealy.atl.sa.earthlink.net ([209.86.89.69]:40794 "EHLO
	elasmtp-mealy.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752157Ab1ALNxm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jan 2011 08:53:42 -0500
In-Reply-To: <20110112030652.GA27164@mcarlson.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/11/2011 10:06 PM, Matt Carlson wrote:
> lspci -vvv -xxx -s 81:00.0

Linux Z1010.netwolves.com 2.6.37 #9 SMP PREEMPT Wed Jan 5 11:14:46 EST 
2011 i686
i686 i386 GNU/Linux

[root@Z1010 ~]# lspci -vvv -xxx -s 81:00.0
81:00.0 Ethernet controller: Broadcom Corporation NetLink BCM5906M Fast 
Ethernet
PCI Express (rev 02)
         Subsystem: Broadcom Corporation Unknown device 9713
         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- 
ParErr- Stepp
ing- SERR- FastB2B-
         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <
MAbort- >SERR- <PERR-
         Latency: 0, Cache Line Size: 64 bytes
         Interrupt: pin A routed to IRQ 10
         Region 0: Memory at cfbf0000 (64-bit, non-prefetchable) [size=64K]
         Capabilities: [48] Power Management version 3
                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA 
PME(D0-,D1-,D2-,D3hot+
,D3cold+)
                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
         Capabilities: [50] Vital Product Data
         Capabilities: [58] Vendor Specific Information
         Capabilities: [e8] Message Signalled Interrupts: 64bit+ 
Queue=0/0 Enable-
                 Address: 00000000fee0100c  Data: 4169
         Capabilities: [d0] Express Endpoint IRQ 0
                 Device: Supported: MaxPayload 128 bytes, PhantFunc 0, 
ExtTag+
                 Device: Latency L0s <4us, L1 unlimited
                 Device: AtnBtn- AtnInd- PwrInd-
                 Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
                 Device: RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
                 Device: MaxPayload 128 bytes, MaxReadReq 512 bytes
                 Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s L1, 
Port 0
                 Link: Latency L0s <4us, L1 <64us
                 Link: ASPM Disabled RCB 64 bytes CommClk- ExtSynch-
                 Link: Speed 2.5Gb/s, Width x1
         Capabilities: [100] Advanced Error Reporting
         Capabilities: [13c] Virtual Channel
         Capabilities: [160] Device Serial Number 39-d1-36-fe-ff-b6-02-00
00: e4 14 13 17 06 00 10 00 02 00 00 02 10 00 00 00
10: 04 00 bf cf 00 00 00 00 00 00 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 e4 14 13 97
30: 00 00 00 00 48 00 00 00 00 00 00 00 0a 01 00 00
40: 00 00 00 00 00 00 00 00 01 50 03 c0 08 00 00 00
50: 03 58 fc 00 78 00 00 00 09 e8 78 00 64 2f 72 64
60: 00 00 00 00 00 00 00 00 00 00 02 c0 00 00 00 00
70: 12 12 00 00 a0 00 00 00 00 00 00 00 00 00 00 00
80: 00 00 00 00 00 00 00 00 00 00 00 00 fe 50 08 24
90: 01 92 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 10 00 01 00 a0 8f 64 00 00 20 10 00 11 6c 03 00
e0: 00 00 11 10 00 00 00 00 05 d0 80 00 0c 10 e0 fe
f0: 00 00 00 00 69 41 00 00 00 00 00 00 00 00 00 00

modprobe tg3

dmesg output:
tg3.c:v3.115 (October 14, 2010)
tg3 0000:81:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
tg3 0000:81:00.0: setting latency timer to 64
tg3 0000:81:00.0: PCI: Disallowing DAC for device
tg3 0000:81:00.0: eth2: Tigon3 [partno(BCM95906) rev c002] (PCI Express) 
MAC addr
ess 00:02:b6:36:d1:39
tg3 0000:81:00.0: eth2: attached PHY is 5906 (10/100Base-TX Ethernet) 
(WireSpeed[
0])
tg3 0000:81:00.0: eth2: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] TSOcap[1]
tg3 0000:81:00.0: eth2: dma_rwctrl[76180000] dma_mask[32-bit]
tg3 0000:82:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
tg3 0000:82:00.0: setting latency timer to 64
tg3 0000:82:00.0: PCI: Disallowing DAC for device
tg3 0000:82:00.0: eth3: Tigon3 [partno(BCM95906) rev c002] (PCI Express) 
MAC addr
ess 00:02:b6:36:d1:3a
tg3 0000:82:00.0: eth3: attached PHY is 5906 (10/100Base-TX Ethernet) 
(WireSpeed[
0])
tg3 0000:82:00.0: eth3: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] TSOcap[1]
tg3 0000:82:00.0: eth3: dma_rwctrl[76180000] dma_mask[32-bit]

[root@Z1010 ~]# ethtool -i eth2
driver: tg3
version: 3.115
firmware-version: sb v3.03
bus-info: 0000:81:00.0

[root@Z1010 ~]# cat /proc/interrupts
            CPU0
   0:        173   IO-APIC-edge      timer
   1:          2   IO-APIC-edge      i8042
   4:       2864   IO-APIC-edge      serial
   6:          2   IO-APIC-edge      floppy
   8:          0   IO-APIC-edge      rtc0
   9:          0   IO-APIC-fasteoi   acpi
  14:          0   IO-APIC-edge      pata_via
  15:       8100   IO-APIC-edge      pata_via
  16:        984   IO-APIC-fasteoi   eth0
  17:        104   IO-APIC-fasteoi   eth1
  20:          0   IO-APIC-fasteoi   uhci_hcd:usb2
  21:          0   IO-APIC-fasteoi   uhci_hcd:usb4, sata_via
  22:          0   IO-APIC-fasteoi   ehci_hcd:usb1, uhci_hcd:usb3
  23:          0   IO-APIC-fasteoi   uhci_hcd:usb5
NMI:          0   Non-maskable interrupts
LOC:     101963   Local timer interrupts
SPU:          0   Spurious interrupts
PMI:          0   Performance monitoring interrupts
IWI:          0   IRQ work interrupts
RES:          0   Rescheduling interrupts
CAL:          0   Function call interrupts
TLB:          0   TLB shootdowns
TRM:          0   Thermal event interrupts
THR:          0   Threshold APIC interrupts
MCE:          0   Machine check exceptions
MCP:          0   Machine check polls
ERR:          0
MIS:          0

The b44 interfaces are working great.

[root@Z1010 ~]# ifconfig eth2 up
do_IRQ: 0.64 No irq handler for vector (irq -1)

system becomes unresponsive then ususally
reboots.

but it didn't this last time just has become really doggy in
responding
[root@Z1010 ~]#
[root@Z1010 ~]#
[root@Z1010 ~]# ifconfig
eth0      Link encap:Ethernet  HWaddr 00:02:B6:36:D1:37
           inet addr:10.0.129.4  Bcast:10.0.255.255  Mask:255.255.128.0
           inet6 addr: fe80::202:b6ff:fe36:d137/64 Scope:Link
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:1025 errors:0 dropped:12 overruns:0 frame:0
           TX packets:6 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:185675 (181.3 KiB)  TX bytes:492 (492.0 b)
           Interrupt:16

eth1      Link encap:Ethernet  HWaddr 00:02:B6:36:D1:38
           inet6 addr: fe80::202:b6ff:fe36:d138/64 Scope:Link
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:35 errors:0 dropped:0 overruns:0 frame:0
           TX packets:41 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:2612 (2.5 KiB)  TX bytes:4014 (3.9 KiB)
           Interrupt:17

eth2      Link encap:Ethernet  HWaddr 00:02:B6:36:D1:39
           UP BROADCAST MULTICAST  MTU:1500  Metric:1
           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
           TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)
           Interrupt:16

lo        Link encap:Local Loopback
           inet addr:127.0.0.1  Mask:255.0.0.0
           inet6 addr: ::1/128 Scope:Host
           UP LOOPBACK RUNNING  MTU:16436  Metric:1
           RX packets:5298 errors:0 dropped:0 overruns:0 frame:0
           TX packets:5298 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:0
           RX bytes:475525 (464.3 KiB)  TX bytes:475525 (464.3 KiB)


Message from syslogd@ at Wed Jan 12 08:44:17 2011 ...
localhost kernel: do_IRQ: 0.192 No irq handler for vector (irq -1)

Message from syslogd@ at Wed Jan 12 08:44:17 2011 ...
localhost kernel: do_IRQ: 0.64 No irq handler for vector (irq -1)
[root@Z1010 ~]# cat /proc/interrupts
            CPU0
   0:        173   IO-APIC-edge      timer
   1:          2   IO-APIC-edge      i8042
   4:        821   IO-APIC-edge      serial
   6:          2   IO-APIC-edge      floppy
   8:          0   IO-APIC-edge      rtc0
   9:          2   IO-APIC-fasteoi   acpi
  14:          0   IO-APIC-edge      pata_via
  15:      19522   IO-APIC-edge      pata_via
  16:        256   IO-APIC-fasteoi   eth0, eth2
  17:         54   IO-APIC-fasteoi   eth1
  20:          0   IO-APIC-fasteoi   uhci_hcd:usb2
  21:          0   IO-APIC-fasteoi   uhci_hcd:usb4, sata_via
  22:          0   IO-APIC-fasteoi   ehci_hcd:usb1, uhci_hcd:usb3
  23:          0   IO-APIC-fasteoi   uhci_hcd:usb5
NMI:          0   Non-maskable interrupts
LOC:     116090   Local timer interrupts
SPU:          0   Spurious interrupts
PMI:          0   Performance monitoring interrupts
IWI:          0   IRQ work interrupts
RES:          0   Rescheduling interrupts
CAL:          0   Function call interrupts
TLB:          0   TLB shootdowns
TRM:          0   Thermal event interrupts
THR:          0   Threshold APIC interrupts
MCE:          0   Machine check exceptions
MCP:          0   Machine check polls
ERR:         38
MIS:          2
[root@Z1010 ~]# arp -an

the system has now lost ethernet connectivity via the b44 ports


This is a test system and I can recompile the kernel if there are
any patches you would like me to try out.







