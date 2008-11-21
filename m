From: Roger Heflin <rogerheflin@gmail.com>
Subject: Re: WARNING: at net/sched/sch_generic.c:219 dev_watchdog+0xfe/0x17e()
 with tg3 network
Date: Fri, 21 Nov 2008 03:34:20 -0600
Message-ID: <4926809C.3020603@gmail.com>
References: <491954E1.2050002@gmail.com> <1226403067.7685.1598.camel@twins> <491E49AA.60407@gmail.com> <20081120030012.GC26448@xw6200.broadcom.net> <492536EE.3050804@gmail.com> <20081120171124.GA27532@xw6200.broadcom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Peter Zijlstra <peterz@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.29]:18400 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751682AbYKUJe3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 04:34:29 -0500
Received: by yx-out-2324.google.com with SMTP id 8so382335yxm.1
        for <netdev@vger.kernel.org>; Fri, 21 Nov 2008 01:34:28 -0800 (PST)
In-Reply-To: <20081120171124.GA27532@xw6200.broadcom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Matt Carlson wrote:
> On Thu, Nov 20, 2008 at 02:07:42AM -0800, Roger Heflin wrote:
>> Matt Carlson wrote:

> 
> Yes, I remember hearing something about this problem too.  That is a firmware
> problem though.  The 5789 does not have any management firmware, so that
> shouldn't be the case here.
> 

Gotcha.

>>>> If someone else runs into this issue, since I have 2 ports I would be
>>>> able to do some testing on it, right now my first port is locked up, and
>>>> the machine is running fine on the second port.
>>>>
>>>> lspci -vvv for the first (bad) port:
>>> Ah.  There it is.
>>>
>>>> 02:00.0 Ethernet controller: Broadcom Corporation NetLink BCM5789 Gigabit
>>>> Ethernet PCI Express (rev 11)
>>>>          Subsystem: Foxconn International, Inc. Unknown device 0cc1
>>>>          Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
>>>> Stepping- SERR- FastB2B-
>>>>          Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort-
>>>> <MAbort- >SERR- <PERR-
>>>>          Latency: 0, Cache Line Size: 32 bytes
>>>>          Interrupt: pin A routed to IRQ 19
>>>>          Region 0: Memory at fd8f0000 (64-bit, non-prefetchable) [size=64K]
>>>>          Expansion ROM at <ignored> [disabled]
>>>>          Capabilities: [48] Power Management version 2
>>>>                  Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
>>>> PME(D0-,D1-,D2-,D3hot+,D3cold+)
>>>>                  Status: D3 PME-Enable- DSel=0 DScale=1 PME-
>>>>          Capabilities: [50] Vital Product Data
>>>>          Capabilities: [58] Message Signalled Interrupts: Mask- 64bit+ Queue=0/3
>>>> Enable-
>>>>                  Address: 0101b8102a0f7b0c  Data: f21e
>>>>          Capabilities: [d0] Express Endpoint IRQ 0
>>>>                  Device: Supported: MaxPayload 128 bytes, PhantFunc 0, ExtTag+
>>>>                  Device: Latency L0s <4us, L1 unlimited
>>>>                  Device: AtnBtn- AtnInd- PwrInd-
>>>>                  Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
>>>>                  Device: RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
>>>>                  Device: MaxPayload 128 bytes, MaxReadReq 4096 bytes
>>>>                  Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s, Port 0
>>>>                  Link: Latency L0s <2us, L1 <64us
>>>>                  Link: ASPM Disabled RCB 64 bytes CommClk+ ExtSynch-
>>>>                  Link: Speed 2.5Gb/s, Width x1
>>>>          Capabilities: [100] Advanced Error Reporting
>>>>          Capabilities: [13c] Virtual Channel
>>> Hmmm.  No smoking gun.  Perhaps the register dump will help.
>>>
>> driver: tg3
>> version: 3.94
>> firmware-version: 5789-v3.29a
>> bus-info: 0000:02:00.0
> 
> O.K.  I'll see if I can find any problems like this in the firmware
> archives.
> 
>> tg3.c:v3.94 (August 14, 2008)
>> tg3 0000:02:00.0: PCI INT A -> GSI 19 (level, low) -> IRQ 19
>> tg3 0000:02:00.0: setting latency timer to 64
>> tg3 0000:05:01.0: PCI INT A -> GSI 22 (level, low) -> IRQ 22
>> tg3: eth0: Link is up at 1000 Mbps, full duplex.
>> tg3: eth0: Flow control is on for TX and on for RX.
>>
>> Right now I brought the interface back up (it is still broken) and setup a
>> network ip on it that other machines can ping.
>>
>> The registers are included at the end of the email.
> 
> O.K.  I'll pour over the dump and get back to you.
> 
> More below.
> 
>>>>>> Nov 11 00:44:39 computer kernel: ------------[ cut here ]------------
>>>>>> Nov 11 00:44:39 computer kernel: WARNING: at net/sched/sch_generic.c:219
>>>>>> dev_watchdog+0xfe/0x17e()
>>>>>> Nov 11 00:44:39 computer kernel: NETDEV WATCHDOG: eth0 (tg3): transmit timed out
>>> Usually the tg3_tx_timeout function dumps a few registers before
>>> resetting the chip, but I don't see that here.  Have you seen any dumps
>>> since then?
>> Is this the dump?
> 
> This would be it.  Thanks.
> 
>> Nov 12 14:58:13 computer kernel: tg3: eth0: transmit timed out, resetting
>> Nov 12 14:58:13 computer kernel: tg3: DEBUG: MAC_TX_STATUS[00000008]
>> MAC_RX_STATUS[00000006]
>> Nov 12 14:58:13 computer kernel: tg3: DEBUG: RDMAC_STATUS[00000010]
>> WDMAC_STATUS[00000000]
> 
> Here the Read DMA Status register is reporting a Read DMA PCI Parity Error.
> I've seen this before...very recently in fact.  The problem was that the
> chipset was not programmed by the BIOS correctly.  In that particular case,
> a BIOS upgrade solved the problem.  YMMV.

The board I have is a OLD board (but new to me) and I have what appears to be 
the last bios that was officially released for it, and cannot find any newer 
updates that what I have.

> 
>> Nov 12 14:58:13 computer kernel: tg3: tg3_stop_block timed out, ofs=2c00
>> enable_bit=2
>> Nov 12 14:58:13 computer kernel: tg3: tg3_stop_block timed out, ofs=1400
>> enable_bit=2
>> Nov 12 14:58:13 computer kernel: tg3: tg3_stop_block timed out, ofs=4800
>> enable_bit=2
>> Nov 12 14:58:13 computer kernel: tg3: eth0: Link is down.
>> Nov 12 14:58:16 computer kernel: tg3: eth0: Link is up at 1000 Mbps, full duplex.
>> Nov 12 14:58:16 computer kernel: tg3: eth0: Flow control is on for TX and on for RX.
>> Nov 12 15:20:37 computer kernel: tg3: eth0: transmit timed out, resetting
>> Nov 12 15:20:37 computer kernel: tg3: DEBUG: MAC_TX_STATUS[0000000b]
>> MAC_RX_STATUS[00000000]
>> Nov 12 15:20:37 computer kernel: tg3: DEBUG: RDMAC_STATUS[00000000]
>> WDMAC_STATUS[00000000]
> 
> Here the MAC TX Status register is reporting that the link is up, but
> the device is sending pause frames and rx is currently rx off'd.
> 
> Does the same problem happen if flow control is disabled?
> 

I have disabled flow control (live) but not rebooted yet I won't have time to 
reboot and test until sometime tomorrow.

