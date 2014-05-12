From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3] sfc: fix calling of free_irq with already free
 vector
Date: Mon, 12 May 2014 14:57:18 -0400 (EDT)
Message-ID: <20140512.145718.681289825304031115.davem@davemloft.net>
References: <1399626699-7181-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, zshi@redhat.com, ben@decadent.org.uk,
	linux-net-drivers@solarflare.com, sshah@solarflare.com
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59867 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754860AbaELS5U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2014 14:57:20 -0400
In-Reply-To: <1399626699-7181-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@redhat.com>
Date: Fri,  9 May 2014 11:11:39 +0200

> If the sfc driver is in legacy interrupt mode (either explicitly by
> using interrupt_mode module param or by falling back to it) it will
> hit a warning at kernel/irq/manage.c because it will try to free an irq
> which wasn't allocated by it in the first place because the MSI(X) irqs are
> zero and it'll try to free them unconditionally. So fix it by checking if
> we're in legacy mode and freeing the appropriate irqs.
> 
> CC: Zenghui Shi <zshi@redhat.com>
> CC: Ben Hutchings <ben@decadent.org.uk>
> CC: <linux-net-drivers@solarflare.com>
> CC: Shradha Shah <sshah@solarflare.com>
> CC: David S. Miller <davem@davemloft.net>
> 
> Fixes: 1899c111a535 ("sfc: Fix IRQ cleanup in case of a probe failure")
> Reported-by: Zenghui Shi <zshi@redhat.com>
> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
> ---
> v3: Use the EFX_INT_MODE_USE_MSI macro instead of direct check
> as suggested by Ben
> v2: Change the fix to check for the interrupt mode and adjust the
> commit message.

Applied and queued up for -stable, thanks Nikolay.
