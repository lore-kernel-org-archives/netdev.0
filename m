From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net: hisilicon: Never build on SPARC
Date: Wed, 21 Oct 2015 08:27:48 -0700 (PDT)
Message-ID: <20151021.082748.806093800519617316.davem@davemloft.net>
References: <1445437773-23261-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, arnd@arndb.de
To: linux@roeck-us.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445437773-23261-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Guenter Roeck <linux@roeck-us.net>
Date: Wed, 21 Oct 2015 07:29:33 -0700

> The Hisilicon network driver does not build for Sparc. Enabling
> COMPILE_TEST for it causes Sparc allmodconfig/allyesconfig builds
> to fail with
> 
> drivers/net/ethernet/hisilicon/hns_mdio.c: In function 'hns_mdio_bus_name':
> drivers/net/ethernet/hisilicon/hns_mdio.c:409:3: error:
> 		implicit declaration of function 'of_translate_address'
> 
> Fixes: 876133d3161d ("net: hisilicon: add OF dependency")
> Cc: Arnd Bergmann <arnd@arndb.de>
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>

I wish we would really resolve this properly instead of hacking crap
like this all the time, it's stupid.

SPARC simply never needs to "translate" OF addresses, since all OF
resources are fully translated already at boot time during OF tree
import.

All IRQs are fully resolved as well.

So we could simply make of_translate_address() a NOP.
