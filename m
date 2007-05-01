From: Daniel Drake <dsd@gentoo.org>
Subject: Re: [PATCH] sky2: re-enable 88E8056 for most motherboards
Date: Tue, 01 May 2007 09:58:28 -0400
Message-ID: <46374784.7010401@gentoo.org>
References: <20070430142349.79754c1b@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	stable@kernel.org, Francois SIMOND <curio@free.fr>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp151.iad.emailsrvr.com ([207.97.245.151]:38836 "EHLO
	smtp151.iad.emailsrvr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423606AbXEAO0O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 May 2007 10:26:14 -0400
In-Reply-To: <20070430142349.79754c1b@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen,

Stephen Hemminger wrote:
> This fixes the regression in 2.6.21 for users with 88e8056 on motherboard.
> Allow all but the Gigabyte motherboard has some unresolved bus problems.

> +	/* Some Gigabyte motherboards have 88e8056 but cause problems
> +	 * There is some unresolved hardware related problem that causes
> +	 * descriptor errors and receive data corruption.
> +	 */
> +	if (pdev->vendor == PCI_VENDOR_ID_MARVELL &&
> +	    pdev->device == 0x4364 && pdev->subsystem_vendor == 0x1458) {
> +		dev_err(&pdev->dev,
> +			"88E8056 on Gigabyte motherboards not supported\n");

Gentoo have reports of sky2 working fine on Gigabyte boards which have 
88E8056 devices:
https://bugs.gentoo.org/show_bug.cgi?id=176219

Can the patch be refined further?

Specifically:

Gigabyte DQ6
03:00.0 0200: 11ab:4364 (rev 12)
         Subsystem: 1458:e000
         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B-
         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort-
<MAbort- >SERR- <PERR-
         Latency: 0, Cache Line Size: 32 bytes
         Interrupt: pin A routed to IRQ 219
         Region 0: Memory at f7000000 (64-bit, non-prefetchable) [size=16K]
         Region 2: I/O ports at 7000 [size=256]
         [virtual] Expansion ROM at 40000000 [disabled] [size=128K]
         Capabilities: [48] Power Management version 3
                 Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA
PME(D0+,D1+,D2+,D3hot+,D3cold+)
                 Status: D0 PME-Enable- DSel=0 DScale=1 PME-
         Capabilities: [50] Vital Product Data
         Capabilities: [5c] Message Signalled Interrupts: 64bit+ Queue=0/0
Enable+
                 Address: 00000000fee0300c  Data: 413a
         Capabilities: [e0] Express Legacy Endpoint IRQ 0
                 Device: Supported: MaxPayload 128 bytes, PhantFunc 0, 
ExtTag-
                 Device: Latency L0s unlimited, L1 unlimited
                 Device: AtnBtn- AtnInd- PwrInd-
                 Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
                 Device: RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
                 Device: MaxPayload 128 bytes, MaxReadReq 512 bytes
                 Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s L1, 
Port 0
                 Link: Latency L0s <256ns, L1 unlimited
                 Link: ASPM Disabled RCB 128 bytes CommClk- ExtSynch-
                 Link: Speed 2.5Gb/s, Width x1
         Capabilities: [100] Advanced Error Reporting
00: ab 11 64 43 07 04 10 00 12 00 00 02 08 00 00 00
10: 04 00 00 f7 00 00 00 00 01 70 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 58 14 00 e0
30: 00 00 00 00 48 00 00 00 00 00 00 00 0a 01 00 00


Gigabyte S3: sorry, no lspci dump available yet

Gigabyte DS3:
04:00.0 Ethernet controller [0200]: Marvell Technology Group Ltd. Unknown
device [11ab:4364] (rev 12)
         Subsystem: Giga-byte Technology Unknown device [1458:e000]
         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B-
         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort-
<MAbort- >SERR- <PERR-
         Latency: 0, Cache Line Size: 32 bytes
         Interrupt: pin A routed to IRQ 16
         Region 0: Memory at f8000000 (64-bit, non-prefetchable) [size=16K]
         Region 2: I/O ports at 8000 [size=256]
         [virtual] Expansion ROM at 40000000 [disabled] [size=128K]
         Capabilities: [48] Power Management version 3
                 Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA
PME(D0+,D1+,D2+,D3hot+,D3cold+)
                 Status: D0 PME-Enable- DSel=0 DScale=1 PME-
         Capabilities: [50] Vital Product Data
         Capabilities: [5c] Message Signalled Interrupts: Mask- 64bit+ 
Queue=0/0
Enable-
                 Address: 0000000000000000  Data: 0000
         Capabilities: [e0] Express Legacy Endpoint IRQ 0
                 Device: Supported: MaxPayload 128 bytes, PhantFunc 0, 
ExtTag-
                 Device: Latency L0s unlimited, L1 unlimited
                 Device: AtnBtn- AtnInd- PwrInd-
                 Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
                 Device: RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
                 Device: MaxPayload 128 bytes, MaxReadReq 512 bytes
                 Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s L1, 
Port 0
                 Link: Latency L0s <256ns, L1 unlimited
                 Link: ASPM Disabled RCB 128 bytes CommClk- ExtSynch-
                 Link: Speed 2.5Gb/s, Width x1
         Capabilities: [100] Advanced Error Reporting
00: ab 11 64 43 07 00 10 00 12 00 00 02 08 00 00 00
10: 04 00 00 f8 00 00 00 00 01 80 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 58 14 00 e0
30: 00 00 00 00 48 00 00 00 00 00 00 00 0b 01 00 00


