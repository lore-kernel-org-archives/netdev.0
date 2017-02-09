From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] [net-next] ARM: orion: fix PHYLIB dependency
Date: Thu, 9 Feb 2017 18:22:11 +0100
Message-ID: <20170209172211.GF29882@lunn.ch>
References: <20170209150834.1158193-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
 Jason Cooper <jason@lakedaemon.net>, netdev@vger.kernel.org,
 Russell King <linux@armlinux.org.uk>, linux-kernel@vger.kernel.org,
 Gregory Clement <gregory.clement@free-electrons.com>,
 "David S . Miller" <davem@davemloft.net>, linux-arm-kernel@lists.infradead.org,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <20170209150834.1158193-1-arnd@arndb.de>
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

On Thu, Feb 09, 2017 at 04:08:11PM +0100, Arnd Bergmann wrote:
> The newly introduced mdiobus_register_board_info() function is only available
> as part of PHYLIB, so we get a link error when we call that from a board while
> phylib is disabled:
> 
> arch/arm/plat-orion/common.o: In function `orion_ge00_switch_init':
> common.c:(.init.text+0x6a4): undefined reference to `mdiobus_register_board_info'
> 
> This adds a workaround that is made up of three parts:
> 
> - in plat-orion, the function for declaring the switch is hidden without
>   PHYLIB.
> - in mach-orion5x, the caller conditionally stubs out the call to
>   the removed function, so we can still build other orion5x boards
>   without PHYLIB
> - For the boards that actually declare the switch, we select PHYLIB
>   explicitly from Kconfig if NETDEVICES is set. Without NETDEVICES,
>   we cannot enable PHYLIB, but we also wouldn't need it.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
