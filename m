From: Yuval Mintz <yuvalmin@broadcom.com>
Subject: RE: [PATCH net-next 2/2] net/mlx4: Revert "mlx4: set maximal number
 of default RSS queues"
Date: Thu, 2 Jan 2014 10:27:02 +0000
Message-ID: <979A8436335E3744ADCD3A9F2A2B68A52AF21E1F@SJEXCHMB10.corp.ad.broadcom.com>
References: <1388581537-4810-1-git-send-email-amirv@mellanox.com>
	<1388581537-4810-3-git-send-email-amirv@mellanox.com>
	<979A8436335E3744ADCD3A9F2A2B68A52AF21A1A@SJEXCHMB10.corp.ad.broadcom.com>
 <CAJZOPZ++ETzuttO9_ZTy6Atx6=wKyhXUhxyQHj2Ed5nTUBNC0A@mail.gmail.com>
 <979A8436335E3744ADCD3A9F2A2B68A52AF21C13@SJEXCHMB10.corp.ad.broadcom.com>
 <52C532DB.9000200@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Amir Vadai <amirv@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Ido Shamay <idos@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>,
	Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:48133 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750711AbaABK1F convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 05:27:05 -0500
In-Reply-To: <52C532DB.9000200@mellanox.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >> Going back to your original commit 16917b87a "net-next: Add
> >> netif_get_num_default_rss_queues" I am still not clear why we want
> >>
> >> 1. why we want a common default to all MQ devices?
> > Although networking benefits from multiple Interrupt vectors
> > (enabling more rings, better performance, etc.), bounding this
> > number only to the number of cpus is unreasonable as it strains
> > system resources; e.g., consider a 40-cpu server - we might wish
> > to have 40 vectors per device, but that means that connecting
> > several devices to the same server might cause other functions
> > to fail probe as they will no longer be able to acquire interrupt
> > vectors of their own.
> 
> Modern servers which have tens of CPUs typically have thousands of MSI-X
> vectors which means you should be easily able to plug four cards into a
> server with 64 cores which will consume 256 out of the 1-4K vectors out
> there. Anyway, let me continue your approach - how about raising the
> default hard limit to 16 or having it as the number of cores @ the numa
> node where the card is plugged?

I think an additional issue was memory consumption -
additional interrupts --> additional allocated memory (for Rx rings).
And I do know the issues were real - we've had complains about devices
failing to load due to lack of resources (not all servers in the world are
top of the art).

Anyway, I believe 8/16 are simply strict limitations without any true meaning;
To judge what's more important, default `slimness' or default performance
is beyond me.
Perhaps the numa approach will prove beneficial (and will make some sense).

Thanks,
Yuval
