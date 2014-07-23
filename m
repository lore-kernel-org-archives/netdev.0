From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [E1000-devel] [linux-nics] Problem: 82574L device (e1000e driver):
 Reset adapter unexpectedly / transmit queue 0 timed out
Date: Wed, 23 Jul 2014 09:04:17 -0700
Message-ID: <53CFDD01.5010204@intel.com>
References: <CAJtEV7bERYgwtQv1zAvk+XzaywF6g7K-QqAq3VLErNU1YSgxYA@mail.gmail.com>	<9B4A1B1917080E46B64F07F2989DADD6533A4E9C@ORSMSX114.amr.corp.intel.com>	<CAJtEV7aCm9AWW3vNQO1pjxorYnGAQQG0MRnPHwy7COx7eM8eFg@mail.gmail.com>	<CAJtEV7Z=54cHbZ8SiYmgm7=osncs1SaQG=adhht-3NmWrkG1ww@mail.gmail.com>	<53CE8259.6080400@intel.com> <CAJtEV7ZtWVg7tLuznPmBce56ARLn7hzk6F6wwXnJ9vo-_AdLtQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Fujinaka, Todd" <todd.fujinaka@intel.com>,
	Dmitry Lifshitz <lifshitz@compulab.co.il>,
	netdev <netdev@vger.kernel.org>,
	"e1000-devel@lists.sf.net" <e1000-devel@lists.sf.net>,
	Igor Grinberg <grinberg@compulab.co.il>,
	Linux NICS <linux.nics@intel.com>
To: Andrew Cooks <acooks@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:46651 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757229AbaGWQE7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jul 2014 12:04:59 -0400
In-Reply-To: <CAJtEV7ZtWVg7tLuznPmBce56ARLn7hzk6F6wwXnJ9vo-_AdLtQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/22/2014 09:59 PM, Andrew Cooks wrote:
> On Tue, Jul 22, 2014 at 11:25 PM, Alexander Duyck
> <alexander.h.duyck@intel.com> wrote:
>>>>>> # lspci -vvnnk:
>>>>>> 01:00.0 Ethernet controller [0200]: Intel Corporation 82574L Gigabit Network Connection [8086:10d3]
>>>>>>         Subsystem: Intel Corporation Device [8086:0000]
>>>>>>         Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx-
>>>>>>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
>>>>>>         Interrupt: pin A routed to IRQ 16
>>>>>>         Region 0: [virtual] Memory at c1900000 (32-bit, non-prefetchable) [size=128K]
>>>>>>         Region 1: [virtual] Memory at c1800000 (32-bit, non-prefetchable) [size=1M]
>>>>>>         Region 2: I/O ports at 7000 [size=32]
>>>>>>         Region 3: [virtual] Memory at c1920000 (32-bit, non-prefetchable) [size=16K]
>>>>>>         [virtual] Expansion ROM at c1940000 [disabled] [size=256K]
>>>>>>         Capabilities: [c8] Power Management version 2
>>>>>>                 Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
>>>>>>                 Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=1 PME-
>>>>>>         Capabilities: [d0] MSI: Enable- Count=1/1 Maskable- 64bit+
>>>>>>                 Address: 0000000000000000  Data: 0000
>>>>>>         Capabilities: [e0] Express (v1) Endpoint, MSI 00
>>>>>>                 DevCap: MaxPayload 256 bytes, PhantFunc 0, Latency L0s <512ns, L1 <64us
>>>>>>                         ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
>>>>>>                 DevCtl: Report errors: Correctable- Non-Fatal- Fatal- Unsupported-
>>>>>>                         RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
>>>>>>                         MaxPayload 128 bytes, MaxReadReq 512 bytes
>>>>>>                 DevSta: CorrErr+ UncorrErr+ FatalErr- UnsuppReq+ AuxPwr+ TransPend-
>>>>>>                 LnkCap: Port #1, Speed 2.5GT/s, Width x1, ASPM L0s L1, Latency L0 <128ns, L1 <64us
>>>>>>                         ClockPM- Surprise- LLActRep- BwNot-
>>>>>>                 LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
>>>>>>                         ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
>>>>>>                 LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
>>>>>>         Capabilities: [a0] MSI-X: Enable- Count=5 Masked-
>>>>>>                 Vector table: BAR=3 offset=00000000
>>>>>>                 PBA: BAR=3 offset=00002000
>>>>>>         Capabilities: [100 v1] Advanced Error Reporting
>>>>>>                 UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq+ ACSViol-
>>>>>>                 UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
>>>>>>                 UESvrt: DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
>>>>>>                 CESta:  RxErr+ BadTLP+ BadDLLP+ Rollover- Timeout- NonFatalErr+
>>>>>>                 CEMsk:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
>>>>>>                 AERCap: First Error Pointer: 14, GenCap- CGenEn- ChkCap- ChkEn-
>>>>>>         Capabilities: [140 v1] Device Serial Number 00-01-c0-ff-ff-12-8a-64
>>>>>>         Kernel driver in use: e1000e
>>>>>>
>>>>>>
>>
>> It looks like something bad happened on the PCIe bus based on the RxErr,
>> BadTLP, BadDLLP, and NonFatalERR indicators all being set.  This could
>> be an indication of a possible problem with the PCIe link on the system.
> 
> Thanks very much for explaining this. Is it correct to think that this
> is likely to be a hardware problem?
> 

Yes, that is kind of what I am thinking.  The problem may be in the
wiring between the root complex and the part.  Correctable errors
usually indicate that the link between the PCIe devices may be failing.

Do you know if you have any features such as runtime power management
enabled?  If so you might try disabling it as one possible issue could
be that transitioning the link between DO and D3 and back to D0 is
eventually failing and causing this issue.

>> One thing that would probably be useful would be to provide an "lspci
>> -vvv" for the entire system.  That would at least give us an idea of the
>> PCIe hierarchy and could help to tell us if the problem is something in
>> the local PCIe hierarchy for the device, or if the problem is closer to
>> the root complex.
> 
> I've attached the complete lspci output, because it's quite large to
> include inline. I hope that's ok. It shows some interesting
> differences between device 01:00.0 (the one that error'ed) and the
> other 82574L devices.
> 
> # lspci -tvvvnn
> -[0000:00]-+-00.0  Advanced Micro Devices, Inc. [AMD] Family 14h
> Processor Root Complex [1022:1510]
>            +-01.0  Advanced Micro Devices, Inc. [AMD/ATI] Wrestler
> [Radeon HD 6320] [1002:9806]
>            +-01.1  Advanced Micro Devices, Inc. [AMD/ATI] Wrestler
> HDMI Audio [1002:1314]
>            +-04.0-[01]----00.0  Intel Corporation 82574L Gigabit
> Network Connection [8086:10d3]
>            +-05.0-[02]----00.0  Intel Corporation 82574L Gigabit
> Network Connection [8086:10d3]
>            +-06.0-[03]----00.0  Intel Corporation 82574L Gigabit
> Network Connection [8086:10d3]
>            +-07.0-[04]----00.0  Intel Corporation 82574L Gigabit
> Network Connection [8086:10d3]
>            +-11.0  Advanced Micro Devices, Inc. [AMD/ATI]
> SB7x0/SB8x0/SB9x0 SATA Controller [AHCI mode] [1002:4391]
>            +-12.0  Advanced Micro Devices, Inc. [AMD/ATI]
> SB7x0/SB8x0/SB9x0 USB OHCI0 Controller [1002:4397]
>            +-12.2  Advanced Micro Devices, Inc. [AMD/ATI]
> SB7x0/SB8x0/SB9x0 USB EHCI Controller [1002:4396]
>            +-13.0  Advanced Micro Devices, Inc. [AMD/ATI]
> SB7x0/SB8x0/SB9x0 USB OHCI0 Controller [1002:4397]
>            +-13.2  Advanced Micro Devices, Inc. [AMD/ATI]
> SB7x0/SB8x0/SB9x0 USB EHCI Controller [1002:4396]
>            +-14.0  Advanced Micro Devices, Inc. [AMD/ATI] SBx00 SMBus
> Controller [1002:4385]
>            +-14.3  Advanced Micro Devices, Inc. [AMD/ATI]
> SB7x0/SB8x0/SB9x0 LPC host controller [1002:439d]
>            +-14.4-[05]--
>            +-14.5  Advanced Micro Devices, Inc. [AMD/ATI]
> SB7x0/SB8x0/SB9x0 USB OHCI2 Controller [1002:4399]
>            +-15.0-[06-07]----00.0  Realtek Semiconductor Co., Ltd.
> RTL8111/8168/8411 PCI Express Gigabit Ethernet Controller [10ec:8168]
>            +-15.1-[08]----00.0  Realtek Semiconductor Co., Ltd.
> RTL8111/8168/8411 PCI Express Gigabit Ethernet Controller [10ec:8168]
>            +-15.2-[09]----00.0  Realtek Semiconductor Co., Ltd.
> RTL8723AE PCIe Wireless Network Adapter [10ec:8723]
>            +-16.0  Advanced Micro Devices, Inc. [AMD/ATI]
> SB7x0/SB8x0/SB9x0 USB OHCI0 Controller [1002:4397]
>            +-16.2  Advanced Micro Devices, Inc. [AMD/ATI]
> SB7x0/SB8x0/SB9x0 USB EHCI Controller [1002:4396]
>            +-18.0  Advanced Micro Devices, Inc. [AMD] Family 12h/14h
> Processor Function 0 [1022:1700]
>            +-18.1  Advanced Micro Devices, Inc. [AMD] Family 12h/14h
> Processor Function 1 [1022:1701]
>            +-18.2  Advanced Micro Devices, Inc. [AMD] Family 12h/14h
> Processor Function 2 [1022:1702]
>            +-18.3  Advanced Micro Devices, Inc. [AMD] Family 12h/14h
> Processor Function 3 [1022:1703]
>            +-18.4  Advanced Micro Devices, Inc. [AMD] Family 12h/14h
> Processor Function 4 [1022:1704]
>            +-18.5  Advanced Micro Devices, Inc. [AMD] Family 12h/14h
> Processor Function 6 [1022:1718]
>            +-18.6  Advanced Micro Devices, Inc. [AMD] Family 12h/14h
> Processor Function 5 [1022:1716]
>            \-18.7  Advanced Micro Devices, Inc. [AMD] Family 12h/14h
> Processor Function 7 [1022:1719]
> 
> 
> Thanks!
> 
> a.
> 


I'll look this over, though nothing jumps out immediately at me as
something that is wrong.  Do you have all 4 ports in use or only a few
of them?  One thing you might try is testing various ports and if you
see the issue on one specific port it might just be a fault in the
wiring between the root complex and that port, or possibly the silicon
on either end.

Thanks,

Alex
