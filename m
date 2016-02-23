From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: Re: [PATCH] bnx2x: add a separate GENEVE Kconfig symbol
Date: Tue, 23 Feb 2016 18:33:10 +0000
Message-ID: <CO2PR11MB0088CC09F328C0CFE10187BF97A40@CO2PR11MB0088.namprd11.prod.outlook.com>
References: <1456223774-1383513-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>,
 "linux-arm-kernel@lists.infradead.org"
 <linux-arm-kernel@lists.infradead.org>,
 linux-kernel <linux-kernel@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>, Ariel Elior <Ariel.Elior@qlogic.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1456223774-1383513-1-git-send-email-arnd@arndb.de>
Content-Language: en-US
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

> When CONFIG_GENEVE is built as a loadable module, and bnx2x is built-in,
> we get this link error:

> drivers/net/built-in.o: In function `bnx2x_open':
> :(.text+0x33322): undefined reference to `geneve_get_rx_port'
> drivers/net/built-in.o: In function `bnx2x_sp_rtnl_task':
> :(.text+0x3e632): undefined reference to `geneve_get_rx_port'

> This avoids the problem by adding a separate Kconfig symbol named
> CONFIG_BNX2X_GENEVE that is only enabled when the code is
> reachable from the driver.

> This is the same trick that BNX2X does for VXLAN support, and
> is similar to how I40E handles both.

> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: 883ce97d25b0 ("bnx2x: Add Geneve inner-RSS support")

Ouch. Thanks for fixing this one; I tried avoiding this solution
since I don't think there's any reason to encumber the config
file with needless options [I.e., what's the gain in the ability to
disable a single offloaded protocol on a single network driver?],
but obviously, I botched the job.

BTW, if you want to handle this exactly like vxlan, you might
consider using `defined(CONFIG_BNX2X_GENEVE)' instead of
`IS_ENABLED(CONFIG_BNX2X_GENEVE)'  [It not a tristate].
But that's truly insignificant.

Acked-By: Yuval Mintz <Yuval.Mintz@qlogic.com>
