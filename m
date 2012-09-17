From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phy: Replace genphy_update_link() call with
 phy_read_status()
Date: Mon, 17 Sep 2012 13:22:16 -0400 (EDT)
Message-ID: <20120917.132216.1721365693674127210.davem@davemloft.net>
References: <5051894B.5060001@sysgo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, afleming@freescale.com
To: asv@sysgo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59549 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755542Ab2IQRWW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2012 13:22:22 -0400
In-Reply-To: <5051894B.5060001@sysgo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Sverdlin <asv@sysgo.com>
Date: Thu, 13 Sep 2012 09:20:43 +0200

> From: Alexander Sverdlin <alexander.sverdlin@sysgo.com>
> 
> Replace genphy_update_link() call with phy_read_status() 
> 
> Code in phy.c should not call genphy_*() functions directly, this breaks PHY layer abstraction.
> Some drivers may re-implement "read_status" callback and it's not being called in one place of
> PHY state machine, where genphy_update_link() is called instead. So fix it.
> For drivers that rely on genphy_* implementation nothing changed, as genphy_read_status() calls
> genphy_update_link() anyway.
> 
> Signed-off-by: Alexander Sverdlin <alexander.sverdlin@sysgo.com>

This is a behavioral change, not just a change to make sure the right
interfaces are used.

genphy_update_link() does only a small subset of the operations
performed by the generic read_status callback.

I'm not applying this patch, because all of those extra operations
might be unexpected in some situations and break some configurations.
