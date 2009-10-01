From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] sky2: irqname based on pci address
Date: Thu, 1 Oct 2009 10:14:50 -0700
Message-ID: <20091001101450.371a2982@s6510>
References: <20090922120127.14242.71353.stgit@localhost.localdomain>
	<20090922092826.5302225c@s6510>
	<20091001122720.3822bdd3@leela>
	<20091001101146.3368b4a4@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Michal Schmidt <mschmidt@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54714 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755078AbZJAROr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Oct 2009 13:14:47 -0400
In-Reply-To: <20091001101146.3368b4a4@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 1 Oct 2009 10:11:46 -0700
Stephen Hemminger <shemminger@vyatta.com> wrote:

> This is based on Michal Schmidt fix for skge.
> 
> Most network drivers request their IRQ when the interface is activated.
> sky2 does it in ->probe() instead, because it can work with two-port
> cards where the two net_devices use the same IRQ. This works fine most
> of the time, except in some situations when the interface gets renamed.
> Consider this example:
> 
> 1. modprobe sky2
>    The card is detected as eth0 and requests IRQ 17. Directory
>    /proc/irq/17/eth0 is created.
> 2. There is an udev rule which says this interface should be called
>    eth1, so udev renames eth0 -> eth1.
> 3. modprobe 8139too
>    The Realtek card is detected as eth0. It will be using IRQ 17 too.
> 4. ip link set eth0 up
>    Now 8139too requests IRQ 17.

One other note, the issue is less of a problem for most usage of sky2
because the drive is used mostly on systems that support MSI interrupts
which can never be shared.
