From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2x: add a separate GENEVE Kconfig symbol
Date: Wed, 24 Feb 2016 22:49:20 -0500 (EST)
Message-ID: <20160224.224920.1224016653458748974.davem@davemloft.net>
References: <1456223774-1383513-1-git-send-email-arnd@arndb.de>
	<CO2PR11MB0088CC09F328C0CFE10187BF97A40@CO2PR11MB0088.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, Ariel.Elior@qlogic.com,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Yuval.Mintz@qlogic.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CO2PR11MB0088CC09F328C0CFE10187BF97A40@CO2PR11MB0088.namprd11.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Tue, 23 Feb 2016 18:33:10 +0000

>> When CONFIG_GENEVE is built as a loadable module, and bnx2x is built-in,
>> we get this link error:
> 
>> drivers/net/built-in.o: In function `bnx2x_open':
>> :(.text+0x33322): undefined reference to `geneve_get_rx_port'
>> drivers/net/built-in.o: In function `bnx2x_sp_rtnl_task':
>> :(.text+0x3e632): undefined reference to `geneve_get_rx_port'
> 
>> This avoids the problem by adding a separate Kconfig symbol named
>> CONFIG_BNX2X_GENEVE that is only enabled when the code is
>> reachable from the driver.
> 
>> This is the same trick that BNX2X does for VXLAN support, and
>> is similar to how I40E handles both.
> 
>> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
>> Fixes: 883ce97d25b0 ("bnx2x: Add Geneve inner-RSS support")
> 
> Ouch. Thanks for fixing this one; I tried avoiding this solution
> since I don't think there's any reason to encumber the config
> file with needless options [I.e., what's the gain in the ability to
> disable a single offloaded protocol on a single network driver?],
> but obviously, I botched the job.
> 
> BTW, if you want to handle this exactly like vxlan, you might
> consider using `defined(CONFIG_BNX2X_GENEVE)' instead of
> `IS_ENABLED(CONFIG_BNX2X_GENEVE)'  [It not a tristate].
> But that's truly insignificant.
> 
> Acked-By: Yuval Mintz <Yuval.Mintz@qlogic.com>

Applied, thanks everyone.
