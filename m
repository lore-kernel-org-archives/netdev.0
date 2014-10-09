From: Eric Wheeler <netdev@lists.ewheeler.net>
Subject: RE: [PATCH net] bna: page allocation during interrupts to use a
 mempool.
Date: Wed, 8 Oct 2014 17:50:24 -0700 (PDT)
Message-ID: <alpine.DEB.2.00.1410081746100.18846@ware.dreamhost.com>
References: <alpine.DEB.2.00.1409271631530.26069@ware.dreamhost.com>    <20140929092833.6c2cb7e9@urahara>    <262CB373A6D1F14F9B81E82F74F77D5A4704FAE7@avmb2.qlogic.org>    <alpine.DEB.2.00.1410061850120.5129@ware.dreamhost.com>  
 <1412646735.11091.93.camel@edumazet-glaptop2.roam.corp.google.com>   <alpine.DEB.2.00.1410061956410.7392@ware.dreamhost.com>  <1412651746.11091.98.camel@edumazet-glaptop2.roam.corp.google.com>  <alpine.DEB.2.00.1410071746230.3503@ware.dreamhost.com>
 <1412731718.11091.175.camel@edumazet-glaptop2.roam.corp.google.com> <2552F74A0BCCBE4DBE2AD218C81B2811C6399B@avmb3.qlogic.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>
To: Rasesh Mody <rasesh.mody@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from homie.mail.dreamhost.com ([208.97.132.208]:56056 "EHLO
	homiemail-a9.g.dreamhost.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752719AbaJIAeo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2014 20:34:44 -0400
In-Reply-To: <2552F74A0BCCBE4DBE2AD218C81B2811C6399B@avmb3.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 8 Oct 2014, Rasesh Mody wrote:

> Hi Eric Wheeler, Eric Dumazet,
>
> We'll try to reproduce the issue in-house to find more about the root 
> cause of the failure and work on possible solution.

Thanks Rasesh,

FYI, we're using the Ethernet part this card (no FCoE use here); I believe 
it is the 1020 version:

02:00.0 Fibre Channel: Brocade Communications Systems, Inc. 1010/1020/1007/1741 10Gbps CNA (rev 01)
02:00.1 Fibre Channel: Brocade Communications Systems, Inc. 1010/1020/1007/1741 10Gbps CNA (rev 01)
02:00.2 Ethernet controller: Brocade Communications Systems, Inc. 1010/1020/1007/1741 10Gbps CNA (rev 01)
02:00.3 Ethernet controller: Brocade Communications Systems, Inc. 1010/1020/1007/1741 10Gbps CNA (rev 01)


02:00.2 Ethernet controller: Brocade Communications Systems, Inc. 1010/1020/1007/1741 10Gbps CNA (rev 01)
         Subsystem: Brocade Communications Systems, Inc. 1010/1020/1007/1741 10Gbps CNA - LL
         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
         Latency: 0, Cache Line Size: 64 bytes
         Interrupt: pin A routed to IRQ 19
         Region 0: Memory at df540000 (64-bit, non-prefetchable) [size=256K]
         Region 2: Memory at df604000 (64-bit, non-prefetchable) [size=16K]
         Expansion ROM at df200000 [disabled] [size=1M]
         Capabilities: [40] Power Management version 3
                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold-)
                 Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=1 PME-
         Capabilities: [50] MSI-X: Enable+ Count=256 Masked-
                 Vector table: BAR=2 offset=00000000
                 PBA: BAR=2 offset=00002000
         Capabilities: [60] Express (v2) Endpoint, MSI 00
                 DevCap: MaxPayload 2048 bytes, PhantFunc 0, Latency L0s <256ns, L1 <64us
                         ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
                 DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
                         RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop+
                         MaxPayload 128 bytes, MaxReadReq 512 bytes
                 DevSta: CorrErr+ UncorrErr- FatalErr- UnsuppReq+ AuxPwr- TransPend-
                 LnkCap: Port #0, Speed 5GT/s, Width x8, ASPM L0s, Latency L0 <256ns, L1 <64us
                         ClockPM- Surprise- LLActRep- BwNot-
                 LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk+
                         ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                 LnkSta: Speed 5GT/s, Width x4, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
                 DevCap2: Completion Timeout: Range ABCD, TimeoutDis+, LTR-, OBFF Not Supported
                 DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis-, LTR-, OBFF Disabled
                 LnkSta2: Current De-emphasis Level: -6dB, EqualizationComplete-, EqualizationPhase1-
                          EqualizationPhase2-, EqualizationPhase3-, LinkEqualizationRequest-
         Capabilities: [a0] Vital Product Data
                 No end tag found
         Capabilities: [100 v1] Advanced Error Reporting
                 UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
                 UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
                 UESvrt: DLP+ SDES+ TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
                 CESta:  RxErr+ BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
                 CEMsk:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
                 AERCap: First Error Pointer: 00, GenCap+ CGenEn- ChkCap+ ChkEn-
         Capabilities: [180 v1] Power Budgeting <?>
         Capabilities: [190 v1] Alternative Routing-ID Interpretation (ARI)
                 ARICap: MFVC- ACS-, Next Function: 3
                 ARICtl: MFVC- ACS-, Function Group: 0
         Kernel driver in use: bna
         Kernel modules: bna


--
Eric Wheeler, President           eWheeler, Inc. dba Global Linux Security
888-LINUX26 (888-546-8926)        Fax: 503-716-3878           PO Box 25107
www.GlobalLinuxSecurity.pro       Linux since 1996!     Portland, OR 97298


>
> Thanks,
> -Rasesh
