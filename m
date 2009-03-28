From: Matheos Worku <Matheos.Worku@Sun.COM>
Subject: Re: niu driver - Transmit timed out - 2.6.29
Date: Fri, 27 Mar 2009 23:18:30 -0700
Message-ID: <49CDC136.60709@sun.com>
References: <49CB78A4.3020406@krogh.cc> <49CD2996.60502@krogh.cc>
 <49CD7266.1070002@sun.com> <49CDBE42.8030708@krogh.cc>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=ISO-8859-1
Content-Transfer-Encoding: 7BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jesper Krogh <jesper@krogh.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sca-es-mail-1.Sun.COM ([192.18.43.132]:61993 "EHLO
	sca-es-mail-1.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752266AbZC1GSs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Mar 2009 02:18:48 -0400
Received: from fe-sfbay-10.sun.com ([192.18.43.129])
	by sca-es-mail-1.sun.com (8.13.7+Sun/8.12.9) with ESMTP id n2S6ITJT015248
	for <netdev@vger.kernel.org>; Fri, 27 Mar 2009 23:18:42 -0700 (PDT)
Received: from conversion-daemon.fe-sfbay-10.sun.com by fe-sfbay-10.sun.com
 (Sun Java(tm) System Messaging Server 7.0-5.01 64bit (built Feb 19 2009))
 id <0KH700M00DDU0H00@fe-sfbay-10.sun.com> for netdev@vger.kernel.org; Fri,
 27 Mar 2009 23:18:29 -0700 (PDT)
In-reply-to: <49CDBE42.8030708@krogh.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesper Krogh wrote:
> Matheos Worku wrote:
>>> This is probably the interesting part:
>>> Mar 26 13:25:49 hest kernel: [25335.587191] niu 0000:84:00.0: niu: 
>>> eth4: bits (40000000) of register RXDMA_CFIG1 would not clear, 
>>> val[c0000000]
>> Jesper,
>>
>> One of the RX  ring DMAs  is failing to reset. I guess whatever is 
>> hanging the TX side is affecting the RX side as well. Can you do lspci 
>> on the function  and its siblings?
> 
> Like this(please guide me if that wasn't the correct lspci output):

Jesper,

I was wondering if you can get the register dump just after the NIC hangs.

lspci -vvv -xxx -s 84:0

Regards
Matheos

> 
> k# lspci -vvv -s 84:00
> 84:00.0 Ethernet controller: Sun Microsystems Computer Corp. 
> Multithreaded 10 Gigabit Ethernet Network Controller (rev 01)
>         Subsystem: Sun Microsystems Computer Corp. Unknown device 0000
>         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- 
> ParErr- Stepping- SERR- FastB2B-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
> <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 0, Cache Line Size: 64 bytes
>         Interrupt: pin A routed to IRQ 43
>         Region 0: Memory at fd000000 (64-bit, non-prefetchable) [size=16M]
>         Region 2: Memory at fe9f8000 (64-bit, non-prefetchable) [size=32K]
>         Region 4: Memory at fe9f0000 (64-bit, non-prefetchable) [size=32K]
>         Expansion ROM at fe800000 [disabled] [size=1M]
>         Capabilities: [40] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA 
> PME(D0-,D1-,D2-,D3hot-,D3cold-)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
>         Capabilities: [50] Message Signalled Interrupts: Mask+ 64bit+ 
> Queue=0/5 Enable-
>                 Address: 0000000000000000  Data: 0000
>                 Masking: 00000000  Pending: 00000000
>         Capabilities: [70] MSI-X: Enable+ Mask- TabSize=32
>                 Vector table: BAR=2 offset=00000000
>                 PBA: BAR=2 offset=00004000
>         Capabilities: [80] Express Endpoint IRQ 0
>                 Device: Supported: MaxPayload 1024 bytes, PhantFunc 0, 
> ExtTag-
>                 Device: Latency L0s <4us, L1 <8us
>                 Device: AtnBtn- AtnInd- PwrInd-
>                 Device: Errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
>                 Device: RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop-
>                 Device: MaxPayload 128 bytes, MaxReadReq 128 bytes
>                 Link: Supported Speed 2.5Gb/s, Width x8, ASPM L0s, Port 1
>                 Link: Latency L0s <512ns, L1 <64us
>                 Link: ASPM Disabled RCB 128 bytes CommClk- ExtSynch-
>                 Link: Speed 2.5Gb/s, Width x8
>         Capabilities: [94] Vendor Specific Information
>         Capabilities: [9c] Vendor Specific Information
> 
> 84:00.1 Ethernet controller: Sun Microsystems Computer Corp. 
> Multithreaded 10 Gigabit Ethernet Network Controller (rev 01)
>         Subsystem: Sun Microsystems Computer Corp. Unknown device 0000
>         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- 
> ParErr- Stepping- SERR- FastB2B-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
> <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 0, Cache Line Size: 64 bytes
>         Interrupt: pin B routed to IRQ 42
>         Region 0: Memory at fc000000 (64-bit, non-prefetchable) [size=16M]
>         Region 2: Memory at fe9e8000 (64-bit, non-prefetchable) [size=32K]
>         Region 4: Memory at fe9e0000 (64-bit, non-prefetchable) [size=32K]
>         Expansion ROM at fe700000 [disabled] [size=1M]
>         Capabilities: [40] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA 
> PME(D0-,D1-,D2-,D3hot-,D3cold-)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
>         Capabilities: [50] Message Signalled Interrupts: Mask+ 64bit+ 
> Queue=0/5 Enable-
>                 Address: 0000000000000000  Data: 0000
>                 Masking: 00000000  Pending: 00000000
>         Capabilities: [70] MSI-X: Enable- Mask- TabSize=32
>                 Vector table: BAR=2 offset=00000000
>                 PBA: BAR=2 offset=00004000
>         Capabilities: [80] Express Endpoint IRQ 0
>                 Device: Supported: MaxPayload 1024 bytes, PhantFunc 0, 
> ExtTag-
>                 Device: Latency L0s <4us, L1 <8us
>                 Device: AtnBtn- AtnInd- PwrInd-
>                 Device: Errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
>                 Device: RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop-
>                 Device: MaxPayload 128 bytes, MaxReadReq 128 bytes
>                 Link: Supported Speed 2.5Gb/s, Width x8, ASPM L0s, Port 1
>                 Link: Latency L0s <512ns, L1 <64us
>                 Link: ASPM Disabled RCB 128 bytes CommClk- ExtSynch-
>                 Link: Speed 2.5Gb/s, Width x8
>         Capabilities: [94] Vendor Specific Information
>         Capabilities: [9c] Vendor Specific Information
> 
> 84:00.2 Ethernet controller: Sun Microsystems Computer Corp. 
> Multithreaded 10 Gigabit Ethernet Network Controller (rev 01)
>         Subsystem: Sun Microsystems Computer Corp. Unknown device 0000
>         Control: I/O- Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- 
> ParErr- Stepping- SERR- FastB2B-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
> <TAbort- <MAbort- >SERR- <PERR-
>         Interrupt: pin C routed to IRQ 41
>         Region 0: Memory at fb000000 (64-bit, non-prefetchable) [size=16M]
>         Region 2: Memory at fe9d8000 (64-bit, non-prefetchable) [size=32K]
>         Region 4: Memory at fe9d0000 (64-bit, non-prefetchable) [size=32K]
>         Expansion ROM at fe600000 [disabled] [size=1M]
>         Capabilities: [40] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA 
> PME(D0-,D1-,D2-,D3hot-,D3cold-)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
>         Capabilities: [50] Message Signalled Interrupts: Mask+ 64bit+ 
> Queue=0/5 Enable-
>                 Address: 0000000000000000  Data: 0000
>                 Masking: 00000000  Pending: 00000000
>         Capabilities: [70] MSI-X: Enable- Mask- TabSize=32
>                 Vector table: BAR=2 offset=00000000
>                 PBA: BAR=2 offset=00004000
>         Capabilities: [80] Express Endpoint IRQ 0
>                 Device: Supported: MaxPayload 1024 bytes, PhantFunc 0, 
> ExtTag-
>                 Device: Latency L0s <4us, L1 <8us
>                 Device: AtnBtn- AtnInd- PwrInd-
>                 Device: Errors: Correctable- Non-Fatal+ Fatal+ Unsupported-
>                 Device: RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
>                 Device: MaxPayload 128 bytes, MaxReadReq 128 bytes
>                 Link: Supported Speed 2.5Gb/s, Width x8, ASPM L0s, Port 1
>                 Link: Latency L0s <512ns, L1 <64us
>                 Link: ASPM Disabled RCB 128 bytes CommClk- ExtSynch-
>                 Link: Speed 2.5Gb/s, Width x8
>         Capabilities: [94] Vendor Specific Information
>         Capabilities: [9c] Vendor Specific Information
> 
> 84:00.3 Ethernet controller: Sun Microsystems Computer Corp. 
> Multithreaded 10 Gigabit Ethernet Network Controller (rev 01)
>         Subsystem: Sun Microsystems Computer Corp. Unknown device 0000
>         Control: I/O- Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- 
> ParErr- Stepping- SERR- FastB2B-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
> <TAbort- <MAbort- >SERR- <PERR-
>         Interrupt: pin D routed to IRQ 40
>         Region 0: Memory at fa000000 (64-bit, non-prefetchable) [size=16M]
>         Region 2: Memory at fe9c8000 (64-bit, non-prefetchable) [size=32K]
>         Region 4: Memory at fe9c0000 (64-bit, non-prefetchable) [size=32K]
>         Expansion ROM at fe500000 [disabled] [size=1M]
>         Capabilities: [40] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA 
> PME(D0-,D1-,D2-,D3hot-,D3cold-)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
>         Capabilities: [50] Message Signalled Interrupts: Mask+ 64bit+ 
> Queue=0/5 Enable-
>                 Address: 0000000000000000  Data: 0000
>                 Masking: 00000000  Pending: 00000000
>         Capabilities: [70] MSI-X: Enable- Mask- TabSize=32
>                 Vector table: BAR=2 offset=00000000
>                 PBA: BAR=2 offset=00004000
>         Capabilities: [80] Express Endpoint IRQ 0
>                 Device: Supported: MaxPayload 1024 bytes, PhantFunc 0, 
> ExtTag-
>                 Device: Latency L0s <4us, L1 <8us
>                 Device: AtnBtn- AtnInd- PwrInd-
>                 Device: Errors: Correctable- Non-Fatal+ Fatal+ Unsupported-
>                 Device: RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
>                 Device: MaxPayload 128 bytes, MaxReadReq 128 bytes
>                 Link: Supported Speed 2.5Gb/s, Width x8, ASPM L0s, Port 1
>                 Link: Latency L0s <512ns, L1 <64us
>                 Link: ASPM Disabled RCB 128 bytes CommClk- ExtSynch-
>                 Link: Speed 2.5Gb/s, Width x8
>         Capabilities: [94] Vendor Specific Information
>         Capabilities: [9c] Vendor Specific Information
> 

