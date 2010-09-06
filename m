From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: bnx2: link drops when idle on 2.6.36-rc3
Date: Mon, 6 Sep 2010 08:25:00 -0700
Message-ID: <C27F8246C663564A84BB7AB3439772421B9134BA22@IRVEXCHCCR01.corp.ad.broadcom.com>
References: <20100906100932.GA15029@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>
To: "'Michael S. Tsirkin'" <mst@redhat.com>,
	"Yaniv Rosner" <yaniv.rosner@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3306 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750929Ab0IFPZI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Sep 2010 11:25:08 -0400
In-Reply-To: <20100906100932.GA15029@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael S. Tsirkin wrote:

> I have an IBM server which after switching to 2.6.36-rc3, started
> experiencing
> link drops, where link would go down apparently at random. The link can
> be
> brought back up without issues.
> I started seing this after switching to 2.6.36-rc3.
> net-2.6 (0b5d404e349c0236b11466c0a4785520c0be6982) also has this issue,
> 2.6.34 seems to work fine. Did not try bisecting or testing 2.6.35 yet.
> Even log in hardware monitor shows e.g.
> 
> 	SERVPROC 	 05/17/01, 20:13:28 	LAN: Ethernet[0] interface is
> now active
> 	SERVPROC 	 05/17/01, 20:09:10 	LAN: Ethernet[0] interface is
> no longer active
> 	SERVPROC 	 05/17/01, 19:40:06 	LAN: Ethernet[0] interface is
> now active
> 	SERVPROC 	 05/17/01, 19:36:42 	LAN: Ethernet[0] interface is
> no longer active
> 
> The server is mostly idle when this happens.  lspci output for the
> device is below.  There appears nothing interesting in dmesg.

dmesg should print a linkdown message when link goes down.  Please check.
Please also provide mii-tool -vvv output when the link is up and when the
link is down.  Thanks.

> I can open a bugzilla at kernel.org if needed, just need to test
> 2.6.35 first.
> 
> 
> 04:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM5708
> Gigabit Ethernet (rev 12)
> 	Subsystem: IBM Device 0342
> 	Control: I/O- Mem+ BusMaster+ SpecCycle+ MemWINV+ VGASnoop-
> ParErr+ Stepping- SERR+ FastB2B- DisINTx+
> 	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
> 	Latency: 64 (16000ns min), Cache Line Size: 64 bytes
> 	Interrupt: pin A routed to IRQ 51
> 	Region 0: Memory at c8000000 (64-bit, non-prefetchable)
> [size=32M]
> 	Capabilities: [40] PCI-X non-bridge device
> 		Command: DPERE- ERO- RBC=512 OST=4
> 		Status: Dev=04:00.0 64bit+ 133MHz+ SCD- USC- DC=simple
> DMMRBC=512 DMOST=8 DMCRS=32 RSCEM- 266MHz- 533MHz-
> 	Capabilities: [48] Power Management version 2
> 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-
> ,D3hot+,D3cold+)
> 		Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=1 PME-
> 	Capabilities: [50] Vital Product Data
> 		Product Name: Broadcom NetXtreme II Ethernet Controller
> 		Read-only fields:
> 			[PN] Part number: BCM95706A0
> 			[EC] Engineering changes: 220197-2
> 			[SN] Serial number: 0123456789
> 			[MN] Manufacture ID: 31 34 65 34
> 			[RV] Reserved: checksum bad, 30 byte(s) reserved
> 		End
> 	Capabilities: [58] MSI: Enable+ Count=1/1 Maskable- 64bit+
> 		Address: 00000000fee0800c  Data: 41c9
> 	Kernel driver in use: bnx2
> 	Kernel modules: bnx2
> 
> Thanks!
> 
> --
> MST


