From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [net-next] xgene_enet: remove bogus forward
 declarations
Date: Thu, 02 Feb 2017 17:13:23 -0500 (EST)
Message-ID: <20170202.171323.2101313074221520967.davem@davemloft.net>
References: <20170201164639.2474782-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isubramanian@apm.com, kchudgar@apm.com, f.fainelli@gmail.com,
        qnguyen@apm.com, tinamdar@apm.com, stephen@networkplumber.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170201164639.2474782-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Wed,  1 Feb 2017 17:46:02 +0100

> The device match tables for both the xgene_enet driver and its phy driver
> have forward declarations that declare an array without a length, leading
> to a clang warning when they are not followed by an actual defitinition:
> 
> drivers/net/ethernet/apm/xgene/../../../phy/mdio-xgene.h:135:34: warning: tentative array definition assumed to have one element
> drivers/net/ethernet/apm/xgene/xgene_enet_main.c:33:36: warning: tentative array definition assumed to have one element
> 
> The declarations for the mdio driver are even in a header file, so they
> cause duplicate definitions of the tables for each file that includes
> them.
> 
> This removes all four forward declarations and moves the actual
> definitions up a little, so they are in front of their first user. For
> the OF match tables, this means having to remove the #ifdef around them,
> and passing the actual structure into of_match_device(). This has no
> effect on the generated object code though, as the of_match_device
> function has an empty stub that does not evaluate its argument, and
> the symbol gets dropped either way.
> 
> Fixes: 43b3cf6634a4 ("drivers: net: phy: xgene: Add MDIO driver")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
> The bug is old, but relatively harmless, so not needed as a fixup for 4.10

Applied, thanks.
