From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net] xen-netfront: use different locks for Rx and Tx
 stats
Date: Tue, 13 Jan 2015 17:22:39 -0500 (EST)
Message-ID: <20150113.172239.2262191030096000641.davem@davemloft.net>
References: <1421167363-27249-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	konrad.wilk@oracle.com, boris.ostrovsky@oracle.com
To: david.vrabel@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36771 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751122AbbAMWWm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 17:22:42 -0500
In-Reply-To: <1421167363-27249-1-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Vrabel <david.vrabel@citrix.com>
Date: Tue, 13 Jan 2015 16:42:42 +0000

> In netfront the Rx and Tx path are independent and use different
> locks.  The Tx lock is held with hard irqs disabled, but Rx lock is
> held with only BH disabled.  Since both sides use the same stats lock,
> a deadlock may occur.
> 
>   [ INFO: possible irq lock inversion dependency detected ]
>   3.16.2 #16 Not tainted
>   ---------------------------------------------------------
>   swapper/0/0 just changed the state of lock:
>    (&(&queue->tx_lock)->rlock){-.....}, at: [<c03adec8>]
>   xennet_tx_interrupt+0x14/0x34
>   but this lock took another, HARDIRQ-unsafe lock in the past:
>    (&stat->syncp.seq#2){+.-...}
>   and interrupts could create inverse lock ordering between them.
>   other info that might help us debug this:
>    Possible interrupt unsafe locking scenario:
> 
>          CPU0                    CPU1
>          ----                    ----
>     lock(&stat->syncp.seq#2);
>                                  local_irq_disable();
>                                  lock(&(&queue->tx_lock)->rlock);
>                                  lock(&stat->syncp.seq#2);
>     <Interrupt>
>       lock(&(&queue->tx_lock)->rlock);
> 
> Using separate locks for the Rx and Tx stats fixes this deadlock.
> 
> Reported-by: Dmitry Piotrovsky <piotrovskydmitry@gmail.com>
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>

Applied, thanks.
