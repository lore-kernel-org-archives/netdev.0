From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: xgene: fix maybe-uninitialized variable
Date: Wed, 03 Aug 2016 11:52:32 -0700 (PDT)
Message-ID: <20160803.115232.837383021887790928.davem@davemloft.net>
References: <20160802102348.81986-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isubramanian@apm.com, kchudgar@apm.com, tinamdar@apm.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160802102348.81986-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Tue,  2 Aug 2016 12:23:29 +0200

> Building with -Wmaybe-uninitialized shows a potential use of
> an uninitialized variable:
> 
> drivers/net/ethernet/apm/xgene/xgene_enet_hw.c: In function 'xgene_enet_phy_connect':
> drivers/net/ethernet/apm/xgene/xgene_enet_hw.c:802:23: warning: 'phy_dev' may be used uninitialized in this function [-Wmaybe-uninitialized]
> 
> Although the compiler correctly identified this based on the function,
> the current code is still safe as long dev->of_node is non-NULL
> for the case of CONFIG_ACPI=n, which is currently the case.
> 
> The warning is now disabled by default, but still appears when
> building with W=1, and other build test tools should be able to
> detect it as well. Adding an #else clause here makes the code
> more robust and makes it clear to the compiler that this cannot
> happen.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: 8089a96f601b ("drivers: net: xgene: Add backward compatibility")

Applied.
