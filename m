From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phylib: Move workqueue initialization to a proper place
Date: Tue, 19 Jan 2010 02:00:29 -0800 (PST)
Message-ID: <20100119.020029.55299562.davem@davemloft.net>
References: <B85A65D85D7EB246BE421B3FB0FBB59301E2025EED@dbde02.ent.ti.com>
	<20100117.192353.85482728.davem@davemloft.net>
	<20100118153716.GA30861@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nsekhar@ti.com, netdev@vger.kernel.org
To: avorontsov@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50773
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756459Ab0ASKAW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2010 05:00:22 -0500
In-Reply-To: <20100118153716.GA30861@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Vorontsov <avorontsov@ru.mvista.com>
Date: Mon, 18 Jan 2010 18:37:16 +0300

> commit 541cd3ee00a4fe975b22fac6a3bc846bacef37f7 ("phylib: Fix deadlock
> on resume") caused TI DaVinci EMAC ethernet driver to oops upon resume:
 ...
> The oops pops up because TI DaVinci EMAC driver detaches PHY on
> suspend and attaches it back on resume. Attaching makes phylib call
> phy_start_machine() that initializes a workqueue. On the other hand,
> PHY's resume routine will call phy_start_machine() again, and that
> will cause the oops since we just destroyed the already scheduled
> workqueue.
> 
> This patch fixes the issue by moving workqueue initialization to
> phy_device_create().
> 
> p.s. We don't see this oops with ucc_geth and gianfar drivers because
> they perform a fine-grained suspend, i.e. they just stop the PHYs
> without detaching.
> 
> Reported-by: Sekhar Nori <nsekhar@ti.com>
> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
> Tested-by: Sekhar Nori <nsekhar@ti.com>

Applied, thanks.
