From: "Hillier, Gernot" <gernot.hillier@siemens.com>
Subject: Re: e1000e: sporadic "hardware error"s with Intel 82563EB on Supermicro
 X7DB3
Date: Wed, 08 Oct 2008 15:35:35 +0200
Message-ID: <48ECB727.6050905@siemens.com>
References: <48EB7161.60004@siemens.com> <m33aj78jnh.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jesse.brandeburg@intel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, bruce.w.allan@intel.com
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from david.siemens.de ([192.35.17.14]:15630 "EHLO david.siemens.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753314AbYJHNaY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Oct 2008 09:30:24 -0400
In-Reply-To: <m33aj78jnh.fsf@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

Krzysztof Halasa wrote:
> Hi,
> 
> "Hillier, Gernot" <gernot.hillier@siemens.com> writes:
> 
>> On at least two machines using the Supermicro X7DB3 board with Intel
>> 82563EB (a.k.a. PCI device 8086:1096), we see sporadic problems on modprobe
>> (about 1 time in some hundred tries):
>>
>> e1000e: Intel(R) PRO/1000 Network Driver - 0.3.3.3-k2
>> e1000e: Copyright (c) 1999-2008 Intel Corporation.
>> e1000e 0000:06:00.0: PCI INT A -> GSI 18 (level, low) -> IRQ 18
>> e1000e 0000:06:00.0: setting latency timer to 64
>> 0000:06:00.0: 0000:06:00.0: Hardware Error
> 
> What does "lspci -vv" say about it when the above happens?
> 
> I spurious chip reset (hardware) could probably cause that.

Here's the output of "lspci -vv" in the error case (for the eth devices):

------- SNIP -----------
06:00.0 Class 0200: Device 8086:1096 (rev 01)
        Subsystem: Device 15d9:1096
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B- DisINTx-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0, Cache Line Size: 32 bytes
        Interrupt: pin A routed to IRQ 18
        Region 0: Memory at d0020000 (32-bit, non-prefetchable) [size=128K]
        Region 1: Memory at d0000000 (32-bit, non-prefetchable) [size=128K]
        Region 2: I/O ports at 4000 [size=32]
        [virtual] Expansion ROM at d0080000 [disabled] [size=64K]
        Capabilities: [c8] Power Management version 2
                Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=1 PME-
        Capabilities: [d0] Message Signalled Interrupts: Mask- 64bit+ Queue=0/0 Enable-
                Address: 00000000feeff00c  Data: 4158
        Capabilities: [e0] Express (v1) Endpoint, MSI 00
                DevCap: MaxPayload 256 bytes, PhantFunc 0, Latency L0s <512ns, L1 <64us
                        ExtTag- AttnBtn- AttnInd- PwrInd- RBE- FLReset-
                DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
                        RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
                        MaxPayload 128 bytes, MaxReadReq 4096 bytes
                DevSta: CorrErr- UncorrErr+ FatalErr- UnsuppReq+ AuxPwr+ TransPend-
                LnkCap: Port #0, Speed 2.5GT/s, Width x4, ASPM unknown, Latency L0 <128ns, L1 <64us
                        ClockPM- Suprise- LLActRep- BwNot-
                LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
                        ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                LnkSta: Speed 2.5GT/s, Width x4, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
        Capabilities: [100] Advanced Error Reporting <?>
        Capabilities: [140] Device Serial Number 06-c7-66-ff-ff-48-30-00
        Kernel driver in use: e1000e
        Kernel modules: e1000e

06:00.1 Class 0200: Device 8086:1096 (rev 01)
        Subsystem: Device 15d9:1096
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B- DisINTx-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0, Cache Line Size: 32 bytes
        Interrupt: pin B routed to IRQ 19
        Region 0: Memory at d0060000 (32-bit, non-prefetchable) [size=128K]
        Region 1: Memory at d0040000 (32-bit, non-prefetchable) [size=128K]
        Region 2: I/O ports at 4020 [size=32]
        [virtual] Expansion ROM at d0090000 [disabled] [size=64K]
        Capabilities: [c8] Power Management version 2
                Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=1 PME-
        Capabilities: [d0] Message Signalled Interrupts: Mask- 64bit+ Queue=0/0 Enable-
                Address: 0000000000000000  Data: 0000
        Capabilities: [e0] Express (v1) Endpoint, MSI 00
                DevCap: MaxPayload 256 bytes, PhantFunc 0, Latency L0s <512ns, L1 <64us
                        ExtTag- AttnBtn- AttnInd- PwrInd- RBE- FLReset-
                DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
                        RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
                        MaxPayload 128 bytes, MaxReadReq 4096 bytes
                DevSta: CorrErr- UncorrErr+ FatalErr- UnsuppReq+ AuxPwr+ TransPend-
                LnkCap: Port #0, Speed 2.5GT/s, Width x4, ASPM unknown, Latency L0 <128ns, L1 <64us
                        ClockPM- Suprise- LLActRep- BwNot-
                LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
                        ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                LnkSta: Speed 2.5GT/s, Width x4, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
        Capabilities: [100] Advanced Error Reporting <?>
        Capabilities: [140] Device Serial Number 06-c7-66-ff-ff-48-30-00
        Kernel driver in use: e1000e
        Kernel modules: e1000e
------- SNIP -----------

Retried this several times in the error and normal case. The only things
which change are three values for device 06:00.0:

- Control "DisINTx-" changes to "DisINTx+" if the card is correctly
initialized
- Interrupt changes from IRQ 18 to IRQ 4345 if card is correctly initialized
- Message Signalled Interrupts change from "Enable-" to "Enable+"

In addition, the "Data" field from "Message Signalled Interrupts" seems to 
change w/o any clear pattern.

For 06:00.1, everything seems to be the same in the error as well as in the
normal case.

Does this tell you anything valuable?

-- 
Gernot Hillier, Siemens AG, CT SE 2
