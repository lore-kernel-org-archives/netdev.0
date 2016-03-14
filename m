From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] smc91x: avoid self-comparison warning
Date: Mon, 14 Mar 2016 19:37:16 -0400 (EDT)
Message-ID: <20160314.193716.2139468785282657178.davem@davemloft.net>
References: <1457995535-1398186-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nico@fluxnic.net, robert.jarzmik@free.fr,
	u.kleine-koenig@pengutronix.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50970 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751441AbcCNXhV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 19:37:21 -0400
In-Reply-To: <1457995535-1398186-1-git-send-email-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Mon, 14 Mar 2016 23:45:12 +0100

> The smc91x driver defines a macro that compares its argument to
> itself, apparently to get a true result while using its argument
> to avoid a warning about unused local variables.
> 
> Unfortunately, this triggers a warning with gcc-6, as the comparison
> is obviously useless:
> 
> drivers/net/ethernet/smsc/smc91x.c: In function 'smc_hardware_send_pkt':
> drivers/net/ethernet/smsc/smc91x.c:563:14: error: self-comparison always evaluates to true [-Werror=tautological-compare]
>   if (!smc_special_trylock(&lp->lock, flags)) {
> 
> This replaces the macro with another one that behaves similarly,
> with a cast to (void) to ensure the argument is used, and using
> a literal 'true' as its value.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied, thanks.
