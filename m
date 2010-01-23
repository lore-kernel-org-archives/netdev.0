From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] e1000/e1000e: don't use small hardware rx
 buffers
Date: Sat, 23 Jan 2010 01:07:56 -0800 (PST)
Message-ID: <20100123.010756.67415950.davem@davemloft.net>
References: <20100123085550.10383.68204.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	jesse.brandeburg@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51313
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751101Ab0AWJHp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jan 2010 04:07:45 -0500
In-Reply-To: <20100123085550.10383.68204.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sat, 23 Jan 2010 00:56:16 -0800

> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> When testing the "e1000: enhance frame fragment detection" (and e1000e)
> patches we found some bugs with reducing the MTU size.  The 1024 byte
> descriptor used with the 1000 mtu test also (re) introduced the
> (originally) reported bug, and causes us to need the e1000_clean_tx_irq
> "enhance frame fragment detection" fix.
> 
> So what has occured here is that 2.6.32 is only vulnerable for mtu <
> 1500 due to the jumbo specific routines in both e1000 and e1000e.
> So, 2.6.32 needs the 2kB buffer len fix for those smaller MTUs, but
> is not vulnerable to the original issue reported.  It has been pointed
> out that this vulnerability needs to be patched in older kernels that
> don't have the e1000 jumbo routine.  Without the jumbo routines, we
> need the "enhance frame fragment detection" fix the e1000, old
> e1000e is only vulnerable for < 1500 mtu, and needs a similar
> fix.  We split the patches up to provide easy backport paths.
> 
> There is only a slight bit of extra code when this fix and the
> original "enhance frame fragment detection" fixes are applied, so
> please apply both, even though it is a bit of overkill.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
