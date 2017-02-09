From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] [net-next] ARM: orion: fix PHYLIB dependency
Date: Thu, 9 Feb 2017 10:14:35 -0800
Message-ID: <d00cef40-ab92-a84f-2e4e-1f7867b5ee76@gmail.com>
References: <20170209150834.1158193-1-arnd@arndb.de>
 <20170209155751.GB29882@lunn.ch> <1967873.WpTcGj2Cy4@wuerfel>
 <20170209172024.GE29882@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jason Cooper <jason@lakedaemon.net>, netdev@vger.kernel.org,
 Russell King <linux@armlinux.org.uk>, linux-kernel@vger.kernel.org,
 Gregory Clement <gregory.clement@free-electrons.com>,
 "David S . Miller" <davem@davemloft.net>, linux-arm-kernel@lists.infradead.org,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>, Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20170209172024.GE29882@lunn.ch>
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

On 02/09/2017 09:20 AM, Andrew Lunn wrote:
>> Adding a 'select' statement to something as broad as NETDEVICES sounds
>> really bad, it has a significant risk of introducing dependency loops
>> and may be confusing if you want to build a multiplatform config without
>> networking support (note that NETDEVICES in turn depends on NET, which
>> can also be disabled).
> 
> O.K, so overall it is not simple. So lets drop my idea.
>  
>> One possibility would be to have a special Kconfig symbol that controls
>> mdiobus_register_board_info() being present and have that symbol
>> force PHYLIB to never be "=m". Then we can either have no networking
>> support and no phylib, turning mdiobus_register_board_info() into a
>> stub, or we have the function built-in and reachable from the board
>> code.
> 
> FYI: Florian is working on splitting MDIO out of PHYLIB. There will be
> two separate symbols, so it will be possible to have MDIO without
> PHYLIB. When this happens, i expect mdiobus_register_board_info() will
> be in the MDIO part, not PHYLIB.

Yes that would be the plan.
-- 
Florian
