From: Michal Schmidt <mschmidt@redhat.com>
Subject: Re: [PATCH] sky2: irqname based on pci address
Date: Thu, 1 Oct 2009 20:03:55 +0200
Message-ID: <20091001200355.7635a8a9@leela>
References: <20090922120127.14242.71353.stgit@localhost.localdomain>
	<20090922092826.5302225c@s6510>
	<20091001122720.3822bdd3@leela>
	<20091001101146.3368b4a4@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53885 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755604AbZJAR6r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Oct 2009 13:58:47 -0400
In-Reply-To: <20091001101146.3368b4a4@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dne Thu, 1 Oct 2009 10:11:46 -0700 Stephen Hemminger napsal(a):
> This is based on Michal Schmidt fix for skge.
> 
> Most network drivers request their IRQ when the interface is
> activated. sky2 does it in ->probe() instead, because it can work
> with two-port cards where the two net_devices use the same IRQ. This
> works fine most of the time, except in some situations when the
> interface gets renamed. Consider this example:
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
> 
> The result is:
> WARNING: at fs/proc/generic.c:590 proc_register ...
> proc_dir_entry '17/eth0' already registered
> 
> The fix is for sky2 to name the irq based on the pci device, as is
> done by some other devices DRM, infiniband, ...  ie.
> sky2@pci:0000:00:00
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Reviewed-by: Michal Schmidt <mschmidt@redhat.com>
