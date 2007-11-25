From: Elvis Pranskevichus <el@prans.net>
Subject: Re: sky2: eth0: hung mac 7:69 fifo 0 (165:176)
Date: Sun, 25 Nov 2007 16:57:42 -0500
Message-ID: <200711251657.42821.el@prans.net>
References: <873av03c0f.fsf@burly.wgtn.ondioline.org> <E1Iw7Ig-0000zL-6Z@asgard.prans.org> <4749E832.1060800@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Paul Collins <paul@burly.ondioline.org>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.prans.org ([64.79.206.200]:49698 "EHLO mail.prans.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753062AbXKYWjp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Nov 2007 17:39:45 -0500
In-Reply-To: <4749E832.1060800@linux-foundation.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday November 25 2007 04:25:06 pm Stephen Hemminger wrote:
>
> Two important bits of data:
>
> 1) What is hardware (output of lspci and dmesg) would be useful to know
> which type
> of board is involved.

uname -srvm:

Linux 2.6.24-rc3 #1 SMP PREEMPT Sat Nov 17 00:26:41 EST 2007 x86_64

CONFIG_NO_HZ=y

lscpi -vvvv:

03:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8053 PCI-E Gigabit Ethernet Controller (rev 22)
        Subsystem: Giga-byte Technology Marvell 88E8053 Gigabit Ethernet Controller (Gigabyte)
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0, Cache Line Size: 32 bytes
        Interrupt: pin A routed to IRQ 315
        Region 0: Memory at f1000000 (64-bit, non-prefetchable) [size=16K]
        Region 2: I/O ports at a000 [size=256]
        [virtual] Expansion ROM at f0000000 [disabled] [size=128K]
        Capabilities: [48] Power Management version 2
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=1 PME-
        Capabilities: [50] Vital Product Data
        Capabilities: [5c] Message Signalled Interrupts: Mask- 64bit+ Queue=0/1 Enable+
                Address: 00000000fee0300c  Data: 4199
        Capabilities: [e0] Express (v1) Legacy Endpoint, MSI 00
                DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s unlimited, L1 unlimited
                        ExtTag- AttnBtn- AttnInd- PwrInd- RBE- FLReset-
                DevCtl: Report errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
                        RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
                        MaxPayload 128 bytes, MaxReadReq 512 bytes
                DevSta: CorrErr+ UncorrErr+ FatalErr- UnsuppReq+ AuxPwr+ TransPend-
                LnkCap: Port #0, Speed 2.5GT/s, Width x1, ASPM L0s, Latency L0 <256ns, L1 unlimited
                        ClockPM- Suprise- LLActRep- BwNot-
                LnkCtl: ASPM Disabled; RCB 128 bytes Disabled- Retrain- CommClk-
                        ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
        Capabilities: [100] Advanced Error Reporting

dmesg | grep sky2:

sky2 0000:03:00.0: v1.20 addr 0xf1000000 irq 16 Yukon-EC (0xb6) rev 2
sky2 eth0: addr 00:16:e6:84:58:5d
sky2 eth0: enabling interface
sky2 eth0: Link is up at 100 Mbps, full duplex, flow control both

Error related part:

sky2 eth0: hung mac 123:3 fifo 194 (150:144)
sky2 eth0: receiver hang detected
sky2 eth0: disabling interface
NETDEV WATCHDOG: eth0: transmit timed out
sky2 eth0: tx timeout
sky2 eth0: transmit ring 178 .. 188 report=178 done=178
NETDEV WATCHDOG: eth0: transmit timed out
sky2 eth0: tx timeout
sky2 eth0: transmit ring 178 .. 188 report=178 done=178
...
<repeats endlessly>

>
> 2) Is this a regression, or always the case.  Does 2.6.23 work okay?
>

2.6.23 works okay in terms of restarting the controller properly, 
i.e sky2_watchdog() actually works. While in 2.6.24 I only see that
sky2_down() is called and never gets to sky2_up(). Moreover, the entire
box becomes unresponsive to events (e.g the keyboard doesn't work etc).

> The problems with FIFO in the past, have been limited to Yukon-EC
> without flow control.
> The hardware has bugs where if the FIFO gets exactly filled it hangs.
> Flow control avoids
> the problem.

Yeah, unfortunately it's Yukon-EC.


Thanks,
-- 
                Elvis
