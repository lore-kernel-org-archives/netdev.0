From: "Allan, Bruce W" <bruce.w.allan@intel.com>
Subject: RE: [PATCH] e1000e: workaround missing power down mii control bit
 on 82571
Date: Wed, 22 Dec 2010 12:25:10 -0800
Message-ID: <8DD2590731AB5D4C9DBF71A877482A9001775662DF@orsmsx509.amr.corp.intel.com>
References: <20101216182847.GA14985@ajones-laptop.nbttech.com>
 <1292525797.3253.8.camel@bwh-desktop>
 <8DD2590731AB5D4C9DBF71A877482A9001773F7655@orsmsx509.amr.corp.intel.com>
 <8DD2590731AB5D4C9DBF71A877482A9001773F76C4@orsmsx509.amr.corp.intel.com>
 <20101216200425.GO18990@ajones-laptop.nbttech.com>
 <20101216221421.GR18990@ajones-laptop.nbttech.com>
 <8DD2590731AB5D4C9DBF71A877482A9001773F7AD6@orsmsx509.amr.corp.intel.com>
 <20101217140453.GS18990@ajones-laptop.nbttech.com>
 <8DD2590731AB5D4C9DBF71A877482A9001773F7BFC@orsmsx509.amr.corp.intel.com>
 <20101220153301.GV18990@ajones-laptop.nbttech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: Arthur Jones <arthur.jones@riverbed.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:31360 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751081Ab0LVUZa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Dec 2010 15:25:30 -0500
In-Reply-To: <20101220153301.GV18990@ajones-laptop.nbttech.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On
>Behalf Of Arthur Jones
>Sent: Monday, December 20, 2010 7:33 AM
>To: Allan, Bruce W
>Cc: Ben Hutchings; Kirsher, Jeffrey T; netdev@vger.kernel.org
>Subject: Re: [PATCH] e1000e: workaround missing power down mii control bit on
>82571
>
>Interesting!  So then you're not able to
>repro the issue that I describe in the
>patch then either?
>
>This was an 82571?  Can you send along
>the firmware revision and the full lspci
>for the NIC where it works to read back
>the power down bit?  Very strange...

No, I _am_ able to reproduce the issue you reported (i.e. Phy powered on
after changing settings via ethtool on a down interface) which as I said
is caused by the deep reset.  However, I do not see any problem with
writing the power down bit in the Phy control register.  I have a fix
for this but want it tested on a number of adapters supported by the
driver before sending it out.

The 82571 dual-port adapter I am using has firmware version 5.11-2 and its
lspci output is:

06:00.1 Ethernet controller: Intel Corporation 82571EB Gigabit Ethernet Controller (rev 06)
        Subsystem: Intel Corporation PRO/1000 PT Dual Port Server Adapter
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0, Cache Line Size: 64 bytes
        Interrupt: pin B routed to IRQ 55
        Region 0: Memory at 48f20000 (32-bit, non-prefetchable) [size=128K]
        Region 1: Memory at 48f00000 (32-bit, non-prefetchable) [size=128K]
        Region 2: I/O ports at 4000 [size=32]
        Expansion ROM at 49a20000 [disabled] [size=128K]
        Capabilities: [c8] Power Management version 2
                Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
                Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=1 PME-
        Capabilities: [d0] MSI: Enable+ Count=1/1 Maskable- 64bit+
                Address: 00000000fee0300c  Data: 41e1
        Capabilities: [e0] Express (v1) Endpoint, MSI 00
                DevCap: MaxPayload 256 bytes, PhantFunc 0, Latency L0s <512ns, L1 <64us
                        ExtTag- AttnBtn- AttnInd- PwrInd- RBE- FLReset-
                DevCtl: Report errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
                        RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
                        MaxPayload 128 bytes, MaxReadReq 512 bytes
                DevSta: CorrErr- UncorrErr+ FatalErr- UnsuppReq+ AuxPwr+ TransPend-
                LnkCap: Port #0, Speed 2.5GT/s, Width x4, ASPM L0s, Latency L0 <4us, L1 <64us
                        ClockPM- Surprise- LLActRep- BwNot-
                LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
                        ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                LnkSta: Speed 2.5GT/s, Width x4, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
        Capabilities: [100 v1] Advanced Error Reporting
                UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq+ ACSViol-
                UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
                UESvrt: DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
                CESta:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
                CEMsk:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
                AERCap: First Error Pointer: 14, GenCap- CGenEn- ChkCap- ChkEn-
        Capabilities: [140 v1] Device Serial Number xx-xx-xx-xx-xx-xx-xx-xx
        Kernel driver in use: e1000e
        Kernel modules: e1000e
