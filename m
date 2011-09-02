From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [Bugme-new] [Bug 42132] New: Support BCM5750M in tg3
Date: Fri, 2 Sep 2011 10:43:16 -0700
Message-ID: <20110902174316.GA6151@mcarlson.broadcom.com>
References: <bug-42132-10286@https.bugzilla.kernel.org/>
 <20110901164011.baa9a8b8.akpm@linux-foundation.org>
 <20110902000646.GA4910@mcarlson.broadcom.com>
 <CAA7bCn6DRmoqhHGBOAkaDqCdiYwrjPGuaYcck7n4+o3Lm10w2g@mail.gmail.com>
 <20110902010431.GA5105@mcarlson.broadcom.com>
 <CAA7bCn7Au+-QEa7hTwO_P_mnL1w5TiGPz4Wsm0CxtoqT3FDBbQ@mail.gmail.com>
 <20110902012514.GA5595@mcarlson.broadcom.com>
 <CAA7bCn5DJjrdZtyYN2g75Ty1=5s1Zcs5A4x0WksOM4oRLLaGOQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Matthew Carlson" <mcarlson@broadcom.com>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>,
	"Benjamin Li" <benli@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>
To: "Francesco Piccinno" <stack.box@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4904 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753713Ab1IBRne (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Sep 2011 13:43:34 -0400
In-Reply-To: <CAA7bCn5DJjrdZtyYN2g75Ty1=5s1Zcs5A4x0WksOM4oRLLaGOQ@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The output shows that the device's firmware isn't running.  Since the
firmware version also doesn't show up in the 'ethtool -i' output, it
might mean that firmware is completely missing.

You probably don't want to leave the device the way it is now.  I'd
contact your vendor to see if you can get your firmware reprogrammed.

On Fri, Sep 02, 2011 at 02:20:10AM -0700, Francesco Piccinno wrote:
> The patch did not apply cleanly. BTW I have figured out an alternative
> method. I modified by hand pci_ids.h and tg3.c files. The device seems
> to work now.
> 
> The output of ethtool -i eth0 gives me:
> driver: tg3
> version: 3.119
> firmware-version:
> bus-info: 0000:08:00.0
> supports-statistics: yes
> supports-test: yes
> supports-eeprom-access: yes
> supports-register-dump: yes
> 
> Messages produced by the driver:
> 
> [  728.741487] tg3 0000:08:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
> [  728.741498] tg3 0000:08:00.0: setting latency timer to 64
> [  728.819963] tg3 0000:08:00.0: vpd r/w failed.  This is likely a
> firmware bug on this device.  Contact the card vendor for a firmware
> update.
> [  728.879960] tg3 0000:08:00.0: vpd r/w failed.  This is likely a
> firmware bug on this device.  Contact the card vendor for a firmware
> update.
> [  728.939957] tg3 0000:08:00.0: vpd r/w failed.  This is likely a
> firmware bug on this device.  Contact the card vendor for a firmware
> update.
> [  728.942680] tg3 0000:08:00.0: eth0: Tigon3 [partno(none) rev 4201]
> (PCI Express) MAC address 00:1b:38:38:c6:60
> [  728.942685] tg3 0000:08:00.0: eth0: attached PHY is 5750
> (10/100/1000Base-T Ethernet) (WireSpeed[1], EEE[0])
> [  728.942689] tg3 0000:08:00.0: eth0: RXcsums[1] LinkChgREG[0]
> MIirq[0] ASF[0] TSOcap[1]
> [  728.942692] tg3 0000:08:00.0: eth0: dma_rwctrl[76180000] dma_mask[64-bit]
> [  728.949503] tg3 0000:08:00.0: irq 45 for MSI/MSI-X
> [  730.633610] tg3 0000:08:00.0: eth0: No firmware running
> [  730.650658] ADDRCONF(NETDEV_UP): eth0: link is not ready
> [  811.811298] tg3 0000:08:00.0: eth0: Link is up at 100 Mbps, full duplex
> [  811.811306] tg3 0000:08:00.0: eth0: Flow control is on for TX and on for RX
> 
> --
> Best regards,
> Francesco Piccinno
> 
> 
> 
> On Fri, Sep 2, 2011 at 3:25 AM, Matt Carlson <mcarlson@broadcom.com> wrote:
> > Yes. ??Sorry. ??Please revert that patch. ??If you really had a bcm5750,
> > you'd need to revert another patch too, but let's see where we stand
> > before going down that road.
> >
> > On Thu, Sep 01, 2011 at 06:14:57PM -0700, Francesco Piccinno wrote:
> >> The only message I get regarding the firmware is the following:
> >>
> >> [51503.038205] pci 0000:08:00.0: vpd r/w failed. ??This is likely a
> >> firmware bug on this device. ??Contact the card vendor for a firmware
> >> update.
> >>
> >> Unfortunately I can not post the output of ethtool since the interface
> >> is not available. Shall I recompile the tg3 module with the proper
> >> patch and post the output?
> >>
> >> --
> >> Best regards,
> >> Francesco Piccinno
> >>
> >> On Fri, Sep 2, 2011 at 3:04 AM, Matt Carlson <mcarlson@broadcom.com> wrote:
> >> > It's showing up on lspci as a PCIe device, so it can't be the 5750M.
> >> > The bcm5750M is a pci device.
> >> >
> >> > I'm wondering if bootcode is failing. ??Do you see any messages in your
> >> > syslogs that say "No firmware running"?
> >> >
> >> > Can you post the output of 'ethtool -i ethX'?
> >> >
> >> > On Thu, Sep 01, 2011 at 05:48:50PM -0700, Francesco Piccinno wrote:
> >> >> Yes sure.
> >> >>
> >> >> # lspci -vvv -s 08:00.0
> >> >> 08:00.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5750M
> >> >> Gigabit Ethernet
> >> >> ?? ?? ?? Subsystem: Broadcom Corporation NetXtreme BCM5750M Gigabit Ethernet
> >> >> ?? ?? ?? Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> >> >> Stepping- SERR- FastB2B- DisINTx-
> >> >> ?? ?? ?? Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> >> >> <TAbort- <MAbort- >SERR- <PERR- INTx-
> >> >> ?? ?? ?? Latency: 0, Cache Line Size: 64 bytes
> >> >> ?? ?? ?? Interrupt: pin A routed to IRQ 10
> >> >> ?? ?? ?? Region 0: Memory at f4100000 (64-bit, non-prefetchable) [size=64K]
> >> >> ?? ?? ?? Capabilities: [48] Power Management version 2
> >> >> ?? ?? ?? ?? ?? ?? ?? Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot+,D3cold+)
> >> >> ?? ?? ?? ?? ?? ?? ?? Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=1 PME-
> >> >> ?? ?? ?? Capabilities: [50] Vital Product Data
> >> >> pcilib: sysfs_read_vpd: read failed: Connection timed out
> >> >> ?? ?? ?? ?? ?? ?? ?? Not readable
> >> >> ?? ?? ?? Capabilities: [58] MSI: Enable- Count=1/8 Maskable- 64bit+
> >> >> ?? ?? ?? ?? ?? ?? ?? Address: 5149526521410124 ??Data: 8b60
> >> >> ?? ?? ?? Capabilities: [d0] Express (v1) Endpoint, MSI 00
> >> >> ?? ?? ?? ?? ?? ?? ?? DevCap: MaxPayload 512 bytes, PhantFunc 0, Latency L0s <4us, L1 unlimited
> >> >> ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ExtTag+ AttnBtn- AttnInd- PwrInd- RBE- FLReset-
> >> >> ?? ?? ?? ?? ?? ?? ?? DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
> >> >> ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
> >> >> ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? MaxPayload 128 bytes, MaxReadReq 512 bytes
> >> >> ?? ?? ?? ?? ?? ?? ?? DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+ TransPend-
> >> >> ?? ?? ?? ?? ?? ?? ?? LnkCap: Port #0, Speed 2.5GT/s, Width x1, ASPM L0s, Latency L0 <4us, L1 <64us
> >> >> ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ClockPM- Surprise- LLActRep- BwNot-
> >> >> ?? ?? ?? ?? ?? ?? ?? LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
> >> >> ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> >> >> ?? ?? ?? ?? ?? ?? ?? LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive-
> >> >> BWMgmt- ABWMgmt-
> >> >> ?? ?? ?? Capabilities: [100 v1] Advanced Error Reporting
> >> >> ?? ?? ?? ?? ?? ?? ?? UESta: ??DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF-
> >> >> MalfTLP- ECRC- UnsupReq- ACSViol-
> >> >> ?? ?? ?? ?? ?? ?? ?? UEMsk: ??DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF-
> >> >> MalfTLP- ECRC- UnsupReq- ACSViol-
> >> >> ?? ?? ?? ?? ?? ?? ?? UESvrt: DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+
> >> >> MalfTLP+ ECRC- UnsupReq- ACSViol-
> >> >> ?? ?? ?? ?? ?? ?? ?? CESta: ??RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
> >> >> ?? ?? ?? ?? ?? ?? ?? CEMsk: ??RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
> >> >> ?? ?? ?? ?? ?? ?? ?? AERCap: First Error Pointer: 00, GenCap+ CGenEn- ChkCap+ ChkEn-
> >> >> ?? ?? ?? Capabilities: [13c v1] Virtual Channel
> >> >> ?? ?? ?? ?? ?? ?? ?? Caps: ?? LPEVC=0 RefClk=100ns PATEntryBits=1
> >> >> ?? ?? ?? ?? ?? ?? ?? Arb: ?? ??Fixed- WRR32- WRR64- WRR128-
> >> >> ?? ?? ?? ?? ?? ?? ?? Ctrl: ?? ArbSelect=Fixed
> >> >> ?? ?? ?? ?? ?? ?? ?? Status: InProgress-
> >> >> ?? ?? ?? ?? ?? ?? ?? VC0: ?? ??Caps: ?? PATOffset=00 MaxTimeSlots=1 RejSnoopTrans-
> >> >> ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? Arb: ?? ??Fixed- WRR32- WRR64- WRR128- TWRR128- WRR256-
> >> >> ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? Ctrl: ?? Enable+ ID=0 ArbSelect=Fixed TC/VC=01
> >> >> ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? ?? Status: NegoPending- InProgress-
> >> >> ?? ?? ?? Capabilities: [160 v1] Device Serial Number 00-00-00-ff-fe-00-00-00
> >> >>
> >> >> Serial number is CND71700K6.
> >> >> --
> >> >> Best regards,
> >> >> Francesco Piccinno
> >> >>
> >> >>
> >> >>
> >> >> On Fri, Sep 2, 2011 at 2:06 AM, Matt Carlson <mcarlson@broadcom.com> wrote:
> >> >> > On Thu, Sep 01, 2011 at 04:40:11PM -0700, Andrew Morton wrote:
> >> >> >>
> >> >> >> (switched to email. ??Please respond via emailed reply-to-all, not via the
> >> >> >> bugzilla web interface).
> >> >> >>
> >> >> >> On Wed, 31 Aug 2011 18:18:40 GMT
> >> >> >> bugzilla-daemon@bugzilla.kernel.org wrote:
> >> >> >>
> >> >> >> > https://bugzilla.kernel.org/show_bug.cgi?id=42132
> >> >> >> >
> >> >> >> > ?? ?? ?? ?? ?? ??Summary: Support BCM5750M in tg3
> >> >> >> > ?? ?? ?? ?? ?? ??Product: Drivers
> >> >> >> > ?? ?? ?? ?? ?? ??Version: 2.5
> >> >> >> > ?? ?? Kernel Version: 3.0.3
> >> >> >> > ?? ?? ?? ?? ?? Platform: All
> >> >> >> > ?? ?? ?? ?? OS/Version: Linux
> >> >> >> > ?? ?? ?? ?? ?? ?? ?? Tree: Mainline
> >> >> >> > ?? ?? ?? ?? ?? ?? Status: NEW
> >> >> >> > ?? ?? ?? ?? ?? Severity: normal
> >> >> >> > ?? ?? ?? ?? ?? Priority: P1
> >> >> >> > ?? ?? ?? ?? ??Component: Network
> >> >> >> > ?? ?? ?? ?? AssignedTo: drivers_network@kernel-bugs.osdl.org
> >> >> >> > ?? ?? ?? ?? ReportedBy: stack.box@gmail.com
> >> >> >> > ?? ?? ?? ?? Regression: Yes
> >> >> >> >
> >> >> >> >
> >> >> >> > I have a notebook (HP TC4400) which has a BCM5750 ethernet card inside. The
> >> >> >> > ouput of lspci is:
> >> >> >> >
> >> >> >> > 08:00.0 Ethernet controller [0200]: Broadcom Corporation NetXtreme BCM5750M
> >> >> >> > Gigabit Ethernet [14e4:167c]
> >> >> >> >
> >> >> >> > Commit 67b284d476bcb3d100e946da23d6cf9acfd0465c removed the support for this
> >> >> >> > device.
> >> >> >> >
> >> >> >>
> >> >> >> 67b284d476bcb3d100 says "These devices were never released to the public".
> >> >> >>
> >> >> >> > I wish to have the support for this network card back again. Thanks!
> >> >> >>
> >> >> >> oops ;)
> >> >> >
> >> >> > Really? ??All the TC4400 documentation I find says it uses a bcm5753M on a
> >> >> > PCIe bus. ??Can you post the full output of 'lspci -vvv -s 08:00.0' ?
> >> >> >
> >> >> >
> >> >>
> >> >
> >> >
> >>
> >
> >
> 
