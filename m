From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [git patches] net driver fixes
Date: Fri, 2 Mar 2007 08:09:41 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0703020751290.3953@woody.linux-foundation.org>
References: <20070227110233.GA14138@havoc.gtf.org>
 <Pine.LNX.4.64.0703012001110.7832@woody.linux-foundation.org>
 <45E7D516.30401@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:33431 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992562AbXCBQJt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2007 11:09:49 -0500
In-Reply-To: <45E7D516.30401@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Thu, 1 Mar 2007, Kok, Auke wrote:

> Linus Torvalds wrote:
> > 
> > Ok, here's an interesting one: my e1000 card no longer worked for a while.
> > 
> > The green link-light blinks on/off once a second, and in time to that, my
> > dmesg fills up with an endless supply of
> > 
> > 	e1000: eth0: e1000_watchdog: NIC Link is Down
> > 	e1000: eth0: e1000_watchdog: NIC Link is Up 100 Mbps Full Duplex, Flow Control: None
> > 	e1000: eth0: e1000_watchdog: 10/100 speed: disabling TSO
> > 
> > and networking obviously doesn't actually work.
> 
> Just out of curiosity, which e1000 chipset+motherboard are you running this
> on?

The kernel prints out:

	e1000: 0000:00:19.0: e1000_probe: (PCI Express:2.5Gb/s:Width x1) 00:16:76:c7:eb:fe
	e1000: eth0: e1000_probe: Intel(R) PRO/1000 Network Connection

and lspci says:

	00:19.0 Ethernet controller: Intel Corporation 82566DM Gigabit Network Connection (rev 02)
	        Subsystem: Intel Corporation Unknown device 0001
	        Flags: bus master, fast devsel, latency 0, IRQ 506
	        Memory at e0400000 (32-bit, non-prefetchable) [size=128K]
	        Memory at e0424000 (32-bit, non-prefetchable) [size=4K]
	        I/O ports at 20c0 [size=32]
	        Capabilities: <access denied>
	00: 86 80 4a 10 07 04 10 00 02 00 00 02 00 00 00 00
	10: 00 00 40 e0 00 40 42 e0 c1 20 00 00 00 00 00 00
	20: 00 00 00 00 00 00 00 00 00 00 00 00 86 80 01 00
	30: 00 00 00 00 c8 00 00 00 00 00 00 00 0b 01 00 00

It's an Intel system (Host bridge: Intel Corporation 82Q963/Q965) with 
integrated graphics: PCI ID 8086:2990 (rev 02) for the host bridge.

DMI info isn't very interesting, but it's an all-Intel board:

	OEM-specific Type
		Strings:
			Intel_ASF
			Intel_ASF_001
	..
	Base Board Information
		Manufacturer: Intel Corporation
		Product Name: DQ965GF
		Version: AAD41676-305
		Serial Number: BQGF635009R2
	...
	BIOS Information
		Vendor: Intel Corp.
		Version: CO96510J.86A.4462.2006.0804.2059
		Release Date: 08/04/2006

so it's all-intel chipset, all-intel board, and all-intel BIOS ;)

> there have been problems reported with AMT2 on several chipsets (AMT2 is
> not supported under linux, unlike AMT1), and having it enabled in the BIOS
> produces this phenomenon.

Is there some way to at least disable AMT2 from the Linux driver (ie I 
assume this is some issue of Intel not documenting it all - but maybe you 
can add a "turn off that bit" to the affected chip).

If I'm not the only one to see it, it's obviously not just my personal 
ethernet switch bug, but apparently the e1000 becoming confused by some 
link detection event (and powering down the switch probably just gets it 
out of its confusion).

			Linus
