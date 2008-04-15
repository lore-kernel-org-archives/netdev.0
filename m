From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: Re: [PATCH] macb: Call phy_disconnect on removing
Date: Wed, 16 Apr 2008 01:35:20 +0900 (JST)
Message-ID: <20080416.013520.74752756.anemo@mba.ocn.ne.jp>
References: <20080410.233007.41197293.anemo@mba.ocn.ne.jp>
	<48005E6E.3010802@garzik.org>
	<20080415015331.b6ab8963.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, hskinnemoen@atmel.com, netdev@vger.kernel.org,
	stable@kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mba.ocn.ne.jp ([122.1.235.107]:58453 "EHLO smtp.mba.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755410AbYDOQe1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Apr 2008 12:34:27 -0400
In-Reply-To: <20080415015331.b6ab8963.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 15 Apr 2008 01:53:31 -0700, Andrew Morton <akpm@linux-foundation.org> wrote:
> > applied
> 
> Needed in 2.6.24.x as well, I think?

Yes, though I suppose this driver is not widely used as a module.
CC-ed to stable@kernel.org.

commit 84b7901f8d5a17536ef2df7fd628ab865df8fe3a
Author: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Date:   Thu Apr 10 23:30:07 2008 +0900

    macb: Call phy_disconnect on removing
    
    Call phy_disconnect() on remove routine.  Otherwise the phy timer
    causes a kernel crash when unloading.
    
    Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
    Signed-off-by: Jeff Garzik <jgarzik@redhat.com>

diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index 1d210ed..10fcea5 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -1257,6 +1257,8 @@ static int __exit macb_remove(struct platform_device *pdev)
 
 	if (dev) {
 		bp = netdev_priv(dev);
+		if (bp->phy_dev)
+			phy_disconnect(bp->phy_dev);
 		mdiobus_unregister(&bp->mii_bus);
 		kfree(bp->mii_bus.irq);
 		unregister_netdev(dev);
