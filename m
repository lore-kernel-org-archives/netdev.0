From: Yuval Mintz <yuvalmin@broadcom.com>
Subject: RE: [PATCH net-next 2/2] net/mlx4: Revert "mlx4: set maximal number
 of default RSS queues"
Date: Wed, 15 Jan 2014 12:54:27 +0000
Message-ID: <979A8436335E3744ADCD3A9F2A2B68A52AF2849F@SJEXCHMB10.corp.ad.broadcom.com>
References: <1388581537-4810-1-git-send-email-amirv@mellanox.com>
	<1388581537-4810-3-git-send-email-amirv@mellanox.com>
	<979A8436335E3744ADCD3A9F2A2B68A52AF21A1A@SJEXCHMB10.corp.ad.broadcom.com>
 <CAJZOPZ++ETzuttO9_ZTy6Atx6=wKyhXUhxyQHj2Ed5nTUBNC0A@mail.gmail.com>
 <979A8436335E3744ADCD3A9F2A2B68A52AF21C13@SJEXCHMB10.corp.ad.broadcom.com>
 <52C532DB.9000200@mellanox.com>
 <979A8436335E3744ADCD3A9F2A2B68A52AF21E1F@SJEXCHMB10.corp.ad.broadcom.com>
 <52D67BFF.6070102@dev.mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Amir Vadai <amirv@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Ido Shamay <idos@mellanox.com>
To: Ido Shamai <idos@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:60004 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751499AbaAOMy2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 07:54:28 -0500
In-Reply-To: <52D67BFF.6070102@dev.mellanox.co.il>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Anyway, I believe 8/16 are simply strict limitations without any true
> meaning;
> > To judge what's more important, default `slimness' or default performance
> > is beyond me.
> > Perhaps the numa approach will prove beneficial (and will make some
> sense).
> 
> After reviewing all that was said, I feel there is no need to enforce
> vendors with this strict limitation without any true meaning.
> 
> The reverted commit you applied forces the driver to use 8 rings at max
> at all time, without the possibility to change in flight using ethtool,
> as it's enforced on the PCI driver at module init (restarting the en
> driver with different of requested rings will not affect).
> So it's crucial for performance oriented applications using mlx4_en.

The rational is to prevent default misusage of resources, be them irq vectors
memories for rings.
Notice this is just the default - You can always re-request interrupts if the
user explicitly requests a large number of rings;
Although, if the driver is incapable of that (e.g., hw limitations), perhaps you
should allocate a larger number of irq vectors during init and use a limitation
on your default number of rings 
(that's assuming that irq vectors are really inexpensive on all machines).

> Going through all Ethernet vendors I don't see this limitation enforced,
> so this limitation has no true meaning (no fairness).
> I think this patch should go in as is.
> Ethernet vendors should use it this limitation when they desire.

Might be true, but two wrongs don't make a right.
I believe that either this limitation should be mandatory, or the functionality
Should Not be included in the kernel as communal code and each driver
should do as it pleases.
