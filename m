From: kernel@zeppo.hm.uc.edu
Subject: Re: [PATCH] sky2: re-enable 88E8056 for most motherboards
Date: Sun, 13 May 2007 21:27:14 -0400
Message-ID: <20070513212714.A9311@zeppo.hm.uc.edu>
Reply-To: Rob Ogden <kernel@zeppo.hm.uc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeppo.hm.uc.edu ([129.137.4.89]:1641 "EHLO zeppo.hm.uc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758531AbXENBxc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 May 2007 21:53:32 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RE: sky2 88e8056 Gigabyte GA-965GM-S2 uATX motherboard


Stephen Hemminger wrote:
>I can use DMI to narrow down to one motherboard.
>Or just let everything through and let user's discover what's unstable, it
>fails
>relatively quickly.
>
>Could you please get full PCI info lspci -vvxxx for working/non-working
>88e8056 (Yukon EC-U)
>systems? It might be some PCI Express setup by the BIOS, but so far haven't
>found any difference that mattered.

----------------------------------------
I have now too many of these Gigabyte mobos, GA-965GM-S2 with the Marvell 88e8056
www.gigabyte.com.tw / Products / Motherboard / Products_Overview.aspx?ProductID=2388

Observations.
-------------
The problem may not be sky2 specific. I have diskless nodes where too many can NOT 
1) reliably DHCP an IP number from the server 
2) and if the pxelinux.cfg/default loads, it is not certain if the kernel or the initrd would tftp transfer.

There are two of 12 diskless nodes that work, ... always work.
All mobos are the same, all CMOS is set identically
Please do not hesitate to ask for further observations on the functionality of the sky2 module.
--------------------------------
lspci is at the bottom of this post.
--------------------------------

Thank you, "Rob Ogden" <kernel (at) zeppo . hm . uc . edu>

Details
-------
0) All systems w/ Intel Core2duo/6600, 2GB-RAM

1) DHCP/PXE-boot/NFS server 
   Suse10.0  2.6.21  was 2.6.18

2) Diskless clients
   Suse10.0  2.6.18 or 2.6.19 or 2.6.21
   I believe that the 2.6.21 kernel is using a patched sky2 but I am not remembering how recent.

3) I have played with sky2 and with sk98lin from Marvell
   There is no change in what works and does not work.

4) Netgear 24-port Gigabit unmanaged switch

The first 4 examples of this mobo worked w/o trouble on gigabit network.
These were the ones I used for setting the configuration.
As I took this configuration to waiting diskless clients, I began to experience the troubles, stopping after 9 failures out of 10.

On the bench there are 3 systems.
1) DHCP/BOOT/NFS server (no problems here)
2) Diskless node #1 (always works)
3) Diskless node #2 (will always fail at some point)

I can get much better but not reliable service from system #2 if I boot it with a Knoppix 5.1.1 CD 2.6.19 kernel.
Several times a 1GB file can "/usr/bin/scp" back and forth at 40MB/sec - going from RAM-DISK to RAM-DISK
But if I make it too busy, it will fail.
Failure comes sooner if I exercise an NFS-mount
Failure variously features - 
"kernel panic"
"link down"
"Corrupted MAC on input"
"transmit descriptor error (hardware problem)"
AND an error from marvell's driver
> eth0: -- ERROR --
> Class: Hardware failure
> Nr: 0X26b
> Msg: Mac Transmit FIFO underrun

I have flashed the BIOS from F4 to F5 to F6(latest)
Perhaps not unexpectedly, BIOS F1 exacerbates the failure.

--------------------------------
How to get system #2 NOT to fail
--------------------------------
The system #2 will NOT fail if it boots and the ethernet is then using an installed PCI-card/RTL8169 chip.
The system #2 will NOT fail when connected to a 100mbit Linksys switch
The system #2 will NOT fail when connected to 1000mbit netgear AND running Win-XP (although throughput seems to drop below 7MB/sec)

Thank you for your help on this.
"Rob Ogden" <kernel (AT) zeppo . hm . uc . edu>

----------------------------------------
lspci information
----------------------------------------
1) DHCP/BOOT/NFS server 
----------------------------------------
02:00.0 Class 0200: 11ab:4364 (rev 12)
	Subsystem: 1458:e000
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0, Cache Line Size 08
	Interrupt: pin A routed to IRQ 220
	Region 0: Memory at f1000000 (64-bit, non-prefetchable) [size=16K]
	Region 2: I/O ports at 7000 [size=256]
	[virtual] Expansion ROM at 80000000 [disabled] [size=128K]
	Capabilities: [48] Power Management version 3
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=1 PME-
	Capabilities: [50] Vital Product Data
	Capabilities: [5c] Message Signalled Interrupts: 64bit+ Queue=0/0 Enable+
		Address: 00000000fee0300c  Data: 41e9
	Capabilities: [e0] Express Legacy Endpoint IRQ 0
		Device: Supported: MaxPayload 128 bytes, PhantFunc 0, ExtTag-
		Device: Latency L0s unlimited, L1 unlimited
		Device: AtnBtn- AtnInd- PwrInd-
		Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
		Device: RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
		Device: MaxPayload 128 bytes, MaxReadReq 512 bytes
		Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s L1, Port 0
		Link: Latency L0s <256ns, L1 unlimited
		Link: ASPM Disabled RCB 128 bytes CommClk- ExtSynch-
		Link: Speed 2.5Gb/s, Width x1
	Capabilities: [100] Advanced Error Reporting
00: ab 11 64 43 07 04 10 00 12 00 00 02 08 00 00 00
10: 04 00 00 f1 00 00 00 00 01 70 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 58 14 00 e0
30: 00 00 00 00 48 00 00 00 00 00 00 00 09 01 00 00

----------------------------------------
2) Diskless node #1 (always works)
----------------------------------------
02:00.0 Class 0200: 11ab:4364 (rev 12)
	Subsystem: 1458:e000
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0, Cache Line Size 08
	Interrupt: pin A routed to IRQ 17
	Region 0: Memory at f1000000 (64-bit, non-prefetchable) [size=16K]
	Region 2: I/O ports at 8000 [size=256]
	[virtual] Expansion ROM at 80000000 [disabled] [size=128K]
	Capabilities: [48] Power Management version 3
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=1 PME-
	Capabilities: [50] Vital Product Data
	Capabilities: [5c] Message Signalled Interrupts: 64bit+ Queue=0/0 Enable-
		Address: 0000000000000000  Data: 0000
	Capabilities: [e0] Express Legacy Endpoint IRQ 0
		Device: Supported: MaxPayload 128 bytes, PhantFunc 0, ExtTag-
		Device: Latency L0s unlimited, L1 unlimited
		Device: AtnBtn- AtnInd- PwrInd-
		Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
		Device: RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
		Device: MaxPayload 128 bytes, MaxReadReq 2048 bytes
		Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s L1, Port 0
		Link: Latency L0s <256ns, L1 unlimited
		Link: ASPM Disabled RCB 128 bytes CommClk- ExtSynch-
		Link: Speed 2.5Gb/s, Width x1
	Capabilities: [100] Advanced Error Reporting
00: ab 11 64 43 07 00 10 00 12 00 00 02 08 00 00 00
10: 04 00 00 f1 00 00 00 00 01 80 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 58 14 00 e0
30: 00 00 00 00 48 00 00 00 00 00 00 00 0c 01 00 00

----------------------------------------
3) Diskless node #2 (will always fail at some point)
----------------------------------------
02:00.0 Class 0200: 11ab:4364 (rev 12)
	Subsystem: 1458:e000
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0, Cache Line Size 08
	Interrupt: pin A routed to IRQ 17
	Region 0: Memory at f1000000 (64-bit, non-prefetchable) [size=16K]
	Region 2: I/O ports at 8000 [size=256]
	[virtual] Expansion ROM at 80000000 [disabled] [size=128K]
	Capabilities: [48] Power Management version 3
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=1 PME-
	Capabilities: [50] Vital Product Data
	Capabilities: [5c] Message Signalled Interrupts: 64bit+ Queue=0/0 Enable-
		Address: 0000000000000000  Data: 0000
	Capabilities: [e0] Express Legacy Endpoint IRQ 0
		Device: Supported: MaxPayload 128 bytes, PhantFunc 0, ExtTag-
		Device: Latency L0s unlimited, L1 unlimited
		Device: AtnBtn- AtnInd- PwrInd-
		Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
		Device: RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
		Device: MaxPayload 128 bytes, MaxReadReq 2048 bytes
		Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s L1, Port 0
		Link: Latency L0s <256ns, L1 unlimited
		Link: ASPM Disabled RCB 128 bytes CommClk- ExtSynch-
		Link: Speed 2.5Gb/s, Width x1
	Capabilities: [100] Advanced Error Reporting
00: ab 11 64 43 07 00 10 00 12 00 00 02 08 00 00 00
10: 04 00 00 f1 00 00 00 00 01 80 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 58 14 00 e0
30: 00 00 00 00 48 00 00 00 00 00 00 00 0c 01 00 00

