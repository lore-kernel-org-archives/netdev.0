From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sfc: fix calling of free_irq with 0 argument
Date: Wed, 07 May 2014 15:39:25 -0400 (EDT)
Message-ID: <20140507.153925.2030838202936450086.davem@davemloft.net>
References: <1399380556-25797-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	sshah@solarflare.com
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51148 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751019AbaEGTj1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 15:39:27 -0400
In-Reply-To: <1399380556-25797-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@redhat.com>
Date: Tue,  6 May 2014 14:49:16 +0200

> If the sfc driver is in legacy interrupt mode (either explicitly by
> using interrupt_mode module param or by falling back to it) it will
> hit a warning at kernel/irq/manage.c because it will try to free irq 0
> in efx_nic_fini_interrupt() since the MSI interrupts were freed always,
> but in legacy irq mode they're == 0. So fix it by checking if we
> actually have an interrupt allocated and only then free it.
> 
> CC: <linux-net-drivers@solarflare.com>
> CC: Shradha Shah <sshah@solarflare.com>
> CC: David S. Miller <davem@davemloft.net>
> 
> Reported-by: Zenghui Shi <zshi@redhat.com>
> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
> ---
> There're other ways to fix this as well, but I chose this one as it follows
> the logic in the code. Also I saw it used in a few places to check if
> there's an IRQ allocated for that channel.

Zero can be a valid interrupt on some systems.

This is a discussion that keeps popping up from time to time, and Linus
usually gets upset when someone adds a "!irq" test somewhere.

Why not just guard the efx_for_each_channel() loop with a top-level
test of whether we are using legacy interrupt mode?  That will avoid
this issue entirely.
