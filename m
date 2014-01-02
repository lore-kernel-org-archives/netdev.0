From: Yuval Mintz <yuvalmin@broadcom.com>
Subject: RE: [PATCH net-next 2/2] net/mlx4: Revert "mlx4: set maximal number
 of default RSS queues"
Date: Thu, 2 Jan 2014 06:04:49 +0000
Message-ID: <979A8436335E3744ADCD3A9F2A2B68A52AF21C13@SJEXCHMB10.corp.ad.broadcom.com>
References: <1388581537-4810-1-git-send-email-amirv@mellanox.com>
	<1388581537-4810-3-git-send-email-amirv@mellanox.com>
	<979A8436335E3744ADCD3A9F2A2B68A52AF21A1A@SJEXCHMB10.corp.ad.broadcom.com>
 <CAJZOPZ++ETzuttO9_ZTy6Atx6=wKyhXUhxyQHj2Ed5nTUBNC0A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Amir Vadai <amirv@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Ido Shamay <idos@mellanox.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:60612 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750860AbaABGEu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 01:04:50 -0500
In-Reply-To: <CAJZOPZ++ETzuttO9_ZTy6Atx6=wKyhXUhxyQHj2Ed5nTUBNC0A@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > [...] If you believe this is a better default (or some relaxation will be, e.g.,  16
> instead of 8),  why not set it as default for ALL multi-queue networking
> drivers?
> 
> Going back to your original commit 16917b87a "net-next: Add
> netif_get_num_default_rss_queues" I am still not clear why we want
> 
> 1. why we want a common default to all MQ devices?

Although networking benefits from multiple Interrupt vectors
(enabling more rings, better performance, etc.), bounding this
number only to the number of cpus is unreasonable as it strains
system resources; e.g., consider a 40-cpu server - we might wish
to have 40 vectors per device, but that means that connecting
several devices to the same server might cause other functions 
to fail probe as they will no longer be able to acquire interrupt
vectors of their own.

Since networking has an API allowing the user to manually set the
number of channels, the default is upper-bounded.

> 2. why this default has to be hard coded and not derived e.g from the
> number of cores or alike attribute of the system?

This is not entirely correct; The default number is derived from
the number of online cpus - it's only upper bounded by some
hard-coded value.

Cheers,
Yuval
