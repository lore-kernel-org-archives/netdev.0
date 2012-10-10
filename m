From: Justin Chudgar <justin@justinzane.com>
Subject: Fwd: [Bug 1063038] Re: Broadcom BCM57780 Cannot Connect at Gigabit
 Speed using tg3 module.
Date: Wed, 10 Oct 2012 05:24:35 -0700
Message-ID: <50756903.1030709@justinzane.com>
References: <20121009143846.2196.28573.malone@chaenomeles.canonical.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070909040008020709070507"
Cc: 1063038@bugs.launchpad.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tiny.justinzane.com ([216.7.117.181]:35908 "EHLO
	happy.justinzane.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752916Ab2JJMbP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2012 08:31:15 -0400
Received: from happy.justinzane.com (media01 [192.168.0.50])
	by happy.justinzane.com (Postfix) with ESMTP id 1907E180195B9
	for <netdev@vger.kernel.org>; Wed, 10 Oct 2012 05:24:38 -0700 (PDT)
In-Reply-To: <20121009143846.2196.28573.malone@chaenomeles.canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070909040008020709070507
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

I've got a device with a Broadcom 57780 ethernet NIC. It uses the tg3.ko
driver module. The problem is that this NIC cannot connect at gigabit
(1000MBps) speed. In all cases connection works well at 100MBps. I
reported this to Ubuntu as noted below and was directed here.
[https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1063038] Following
are the tests I've completed:

- Cables tested with cable tester
- Cables tested to work at gigabit speed with Realtek and Intel gigabit
NICs.
- All unmanaged switch ports tested at gigabit speed with other NICs.
- Tried to connect with NetworkManager enabled and disabled.
- Tried both dhcp and static connections.
- Tried to renegotiate connection with `ethtool -r` both with TSO
enabled and disabled.
- Tried 3.2.0-23-generic 3.5.0-15-generic3.5.0-17-generic
3.6.0-999-generic kernels from main, xorg-edgers and mainline repos.
- Used 'tg3_debug=1' kernel option in grub with the following output:

    [ 0.000000] Command line: BOOT_IMAGE=/vmlinuz-3.5.0-17-generic
root=UUID=eccabacd-efb2-45b4-b7a6-2f530d50afd3 ro rootflags=subvol=@
tg3_debug=1 i915_enable_rc6=7 i915_enable_fbc=1 lvds_downclock=1
    [ 0.000000] Kernel command line:
BOOT_IMAGE=/vmlinuz-3.5.0-17-generic
root=UUID=eccabacd-efb2-45b4-b7a6-2f530d50afd3 ro rootflags=subvol=@
tg3_debug=1 i915_enable_rc6=7 i915_enable_fbc=1 lvds_downclock=1
    [ 5.963136] tg3.c:v3.123 (March 21, 2012)
    [ 5.995781] tg3 mdio bus: probed
    [ 6.005583] tg3 0000:01:00.0: >eth0: Tigon3 [partno(BCM57780) rev
57780001] (PCI Express) MAC address dc:0e:a1:ac:38:d5
    [ 6.005687] tg3 0000:01:00.0: >eth0: attached PHY driver [Broadcom
BCM57780] (mii_bus:phy_addr=100:01)
    [ 6.005790] tg3 0000:01:00.0: >eth0: RXcsums[1] LinkChgREG[0]
MIirq[0] ASF[0] TSOcap[1]
    [ 6.005887] tg3 0000:01:00.0: >eth0: dma_rwctrl[76180000]
dma_mask[64-bit]
    [ 294.987653] tg3 0000:01:00.0: >irq 44 for MSI/MSI-X
    [ 295.893224] tg3 0000:01:00.0: >eth0: Link is down
    [ 309.887879] tg3 0000:01:00.0: >eth0: Link is up at 100 Mbps, full
duplex
    [ 309.887886] tg3 0000:01:00.0: >eth0: Flow control is on for TX and
on for RX

Other distros' forums suggest loading broadcom.ko first; however, this
module is no present. Any suggestions would be much appreciated.

lspci -vv:
    01:00.0 Ethernet controller: Broadcom Corporation NetLink BCM57780
Gigabit Ethernet PCIe (rev 01)
        Subsystem: Acer Incorporated [ALI] Device 0601
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx+
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0, Cache Line Size: 64 bytes
        Interrupt: pin A routed to IRQ 44
        Region 0: Memory at d3400000 (64-bit, non-prefetchable) [size=64K]
        Capabilities: [48] Power Management version 3
                Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
PME(D0-,D1-,D2-,D3hot+,D3cold+)

                Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=1 PME-
        Capabilities: [60] Vendor Specific Information: Len=6c <?>
        Capabilities: [50] MSI: Enable+ Count=1/1 Maskable- 64bit+
                Address: 00000000fee0100c Data: 4189
        Capabilities: [cc] Express (v2) Endpoint, MSI 00
                DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s
<4us, L1 unlimited
                        ExtTag+ AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
                DevCtl: Report errors: Correctable- Non-Fatal- Fatal-
Unsupported-
                        RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
                        MaxPayload 128 bytes, MaxReadReq 512 bytes
                DevSta: CorrErr+ UncorrErr- FatalErr- UnsuppReq- AuxPwr+
TransPend+
                LnkCap: Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1,
Latency L0 <1us, L1 <32us
                        ClockPM+ Surprise- LLActRep- BwNot-
                LnkCtl: ASPM L0s L1 Enabled; RCB 64 bytes Disabled-
Retrain- CommClk+
                        ExtSynch- ClockPM+ AutWidDis- BWInt- AutBWInt-
                LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+
DLActive- BWMgmt- ABWMgmt-
                DevCap2: Completion Timeout: Range ABCD, TimeoutDis+
                DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-
                LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance-
SpeedDis-, Selectable De-emphasis: -6dB
                         Transmit Margin: Normal Operating Range,
EnterModifiedCompliance- ComplianceSOS-
                         Compliance De-emphasis: -6dB
                LnkSta2: Current De-emphasis Level: -6dB
        Capabilities: [100 v1] Advanced Error Reporting
                UESta: DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt-
UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
                UEMsk: DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt-
UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
                UESvrt: DLP+ SDES+ TLP- FCP+ CmpltTO- CmpltAbrt-
UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
                CESta: RxErr+ BadTLP- BadDLLP- Rollover- Timeout-
NonFatalErr-
                CEMsk: RxErr- BadTLP- BadDLLP- Rollover- Timeout-
NonFatalErr+
                AERCap: First Error Pointer: 00, GenCap+ CGenEn- ChkCap+
ChkEn-
        Capabilities: [13c v1] Virtual Channel
                Caps: LPEVC=0 RefClk=100ns PATEntryBits=1
                Arb: Fixed- WRR32- WRR64- WRR128-
                Ctrl: ArbSelect=Fixed
                Status: InProgress-
                VC0: Caps: PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
                        Arb: Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
                        Ctrl: Enable+ ID=0 ArbSelect=Fixed TC/VC=ff
                        Status: NegoPending- InProgress-
        Capabilities: [160 v1] Device Serial Number dc-0e-a1-ff-fe-ac-38-d5
        Capabilities: [16c v1] Power Budgeting <?>
        Kernel driver in use: tg3
        Kernel modules: tg3
---


Justin Chudgar  |  Weed, CA 96094  |  530 921 0738 | http://www.justinzane.com/

-------- Original Message --------
Subject: 	[Bug 1063038] Re: Broadcom BCM57780 Cannot Connect at Gigabit
Speed using tg3 module.
Date: 	Tue, 09 Oct 2012 14:38:45 -0000
From: 	Joseph Salisbury <joseph.salisbury@canonical.com>
Reply-To: 	Bug 1063038 <1063038@bugs.launchpad.net>
To: 	justin@justinzane.com



This issue appears to be an upstream bug, since you tested the latest
upstream kernel.  Would it be possible for you to open an upstream bug
report[0]?  That will allow the upstream Developers to examine the
issue, and may provide a quicker resolution to the bug.

Please follow the instructions on the wiki page[0].  The first step is
to email the appropriate mailing list.  If no response is received, then
a bug may be opened on bugzilla.kernel.org.

[0] https://wiki.ubuntu.com/Bugs/Upstream/kernel


** Changed in: linux (Ubuntu)
       Status: Confirmed => Triaged

** Changed in: linux (Ubuntu)
   Importance: Undecided => Medium

** Tags added: kernel-bug-exists-upstream

-- 
You received this bug notification because you are subscribed to the bug
report.
https://bugs.launchpad.net/bugs/1063038

Title:
  Broadcom BCM57780 Cannot Connect at Gigabit Speed using tg3 module.

To manage notifications about this bug go to:
https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1063038/+subscriptions





--------------070909040008020709070507
Content-Type: text/x-vcard; charset=utf-8;
 name="justin.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="justin.vcf"

begin:vcard
fn:Justin Chudgar
n:Chudgar;Justin
email;internet:justin@justinzane.com
tel;cell:530-921-0738
x-mozilla-html:FALSE
version:2.1
end:vcard


--------------070909040008020709070507--
