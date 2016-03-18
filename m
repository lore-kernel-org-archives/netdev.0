From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: mvneta: bm: clarify dependencies
Date: Fri, 18 Mar 2016 19:37:03 -0400 (EDT)
Message-ID: <20160318.193703.1746980343115277326.davem@davemloft.net>
References: <1458078449-635940-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gregory.clement@free-electrons.com,
	mw@semihalf.com, linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56635 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753171AbcCRXhF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2016 19:37:05 -0400
In-Reply-To: <1458078449-635940-1-git-send-email-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 15 Mar 2016 22:47:14 +0100

> MVNETA_BM has a dependency on MVNETA, so we can only select the former
> if the latter is enabled. However, the code dependency is the reverse:
> The mvneta module can call into the mvneta_bm module, so mvneta cannot
> be a built-in if mvneta_bm is a module, or we get a link error:
> 
> drivers/net/built-in.o: In function `mvneta_remove':
> drivers/net/ethernet/marvell/mvneta.c:4211: undefined reference to `mvneta_bm_pool_destroy'
> drivers/net/built-in.o: In function `mvneta_bm_update_mtu':
> drivers/net/ethernet/marvell/mvneta.c:1034: undefined reference to `mvneta_bm_bufs_free'
> 
> This avoids the problem by further clarifying the dependency so that
> MVNETA_BM is a silent Kconfig option that gets turned on by the
> new MVNETA_BM_ENABLE option. This way both the core HWBM module and
> the MVNETA_BM code are always built-in when needed.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: dc35a10f68d3 ("net: mvneta: bm: add support for hardware buffer management")

Applied.
