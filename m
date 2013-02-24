From: Tomi Orava <tomimo@ncircle.nullnet.fi>
Subject: Re: Fw: [Bug 54231] r8169 driver regression caused by the commit
 aee77e4accbeb2c86b1d294cd84fec4a12dde3bd
Date: Sun, 24 Feb 2013 17:03:12 +0200
Message-ID: <512A2BB0.9050803@ncircle.nullnet.fi>
References: <20130222095546.396e63a8@nehalam.linuxnetplumber.net> <20130222230908.GB4248@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xdsl-83-150-88-111.nebulazone.fi ([83.150.88.111]:36627 "EHLO
	ncircle.nullnet.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757922Ab3BXPJt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Feb 2013 10:09:49 -0500
In-Reply-To: <20130222230908.GB4248@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/23/2013 01:09 AM, Francois Romieu wrote:
> Stephen Hemminger <stephen@networkplumber.org> :
> [...]
>> https://bugzilla.kernel.org/show_bug.cgi?id=54231
> This one should not be used in the (RTL_CFG_1) 8168 / RTL_GIGA_MAC_VER_11
> path.

I started re-testing after your comment and figured out that the
real problem seems to lie somehow with jumbo frames. Ie. the DMA burst
changes do not actually prevent the hangs at all in my case. The
catch here, that I missed previously, was that for some interesting
reason the NIC will fail in a couple of minutes with a suitable traffic
if the jumbo frames (mtu 4000) have been enabled from the start.
However, if I enable the jumbo frames manually after the system
has already started up, there are no stability issues related to network.

I ran my tests again with unmodified 3.7.9 kernel and got the
same results as with the 3.4.31 version.

> 
> Tomi, what does lspci say about your 8168b device ?

The NIC information is:

03:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/8168B PCI
Express Gigabit Ethernet controller (rev 01)

03:00.0 0200: 10ec:8168 (rev 01)
    Subsystem: 1043:8385
    Flags: bus master, fast devsel, latency 0, IRQ 40
    I/O ports at e800 [size=256]
    Memory at febff000 (64-bit, non-prefetchable) [size=4K]
    Expansion ROM at febc0000 [disabled] [size=128K]
    Capabilities: [40] Power Management version 2
    Capabilities: [48] Vital Product Data
    Capabilities: [50] MSI: Enable+ Count=1/2 Maskable- 64bit+
    Capabilities: [60] Express Endpoint, MSI 00
    Capabilities: [84] Vendor Specific Information: Len=4c <?>
    Kernel driver in use: r8169

Tomi
