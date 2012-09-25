From: Jean-Michel Hautbois <jhautbois@gmail.com>
Subject: Re: bnx2x: link detected up at startup even when it should be down
Date: Tue, 25 Sep 2012 10:11:25 +0200
Message-ID: <CAL8zT=gp5uZ-Q36=vw--j35txrnLRhguoiMHi8a1kzX=VC3nJg@mail.gmail.com>
References: <CAL8zT=hFPQ-NZw8eKQwnktRrcpsOFk3aa_ac5mSWa+TAwyTGBQ@mail.gmail.com>
 <504C9EFCA2D0054393414C9CB605C37F2EB97C@SJEXCHMB06.corp.ad.broadcom.com>
 <CAL8zT=i_eV3SjuBgdWrBPaE-CoBBVh5QJD8jg-YMoQHDuA4AOQ@mail.gmail.com>
 <504C9EFCA2D0054393414C9CB605C37F2F1B50@SJEXCHMB06.corp.ad.broadcom.com> <504C9EFCA2D0054393414C9CB605C37F3079E4@SJEXCHMB06.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Barak Witkowski <barak@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Dmitry Kravkov <dmitry@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:39175 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753657Ab2IYILq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Sep 2012 04:11:46 -0400
Received: by ieak13 with SMTP id k13so13197136iea.19
        for <netdev@vger.kernel.org>; Tue, 25 Sep 2012 01:11:45 -0700 (PDT)
In-Reply-To: <504C9EFCA2D0054393414C9CB605C37F3079E4@SJEXCHMB06.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/9/25 Dmitry Kravkov <dmitry@broadcom.com>:
>> -----Original Message-----
>> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
>> On Behalf Of Dmitry Kravkov
>> Sent: Friday, September 21, 2012 10:23 PM
>> To: Jean-Michel Hautbois
>> Cc: netdev; Barak Witkowski; Eilon Greenstein; davem@davemloft.net
>> Subject: RE: bnx2x: link detected up at startup even when it should be down
>>
>> Hi Jean,
>>
>> Thank you for the info
>>
>> > -----Original Message-----
>> > From: Jean-Michel Hautbois [mailto:jhautbois@gmail.com]
>> > Sent: Friday, September 21, 2012 9:04 AM
>> > To: Dmitry Kravkov
>> > Cc: netdev; Barak Witkowski; Eilon Greenstein; davem@davemloft.net
>> > Subject: Re: bnx2x: link detected up at startup even when it should be down
>> >
>> > I already did it twice. I think this is FW related and not only the
>> > commit adding afex support. It may have solved a link issue (I am just
>> > guessing, based on experiments) ?
>>
>> FW replaced in this commit does not deal with link at all,
>>
>> One is involved in link management is displayed using 'ethtool -i' - it comes with
>> a card  and driver independent.
>>
>> Is device configured for MF by the switch?
>> Can you please share lspci output?
>>
>> Other thing that can help in analysis is msglvl 0x4 for both situations
>>
> We were unable to reproduce the issue on 3.2. Can you please provide logs from your setup?

Yes, I was off until today, I have a workaround, but here are some
informations :

$> lspci -vv -d 14e4:168e

04:00.0 Ethernet controller: Broadcom Corporation Device 168e (rev 10)
        Subsystem: Hewlett-Packard Company Device 1798
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR- FastB2B- DisINTx+
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0, Cache Line Size: 64 bytes
        Interrupt: pin A routed to IRQ 32
        Region 0: Memory at ea000000 (64-bit, prefetchable) [size=8M]
        Region 2: Memory at e9800000 (64-bit, prefetchable) [size=8M]
        Region 4: Memory at e97f0000 (64-bit, prefetchable) [size=64K]
        [virtual] Expansion ROM at def00000 [disabled] [size=256K]
        Capabilities: [48] Power Management version 3
                Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
PME(D0+,D1-,D2-,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=1 PME-
        Capabilities: [50] Vital Product Data <?>
        Capabilities: [58] Message Signalled Interrupts: Mask- 64bit+
Queue=0/3 Enable-
                Address: 0000000000000000  Data: 0000
        Capabilities: [a0] MSI-X: Enable+ Mask- TabSize=17
                Vector table: BAR=4 offset=00000000
                PBA: BAR=4 offset=00001000
        Capabilities: [ac] Express (v2) Endpoint, MSI 00
                DevCap: MaxPayload 512 bytes, PhantFunc 0, Latency L0s
<4us, L1 <64us
                        ExtTag+ AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
                DevCtl: Report errors: Correctable- Non-Fatal+ Fatal+
Unsupported-
                        RlxdOrd+ ExtTag+ PhantFunc- AuxPwr+ NoSnoop+
                        MaxPayload 256 bytes, MaxReadReq 4096 bytes
                DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq-
AuxPwr+ TransPend-
                LnkCap: Port #0, Speed 5GT/s, Width x8, ASPM L0s L1,
Latency L0 <2us, L1 <4us
                        ClockPM+ Suprise- LLActRep- BwNot-
                LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
                        ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                LnkSta: Speed 5GT/s, Width x8, TrErr- Train- SlotClk+
DLActive- BWMgmt- ABWMgmt-
        Capabilities: [100] Advanced Error Reporting <?>
        Capabilities: [13c] Device Serial Number 48-49-7a-fe-ff-6e-c1-80
        Capabilities: [150] Power Budgeting <?>
        Capabilities: [160] Virtual Channel <?>
        Capabilities: [1b8] #0e
        Capabilities: [220] #15
        Capabilities: [300] #19
        Kernel driver in use: bnx2x
        Kernel modules: bnx2x

04:00.1 Ethernet controller: Broadcom Corporation Device 168e (rev 10)
        Subsystem: Hewlett-Packard Company Device 1798
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR- FastB2B- DisINTx+
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0, Cache Line Size: 64 bytes
        Interrupt: pin B routed to IRQ 36
        Region 0: Memory at e8800000 (64-bit, prefetchable) [size=8M]
        Region 2: Memory at e8000000 (64-bit, prefetchable) [size=8M]
        Region 4: Memory at e7ff0000 (64-bit, prefetchable) [size=64K]
        [virtual] Expansion ROM at def40000 [disabled] [size=256K]
        Capabilities: [48] Power Management version 3
                Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
PME(D0+,D1-,D2-,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=1 PME-
        Capabilities: [50] Vital Product Data <?>
        Capabilities: [58] Message Signalled Interrupts: Mask- 64bit+
Queue=0/3 Enable-
                Address: 0000000000000000  Data: 0000
        Capabilities: [a0] MSI-X: Enable+ Mask- TabSize=17
                Vector table: BAR=4 offset=00000000
                PBA: BAR=4 offset=00001000
        Capabilities: [ac] Express (v2) Endpoint, MSI 00
                DevCap: MaxPayload 512 bytes, PhantFunc 0, Latency L0s
<4us, L1 <64us
                        ExtTag+ AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
                DevCtl: Report errors: Correctable- Non-Fatal+ Fatal+
Unsupported-
                        RlxdOrd+ ExtTag+ PhantFunc- AuxPwr+ NoSnoop+
                        MaxPayload 256 bytes, MaxReadReq 4096 bytes
                DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq-
AuxPwr+ TransPend-
                LnkCap: Port #0, Speed 5GT/s, Width x8, ASPM L0s L1,
Latency L0 <2us, L1 <4us
                        ClockPM+ Suprise- LLActRep- BwNot-
                LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
                        ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                LnkSta: Speed 5GT/s, Width x8, TrErr- Train- SlotClk+
DLActive- BWMgmt- ABWMgmt-
        Capabilities: [100] Advanced Error Reporting <?>
        Capabilities: [13c] Device Serial Number 4c-49-7a-fe-ff-6e-c1-80
        Capabilities: [150] Power Budgeting <?>
        Capabilities: [160] Virtual Channel <?>
        Capabilities: [1b8] #0e
        Capabilities: [220] #15
        Kernel driver in use: bnx2x
        Kernel modules: bnx2x

04:00.2 Ethernet controller: Broadcom Corporation Device 168e (rev 10)
        Subsystem: Hewlett-Packard Company Device 1798
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR- FastB2B- DisINTx+
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0, Cache Line Size: 64 bytes
        Interrupt: pin B routed to IRQ 36
        Region 0: Memory at e7000000 (64-bit, prefetchable) [size=8M]
        Region 2: Memory at e6800000 (64-bit, prefetchable) [size=8M]
        Region 4: Memory at e67f0000 (64-bit, prefetchable) [size=64K]
        Capabilities: [48] Power Management version 3
                Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
PME(D0+,D1-,D2-,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=1 PME-
        Capabilities: [50] Vital Product Data <?>
        Capabilities: [58] Message Signalled Interrupts: Mask- 64bit+
Queue=0/3 Enable-
                Address: 0000000000000000  Data: 0000
        Capabilities: [a0] MSI-X: Enable+ Mask- TabSize=17
                Vector table: BAR=4 offset=00000000
                PBA: BAR=4 offset=00001000
        Capabilities: [ac] Express (v2) Endpoint, MSI 00
                DevCap: MaxPayload 512 bytes, PhantFunc 0, Latency L0s
<4us, L1 <64us
                        ExtTag+ AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
                DevCtl: Report errors: Correctable- Non-Fatal+ Fatal+
Unsupported-
                        RlxdOrd+ ExtTag+ PhantFunc- AuxPwr+ NoSnoop+
                        MaxPayload 256 bytes, MaxReadReq 4096 bytes
                DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq-
AuxPwr+ TransPend-
                LnkCap: Port #0, Speed 5GT/s, Width x8, ASPM L0s L1,
Latency L0 <2us, L1 <4us
                        ClockPM+ Suprise- LLActRep- BwNot-
                LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
                        ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                LnkSta: Speed 5GT/s, Width x8, TrErr- Train- SlotClk+
DLActive- BWMgmt- ABWMgmt-
        Capabilities: [100] Advanced Error Reporting <?>
        Capabilities: [13c] Device Serial Number 48-49-7a-fe-ff-6e-c1-80
        Capabilities: [150] Power Budgeting <?>
        Capabilities: [160] Virtual Channel <?>
        Capabilities: [1b8] #0e
        Capabilities: [220] #15
        Kernel driver in use: bnx2x
        Kernel modules: bnx2x

04:00.3 Ethernet controller: Broadcom Corporation Device 168e (rev 10)
        Subsystem: Hewlett-Packard Company Device 1798
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR- FastB2B- DisINTx+
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0, Cache Line Size: 64 bytes
        Interrupt: pin C routed to IRQ 37
        Region 0: Memory at e5800000 (64-bit, prefetchable) [size=8M]
        Region 2: Memory at e5000000 (64-bit, prefetchable) [size=8M]
        Region 4: Memory at e4ff0000 (64-bit, prefetchable) [size=64K]
        Capabilities: [48] Power Management version 3
                Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
PME(D0+,D1-,D2-,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=1 PME-
        Capabilities: [50] Vital Product Data <?>
        Capabilities: [58] Message Signalled Interrupts: Mask- 64bit+
Queue=0/3 Enable-
                Address: 0000000000000000  Data: 0000
        Capabilities: [a0] MSI-X: Enable+ Mask- TabSize=17
                Vector table: BAR=4 offset=00000000
                PBA: BAR=4 offset=00001000
        Capabilities: [ac] Express (v2) Endpoint, MSI 00
                DevCap: MaxPayload 512 bytes, PhantFunc 0, Latency L0s
<4us, L1 <64us
                        ExtTag+ AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
                DevCtl: Report errors: Correctable- Non-Fatal+ Fatal+
Unsupported-
                        RlxdOrd+ ExtTag+ PhantFunc- AuxPwr+ NoSnoop+
                        MaxPayload 256 bytes, MaxReadReq 4096 bytes
                DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq-
AuxPwr+ TransPend-
                LnkCap: Port #0, Speed 5GT/s, Width x8, ASPM L0s L1,
Latency L0 <2us, L1 <4us
                        ClockPM+ Suprise- LLActRep- BwNot-
                LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
                        ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                LnkSta: Speed 5GT/s, Width x8, TrErr- Train- SlotClk+
DLActive- BWMgmt- ABWMgmt-
        Capabilities: [100] Advanced Error Reporting <?>
        Capabilities: [13c] Device Serial Number 4c-49-7a-fe-ff-6e-c1-80
        Capabilities: [150] Power Budgeting <?>
        Capabilities: [160] Virtual Channel <?>
        Capabilities: [1b8] #0e
        Capabilities: [220] #15
        Kernel driver in use: bnx2x
        Kernel modules: bnx2x

04:00.4 Ethernet controller: Broadcom Corporation Device 168e (rev 10)
        Subsystem: Hewlett-Packard Company Device 1798
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR- FastB2B- DisINTx+
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0, Cache Line Size: 64 bytes
        Interrupt: pin C routed to IRQ 37
        Region 0: Memory at e4000000 (64-bit, prefetchable) [size=8M]
        Region 2: Memory at e3800000 (64-bit, prefetchable) [size=8M]
        Region 4: Memory at e37f0000 (64-bit, prefetchable) [size=64K]
        Capabilities: [48] Power Management version 3
                Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
PME(D0+,D1-,D2-,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=1 PME-
        Capabilities: [50] Vital Product Data <?>
        Capabilities: [58] Message Signalled Interrupts: Mask- 64bit+
Queue=0/3 Enable-
                Address: 0000000000000000  Data: 0000
        Capabilities: [a0] MSI-X: Enable+ Mask- TabSize=17
                Vector table: BAR=4 offset=00000000
                PBA: BAR=4 offset=00001000
        Capabilities: [ac] Express (v2) Endpoint, MSI 00
                DevCap: MaxPayload 512 bytes, PhantFunc 0, Latency L0s
<4us, L1 <64us
                        ExtTag+ AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
                DevCtl: Report errors: Correctable- Non-Fatal+ Fatal+
Unsupported-
                        RlxdOrd+ ExtTag+ PhantFunc- AuxPwr+ NoSnoop+
                        MaxPayload 256 bytes, MaxReadReq 4096 bytes
                DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq-
AuxPwr+ TransPend-
                LnkCap: Port #0, Speed 5GT/s, Width x8, ASPM L0s L1,
Latency L0 <2us, L1 <4us
                        ClockPM+ Suprise- LLActRep- BwNot-
                LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
                        ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                LnkSta: Speed 5GT/s, Width x8, TrErr- Train- SlotClk+
DLActive- BWMgmt- ABWMgmt-
        Capabilities: [100] Advanced Error Reporting <?>
        Capabilities: [13c] Device Serial Number 48-49-7a-fe-ff-6e-c1-80
        Capabilities: [150] Power Budgeting <?>
        Capabilities: [160] Virtual Channel <?>
        Capabilities: [1b8] #0e
        Capabilities: [220] #15
        Kernel driver in use: bnx2x
        Kernel modules: bnx2x

04:00.5 Ethernet controller: Broadcom Corporation Device 168e (rev 10)
        Subsystem: Hewlett-Packard Company Device 1798
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR- FastB2B- DisINTx+
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0, Cache Line Size: 64 bytes
        Interrupt: pin D routed to IRQ 38
        Region 0: Memory at e2800000 (64-bit, prefetchable) [size=8M]
        Region 2: Memory at e2000000 (64-bit, prefetchable) [size=8M]
        Region 4: Memory at e1ff0000 (64-bit, prefetchable) [size=64K]
        Capabilities: [48] Power Management version 3
                Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
PME(D0+,D1-,D2-,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=1 PME-
        Capabilities: [50] Vital Product Data <?>
        Capabilities: [58] Message Signalled Interrupts: Mask- 64bit+
Queue=0/3 Enable-
                Address: 0000000000000000  Data: 0000
        Capabilities: [a0] MSI-X: Enable+ Mask- TabSize=17
                Vector table: BAR=4 offset=00000000
                PBA: BAR=4 offset=00001000
        Capabilities: [ac] Express (v2) Endpoint, MSI 00
                DevCap: MaxPayload 512 bytes, PhantFunc 0, Latency L0s
<4us, L1 <64us
                        ExtTag+ AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
                DevCtl: Report errors: Correctable- Non-Fatal+ Fatal+
Unsupported-
                        RlxdOrd+ ExtTag+ PhantFunc- AuxPwr+ NoSnoop+
                        MaxPayload 256 bytes, MaxReadReq 4096 bytes
                DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq-
AuxPwr+ TransPend-
                LnkCap: Port #0, Speed 5GT/s, Width x8, ASPM L0s L1,
Latency L0 <2us, L1 <4us
                        ClockPM+ Suprise- LLActRep- BwNot-
                LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
                        ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                LnkSta: Speed 5GT/s, Width x8, TrErr- Train- SlotClk+
DLActive- BWMgmt- ABWMgmt-
        Capabilities: [100] Advanced Error Reporting <?>
        Capabilities: [13c] Device Serial Number 4c-49-7a-fe-ff-6e-c1-80
        Capabilities: [150] Power Budgeting <?>
        Capabilities: [160] Virtual Channel <?>
        Capabilities: [1b8] #0e
        Capabilities: [220] #15
        Kernel driver in use: bnx2x
        Kernel modules: bnx2x

04:00.6 Ethernet controller: Broadcom Corporation Device 168e (rev 10)
        Subsystem: Hewlett-Packard Company Device 1798
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR- FastB2B- DisINTx+
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0, Cache Line Size: 64 bytes
        Interrupt: pin D routed to IRQ 38
        Region 0: Memory at e1000000 (64-bit, prefetchable) [size=8M]
        Region 2: Memory at e0800000 (64-bit, prefetchable) [size=8M]
        Region 4: Memory at e07f0000 (64-bit, prefetchable) [size=64K]
        Capabilities: [48] Power Management version 3
                Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
PME(D0+,D1-,D2-,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=1 PME-
        Capabilities: [50] Vital Product Data <?>
        Capabilities: [58] Message Signalled Interrupts: Mask- 64bit+
Queue=0/3 Enable-
                Address: 0000000000000000  Data: 0000
        Capabilities: [a0] MSI-X: Enable+ Mask- TabSize=17
                Vector table: BAR=4 offset=00000000
                PBA: BAR=4 offset=00001000
        Capabilities: [ac] Express (v2) Endpoint, MSI 00
                DevCap: MaxPayload 512 bytes, PhantFunc 0, Latency L0s
<4us, L1 <64us
                        ExtTag+ AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
                DevCtl: Report errors: Correctable- Non-Fatal+ Fatal+
Unsupported-
                        RlxdOrd+ ExtTag+ PhantFunc- AuxPwr+ NoSnoop+
                        MaxPayload 256 bytes, MaxReadReq 4096 bytes
                DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq-
AuxPwr+ TransPend-
                LnkCap: Port #0, Speed 5GT/s, Width x8, ASPM L0s L1,
Latency L0 <2us, L1 <4us
                        ClockPM+ Suprise- LLActRep- BwNot-
                LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
                        ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                LnkSta: Speed 5GT/s, Width x8, TrErr- Train- SlotClk+
DLActive- BWMgmt- ABWMgmt-
        Capabilities: [100] Advanced Error Reporting <?>
        Capabilities: [13c] Device Serial Number 48-49-7a-fe-ff-6e-c1-80
        Capabilities: [150] Power Budgeting <?>
        Capabilities: [160] Virtual Channel <?>
        Capabilities: [1b8] #0e
        Capabilities: [220] #15
        Kernel driver in use: bnx2x
        Kernel modules: bnx2x

04:00.7 Ethernet controller: Broadcom Corporation Device 168e (rev 10)
        Subsystem: Hewlett-Packard Company Device 1798
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr+ Stepping- SERR- FastB2B- DisINTx+
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0, Cache Line Size: 64 bytes
        Interrupt: pin A routed to IRQ 32
        Region 0: Memory at df800000 (64-bit, prefetchable) [size=8M]
        Region 2: Memory at df000000 (64-bit, prefetchable) [size=8M]
        Region 4: Memory at deff0000 (64-bit, prefetchable) [size=64K]
        Capabilities: [48] Power Management version 3
                Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
PME(D0+,D1-,D2-,D3hot+,D3cold+)
                Status: D3 PME-Enable+ DSel=0 DScale=1 PME-
        Capabilities: [50] Vital Product Data <?>
        Capabilities: [58] Message Signalled Interrupts: Mask- 64bit+
Queue=0/3 Enable-
                Address: 0000000000000000  Data: 0000
        Capabilities: [a0] MSI-X: Enable+ Mask- TabSize=17
                Vector table: BAR=4 offset=00000000
                PBA: BAR=4 offset=00001000
        Capabilities: [ac] Express (v2) Endpoint, MSI 00
                DevCap: MaxPayload 512 bytes, PhantFunc 0, Latency L0s
<4us, L1 <64us
                        ExtTag+ AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
                DevCtl: Report errors: Correctable- Non-Fatal+ Fatal+
Unsupported-
                        RlxdOrd+ ExtTag+ PhantFunc- AuxPwr+ NoSnoop+
                        MaxPayload 256 bytes, MaxReadReq 4096 bytes
                DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq-
AuxPwr+ TransPend-
                LnkCap: Port #0, Speed 5GT/s, Width x8, ASPM L0s L1,
Latency L0 <2us, L1 <4us
                        ClockPM+ Suprise- LLActRep- BwNot-
                LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
                        ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                LnkSta: Speed 5GT/s, Width x8, TrErr- Train- SlotClk+
DLActive- BWMgmt- ABWMgmt-
        Capabilities: [100] Advanced Error Reporting <?>
        Capabilities: [13c] Device Serial Number 4c-49-7a-fe-ff-6e-c1-80
        Capabilities: [150] Power Budgeting <?>
        Capabilities: [160] Virtual Channel <?>
        Capabilities: [1b8] #0e
        Capabilities: [220] #15
        Kernel driver in use: bnx2x
        Kernel modules: bnx2x

I have tested several things, and I added some traces in order to get
information.
For instance, I trace the load_code in the function named "bnx2x_nic_load".

[   25.693677] bnx2x 0000:04:00.0: eth0: bnx2x_nic_load load_code=0x10130000
[   25.693679] bnx2x 0000:04:00.0: eth0: bnx2x_nic_load start period
[  102.748934] bnx2x 0000:04:00.1: eth1: bnx2x_nic_load load_code=0x10100000
[  102.749065] bnx2x 0000:04:00.1: eth1: bnx2x_nic_load start period
[  104.007074] bnx2x 0000:04:00.2: eth2: bnx2x_nic_load load_code=0x10120000
[  104.007197] bnx2x 0000:04:00.2: eth2: bnx2x_nic_load NOT start period
[  104.423789] bnx2x 0000:04:00.3: eth3: bnx2x_nic_load load_code=0x10120000
[  104.423914] bnx2x 0000:04:00.3: eth3: bnx2x_nic_load NOT start period
[  104.836505] bnx2x 0000:04:00.4: eth4: bnx2x_nic_load load_code=0x10120000
[  104.836632] bnx2x 0000:04:00.4: eth4: bnx2x_nic_load NOT start period
[  105.254220] bnx2x 0000:04:00.5: eth5: bnx2x_nic_load load_code=0x10120000
[  105.254350] bnx2x 0000:04:00.5: eth5: bnx2x_nic_load NOT start period
[  105.667935] bnx2x 0000:04:00.6: eth6: bnx2x_nic_load load_code=0x10120000
[  105.668066] bnx2x 0000:04:00.6: eth6: bnx2x_nic_load NOT start period
[  106.081652] bnx2x 0000:04:00.7: eth7: bnx2x_nic_load load_code=0x10120000
[  106.081779] bnx2x 0000:04:00.7: eth7: bnx2x_nic_load NOT start period

This is a FlexNIC use.
Here is my (quick and dirty) patch which makes the link detection
working and adds the traces shown above :

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 580b44e..dedd810 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -1769,6 +1769,7 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
         */
        if (!BP_NOMCP(bp)) {
                load_code = bnx2x_fw_command(bp, DRV_MSG_CODE_LOAD_REQ, 0);
+netdev_info(bp->dev, "bnx2x_nic_load bnx2x_fw_command
load_code=0x%08X\n",load_code);
                if (!load_code) {
                        BNX2X_ERR("MCP response failure, aborting\n");
                        rc = -EBUSY;
@@ -1785,22 +1786,31 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
                DP(NETIF_MSG_IFUP, "NO MCP - load counts[%d]      %d, %d, %d\n",
                   path, load_count[path][0], load_count[path][1],
                   load_count[path][2]);
+netdev_info(bp->dev, "bnx2x_nic_load NO MCP - load counts[%d]
%d, %d, %d\n",
+                  path, load_count[path][0], load_count[path][1],
+                  load_count[path][2]);
                load_count[path][0]++;
                load_count[path][1 + port]++;
                DP(NETIF_MSG_IFUP, "NO MCP - new load counts[%d]  %d, %d, %d\n",
                   path, load_count[path][0], load_count[path][1],
                   load_count[path][2]);
+netdev_info(bp->dev, "bnx2x_nic_load NO MCP - new load counts[%d]
%d, %d, %d\n",
+                  path, load_count[path][0], load_count[path][1],
+                  load_count[path][2]);
                if (load_count[path][0] == 1)
                        load_code = FW_MSG_CODE_DRV_LOAD_COMMON;
                else if (load_count[path][1 + port] == 1)
                        load_code = FW_MSG_CODE_DRV_LOAD_PORT;
                else
                        load_code = FW_MSG_CODE_DRV_LOAD_FUNCTION;
+netdev_info(bp->dev, "bnx2x_nic_load autre load_code=0x%08X\n",load_code);
        }

+netdev_info(bp->dev, "bnx2x_nic_load load_code=0x%08X\n",load_code);
        if ((load_code == FW_MSG_CODE_DRV_LOAD_COMMON) ||
            (load_code == FW_MSG_CODE_DRV_LOAD_COMMON_CHIP) ||
-           (load_code == FW_MSG_CODE_DRV_LOAD_PORT)) {
+           (load_code == FW_MSG_CODE_DRV_LOAD_PORT) ||
+                (load_code == FW_MSG_CODE_DRV_LOAD_FUNCTION)) {
                bp->port.pmf = 1;
                /*
                 * We need the barrier to ensure the ordering between the
@@ -1808,9 +1818,13 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
                 * bnx2x_periodic_task().
                 */
                smp_mb();
+netdev_info(bp->dev, "bnx2x_nic_load start period\n");
                queue_delayed_work(bnx2x_wq, &bp->period_task, 0);
        } else
+{
+netdev_info(bp->dev, "bnx2x_nic_load NOT start period\n");
                bp->port.pmf = 0;
+}

        DP(NETIF_MSG_LINK, "pmf %d\n", bp->port.pmf);


Hope it can help...
Regards,
JM
