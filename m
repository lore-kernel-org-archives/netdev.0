From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net] bnx2x: Fix statistics locking scheme
Date: Mon, 23 Mar 2015 22:39:37 -0400 (EDT)
Message-ID: <20150323.223937.150869082277208564.davem@davemloft.net>
References: <1427100974-17338-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Elior@qlogic.com
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60118 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752386AbbCXCjj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 22:39:39 -0400
In-Reply-To: <1427100974-17338-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Mon, 23 Mar 2015 10:56:14 +0200

> Statistics' state-machine in bnx2x driver must be synced with various driver
> flows, but its current locking scheme manages to be wasteful [using 2 locks +
> additional local variable] and prone to race-conditions at the same time,
> as the state-machine and 'action' are being accessed under different locks.
> 
> In addition, current 'safe exec' isn't in fact safe, since the only guarantee
> it gives is that DMA transactions are over, but ramrods might still be running.
> 
> This patch cleans up said logic, leaving us with a single lock for the entire
> flow and removing the possible races.
> 
> Changes from v2:
> 	- Switched into mutex locking from semaphore locking.
> 	- Release locks on error flows.
> 
> Changes from v1:
> 	Failure to acquire lock fails flow instead of printing a warning and
> 	allowing access to the critical section.
> 
> Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
> Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>

Applied, thanks.
