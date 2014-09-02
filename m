From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH 1/1] drivers: net: cpsw: dual_emac: fix reducing of
 rx descriptor during ifdown
Date: Mon, 01 Sep 2014 18:31:08 -0700 (PDT)
Message-ID: <20140901.183108.784916699845611422.davem@davemloft.net>
References: <1409304145-26179-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mugunthanvnm@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46017 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751227AbaIBBbJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 21:31:09 -0400
In-Reply-To: <1409304145-26179-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mugunthan V N <mugunthanvnm@ti.com>
Date: Fri, 29 Aug 2014 14:52:25 +0530

> In Dual EMAC, when both interface are up and while doing ifdown with heavy
> traffic then skbs already processed by DMA from that slave emac has to be
> requeued as still the other interface is up and running.
> 
> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>

I don't see why this is important.

If the packet arrived via the down interface, let it be dropped and
the sender will simply resend if necessary.

Also you are putting this new multi-slave logic under the "status < 0"
condition as well as the interface being down, that's not right either.
