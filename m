From: Paul Collins <paul@burly.ondioline.org>
Subject: sky2: eth0: hung mac 7:69 fifo 0 (165:176)
Date: Wed, 21 Nov 2007 09:20:00 +1300
Message-ID: <873av03c0f.fsf@burly.wgtn.ondioline.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from jenny.ondioline.org ([66.220.1.122]:49640 "EHLO
	jenny.ondioline.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753527AbXKTUar (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 15:30:47 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen,

Running amd64 kernel built from 2ffbb8377c7a0713baf6644e285adc27a5654582
after about three days of uptime, this morning I found the network dead
and the following in dmesg:

  sky2 eth0: hung mac 7:69 fifo 0 (165:176)
  sky2 eth0: receiver hang detected
  sky2 eth0: disabling interface
  NETDEV WATCHDOG: eth0: transmit timed out
  sky2 eth0: tx timeout
  sky2 eth0: transmit ring 26 .. 26 report=26 done=26
  NETDEV WATCHDOG: eth0: transmit timed out
  sky2 eth0: tx timeout
  sky2 eth0: transmit ring 26 .. 26 report=26 done=26

The watchdog had been blorping for about three hours when I discovered
it and rebooted the machine.

Here's what the driver prints on init:

  sky2 0000:01:00.0: v1.20 addr 0x50200000 irq 16 Yukon-EC (0xb6) rev 2

And lspci -vvvv for the device:

  01:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8053 PCI-E Gigabit Ethernet Controller (rev 22)
          Subsystem: Marvell Technology Group Ltd. Marvell RDK-8053
          Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
          Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
          Latency: 0, Cache Line Size: 256 bytes
          Interrupt: pin A routed to IRQ 1277
          Region 0: Memory at 50200000 (64-bit, non-prefetchable) [size=16K]
          Region 2: I/O ports at 1000 [size=256]
          Expansion ROM at 50220000 [disabled] [size=128K]
          Capabilities: [48] Power Management version 2
                  Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot
  +,D3cold+)
                  Status: D0 PME-Enable- DSel=0 DScale=1 PME-
          Capabilities: [50] Vital Product Data
          Capabilities: [5c] Message Signalled Interrupts: Mask- 64bit+ Queue=0/1 Enable+
                  Address: 00000000fee0200c  Data: 4169
          Capabilities: [e0] Express Legacy Endpoint IRQ 0
                  Device: Supported: MaxPayload 128 bytes, PhantFunc 0, ExtTag-
                  Device: Latency L0s unlimited, L1 unlimited
                  Device: AtnBtn- AtnInd- PwrInd-
                  Device: Errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
                  Device: RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
                  Device: MaxPayload 128 bytes, MaxReadReq 2048 bytes
                  Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s, Port 0
                  Link: Latency L0s <256ns, L1 unlimited
                  Link: ASPM Disabled RCB 128 bytes CommClk+ ExtSynch-
                  Link: Speed 2.5Gb/s, Width x1
          Capabilities: [100] Advanced Error Reporting


Please let me know if you need more information.

-- 
Paul Collins
Wellington, New Zealand

Dag vijandelijk luchtschip de huismeester is dood
