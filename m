From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: sky2 hangs without any messages
Date: Wed, 27 Jun 2007 13:31:06 -0400
Message-ID: <20070627133106.7cf1ce5c@oldman>
References: <20070523075431.GA15935@dose.home.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Tino Keitel <tino.keitel@tikei.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:52589 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755897AbXF0RbX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2007 13:31:23 -0400
In-Reply-To: <20070523075431.GA15935@dose.home.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 23 May 2007 09:54:31 +0200
Tino Keitel <tino.keitel@tikei.de> wrote:

> Hi folks,
> 
> in the last 2 days, I had 2 outages of the NIC of my Mac mini Core Duo.
> I checked the kernel log but I found nothing sky2 related. After
> reloading the module, the interface worked again.
> 
> Both freezes were connected to access from a remote NFS client to a
> directory with ~4700 files in it. Both times, after reloading the
> module and waiting some minutes until the NFS client had recovered from
> the hanging NFS server, the same action worked.
> 
> The network is 100 mbit full duplex. I use NFS over TCP and kernel
> 2.6.21 with the "disable flow control" patch, the configuration is
> attached.
> 
> Here are the sky2 messages that appeared when I discovered the freeze
> and reloaded the driver:
> 
> sky2 eth0: disabling interface
> ACPI: PCI interrupt for device 0000:01:00.0 disabled
> ACPI: PCI Interrupt 0000:01:00.0[A] -> GSI 16 (level, low) -> IRQ 17
> PCI: Setting latency timer of device 0000:01:00.0 to 64
> sky2 0000:01:00.0: v1.14 addr 0x90200000 irq 17 Yukon-EC (0xb6) rev 2
> Device driver eth0 lacks bus and class support for being resumed.
> sky2 eth0: addr 00:16:cb:a4:e1:68
> sky2 eth0: enabling interface
> sky2 eth0: ram buffer 48K
> sky2 eth0: Link is up at 100 Mbps, full duplex, flow control none
> 


There is a reproducible hang (due to missed IRQ) in sky2.  It is more reproducible
with slower CPU's like Mac Mini.
