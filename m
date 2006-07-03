From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: Two I/O memory regions in /proc/iomem for a NIC
Date: Mon, 3 Jul 2006 23:30:35 +0200
Message-ID: <20060703213035.GD31385@xi.wantstofly.org>
References: <ada605fb0607020024o15c8e4b4j83f37102492e8932@mail.gmail.com> <20060702111224.GA6624@havoc.gtf.org> <ada605fb0607020837q5573299ke05864e130169bed@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:16098 "EHLO
	xi.wantstofly.org") by vger.kernel.org with ESMTP id S1750741AbWGCVaj
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jul 2006 17:30:39 -0400
To: John Que <qwejohn@gmail.com>
Content-Disposition: inline
In-Reply-To: <ada605fb0607020837q5573299ke05864e130169bed@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jul 02, 2006 at 06:37:18PM +0300, John Que wrote:

> Could a single call to
> pci_request_regions(pdev, driver_name)
> result in that we see 2 regions afterwards when running
> cat /proc/iomem?

Sure.  Take a look at the output of 'lspci -v' some time.  On my
machine, for example, I have:

05:11.0 Ethernet controller: Intel Corporation 82546GB Gigabit Ethernet Controller (rev 03)
        Subsystem: Intel Corporation PRO/1000 MT Dual Port Network Connection
        Flags: bus master, 66Mhz, medium devsel, latency 64, IRQ 10
        Memory at cffc0000 (64-bit, non-prefetchable) [size=128K]   <===
        Memory at cff00000 (64-bit, non-prefetchable) [size=256K]   <===
        I/O ports at e400 [size=64]
        Expansion ROM at cfec0000 [disabled] [size=256K]
        Capabilities: <available only to root>

05:11.1 Ethernet controller: Intel Corporation 82546GB Gigabit Ethernet Controller (rev 03)
        Subsystem: Intel Corporation PRO/1000 MT Dual Port Network Connection
        Flags: bus master, 66Mhz, medium devsel, latency 64, IRQ 11
        Memory at cffe0000 (64-bit, non-prefetchable) [size=128K]   <===
        Memory at cff80000 (64-bit, non-prefetchable) [size=256K]   <===
        I/O ports at e800 [size=64]
        Expansion ROM at cff40000 [disabled] [size=256K]
        Capabilities: <available only to root>

As you can see, each port of the dual-port card has two memory regions,
four a total of 4 memory regions.


cheers,
Lennert
