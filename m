From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/5] net/xgene: fix error handling during reset
Date: Mon, 29 Aug 2016 00:31:05 -0400 (EDT)
Message-ID: <20160829.003105.1844403424202906526.davem@davemloft.net>
References: <20160826152546.604384-1-arnd@arndb.de>
        <20160826152546.604384-6-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, torvalds@linux-foundation.org,
        fchen@apm.com, isubramanian@apm.com, kchudgar@apm.com,
        netdev@vger.kernel.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49446 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750750AbcH2EbH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 00:31:07 -0400
In-Reply-To: <20160826152546.604384-6-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 26 Aug 2016 17:25:46 +0200

> The newly added reset logic uses helper functions for the MMIO that
> may fail. However, when the read operation fails, we end up writing
> back uninitialized data to the register, as gcc warns:
> 
> drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c: In function 'xgene_enet_link_state':
> drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c:213:2: error: 'data' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c:209:6: note: 'data' was declared here
>   u32 data;
> 
> We already print a warning to the console log if that happens,
> the best alternative that I can see is skip the rest of the reset
> sequence if the register value cannot be read: Most likely the
> write would fail as well, and if it succeeded, worse things could
> happen.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: 3eb7cb9dc946 ("drivers: net: xgene: XFI PCS reset when link is down")

Applied.
