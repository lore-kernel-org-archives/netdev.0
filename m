From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: sky2: hw csum failure
Date: Mon, 28 Nov 2011 08:50:30 -0800
Message-ID: <20111128085030.248ebcb7@nehalam.linuxnetplumber.net>
References: <4ED37A2C.5040608@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Debian Bug Tracking System <609994@bugs.debian.org>
To: Vincent Blut <vincent.debian@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44510 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752116Ab1K1Quf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Nov 2011 11:50:35 -0500
In-Reply-To: <4ED37A2C.5040608@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 28 Nov 2011 12:10:20 +0000
Vincent Blut <vincent.debian@free.fr> wrote:

> Hi,
> 
> [reference: http://bugs.debian.org/609994]
> 
> I have a Marvell ethernet controller which presents some failures when
> 'rx checksumming' is enabled,
> here is the model:
> 
> $ lspci -vvs 03:00.0
> 03:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8053 PCI-E
> Gigabit Ethernet Controller (rev 15)
>         Subsystem: Micro-Star International Co., Ltd. Marvell 88E8053
> Gigabit Ethernet Controller (MSI)
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
> ParErr- Stepping- SERR- FastB2B- DisINTx+
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 0, Cache Line Size: 32 bytes
>         Interrupt: pin A routed to IRQ 44
>         Region 0: Memory at fdbfc000 (64-bit, non-prefetchable) [size=16K]
>         Region 2: I/O ports at 7c00 [size=256]
>         [virtual] Expansion ROM at fda00000 [disabled] [size=128K]
>         Capabilities: <access denied>
>         Kernel driver in use: sky2
> 
> At first I thought it was due to the MTU size, so I tested different
> values but unfortunately without positive effect.
> Overall this issue appears randomly when the incoming traffic is high. I
> tested 2.6.32, 3.1.1, and 3.2-rc3, sadly
> all are affected. Finally, the only way to avoid those failures is to
> disabled 'rx checksumming' (ethtool -K ethX rx off).
> 
> Here is the stack trace:
> 
> [   14.615648] sky2 0000:03:00.0: eth1: enabling interface
> [   14.616452] ADDRCONF(NETDEV_UP): eth1: link is not ready
> [   17.094194] sky2 0000:03:00.0: eth1: Link is up at 1000 Mbps, full
> duplex, flow control both
> [   17.094887] ADDRCONF(NETDEV_CHANGE): eth1: link becomes ready
> [   28.080018] eth1: no IPv6 routers present
> [  563.816032] sky2 0000:03:00.0: eth1: hung mac 124:22 fifo 195 (150:145)
> [  563.816036] sky2 0000:03:00.0: eth1: receiver hang detected
> [  567.005422] sky2 0000:03:00.0: eth1: Link is up at 1000 Mbps, full
> duplex, flow control both
> [ 1040.816314] sky2 0000:03:00.0: eth1: rx error, status 0x7ffc0001
> length 1004
> [ 2097.401616] sky2 0000:03:00.0: eth1: rx error, status 0x39a339a3 length 0

This isn't really a hardware checksum failure.
Your problem is deeper than that. The internal parts of the chip are not
communicating correctly. The "hung mac" is a problem only occurs if the PCI
is really stuck. There may be a timing issue on your motherboard, or the BIOS
isn't setting up the device properly. The timing then gets messed up between
the end of frame status and the PCI shared memory region. Turning checksum
off masks the problem, but the status is probably still corrupt.

In either case the problem is beyond the ability of the driver to fix or workaround.
Your best bet is to see if there is a BIOS update, or replace the hardware.
