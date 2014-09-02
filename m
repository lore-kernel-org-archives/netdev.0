From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH 1/1] drivers: net: cpsw: dual_emac: fix reducing of
 rx descriptor during ifdown
Date: Tue, 02 Sep 2014 11:54:34 -0700 (PDT)
Message-ID: <20140902.115434.1276391011837651390.davem@davemloft.net>
References: <1409304145-26179-1-git-send-email-mugunthanvnm@ti.com>
	<20140901.183108.784916699845611422.davem@davemloft.net>
	<54058C01.3010402@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mugunthanvnm@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57401 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751850AbaIBSyf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 14:54:35 -0400
In-Reply-To: <54058C01.3010402@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mugunthan V N <mugunthanvnm@ti.com>
Date: Tue, 2 Sep 2014 14:51:05 +0530

> When ifup and ifdown is run continuously, for each spilled packet (for
> interface which is down) from DMA, the total number of rx descriptor
> goes down and at one instance all the descriptor is lost and both the
> interface stops working.
> 
> To recover from this we need to put down both the interface and open the
> interface which will re-init the DMA which intern queues fresh set of
> skbs for rx.

But you still should not receive packets for a netdev which is down.
As far as I can tell, you're feeding it into the stack still.

Also this doesn't explain why the "status < 0" case applies to this
new logic, you have not explained that at all.
