From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: xgene: fix backward compatibility fix
Date: Thu, 01 Sep 2016 10:01:08 -0700 (PDT)
Message-ID: <20160901.100108.1348875318377995073.davem@davemloft.net>
References: <20160829123740.3336010-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isubramanian@apm.com, kchudgar@apm.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160829123740.3336010-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Mon, 29 Aug 2016 14:37:14 +0200

> A bugfix for backward compatibility handling introduced undefined
> behavior for the case that of_parse_phandle() does not return
> a valid entry, as "gcc -Wmaybe-unused" reports:
> 
> drivers/net/ethernet/apm/xgene/xgene_enet_hw.c: In function 'xgene_enet_phy_connect':
> drivers/net/ethernet/apm/xgene/xgene_enet_hw.c:776:6: error: 'phy_dev' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> drivers/net/ethernet/apm/xgene/xgene_enet_hw.c: In function 'xgene_enet_mdio_config':
> drivers/net/ethernet/apm/xgene/xgene_enet_hw.c:776:6: error: 'phy_dev' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> 
> We can work around this by removing the check for zero "np", as
> of_phy_connect() will correctly handle a NULL argument so we fall
> back into the normal error handling case.
> 
> Note that I had previously fixed another bug that resulted in the
> exact same warning, but this is a different problem that was
> introduced after my original fix.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: 03377e381bf4 ("drivers: net: xgene: Fix backward compatibility")

Applied.
