From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH net 0/2] net: marvell: Fix highmem support on non-TSO path
Date: Thu, 22 Jan 2015 21:09:51 +0000
Message-ID: <20150122210951.GC26493@n2100.arm.linux.org.uk>
References: <1421844850-30886-1-git-send-email-ezequiel.garcia@free-electrons.com>
 <20150121150159.GS26493@n2100.arm.linux.org.uk>
 <54C1443C.80909@tpi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	B38611@freescale.com, fabio.estevam@freescale.com
To: Dean Gehnert <deang@tpi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:46889 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755020AbbAVVKB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2015 16:10:01 -0500
Content-Disposition: inline
In-Reply-To: <54C1443C.80909@tpi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 22, 2015 at 10:41:00AM -0800, Dean Gehnert wrote:
> FYI, I found a way to reproduce the mv643xx_eth transmit corruption without
> using a network filesystem by using SOCAT (should also be able to use NETCAT
> or NC) and I have a bit more information about the corruption that looks
> like it is somehow related to the cache line size.

That's not quite what I'm seeing.  What I'm seeing with NFS is that the
machine is basically unusable.  I have the etna_viv source in a NFS
share (it's shared amongst not only the Dove box but also my collection
of iMX6 based hardware.)

I'm fairly fully IPv6 enabled here, which includes NFS.

On the Dove, if I try to build this without any fixes, and then try to
build the etna_viv sources, it will take the machine out to the extent
that I have to reboot it - either the machine will freeze solidly, or
the kernel will oops in the DMA API functions, in a path which was
called from an interrupt handler.  That takes out the entire machine
because we miss acknowleding the interrupt.

Either way, it's effectively a power cycle as there's no reset button on
the machine.

I have yet to see any sign of data corruption.

-- 
FTTC broadband for 0.8mile line: currently at 10.5Mbps down 400kbps up
according to speedtest.net.
