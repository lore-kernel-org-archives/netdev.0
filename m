From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH] netvsc: don't access netdev->num_rx_queues directly
Date: Wed, 21 Jun 2017 22:21:57 +0000
Message-ID: <BY2PR21MB0004AB80D408D9184BE6C09BCADA0@BY2PR21MB0004.namprd21.prod.outlook.com>
References: <20170621221714.278724-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 "David S. Miller" <davem@davemloft.net>
To: Arnd Bergmann <arnd@arndb.de>, Stephen Hemminger <sthemmin@microsoft.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20170621221714.278724-1-arnd@arndb.de>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Arnd Bergmann [mailto:arnd@arndb.de]
> Sent: Wednesday, June 21, 2017 6:17 PM
> To: Stephen Hemminger <sthemmin@microsoft.com>
> Cc: Arnd Bergmann <arnd@arndb.de>; KY Srinivasan <kys@microsoft.com>;
> Haiyang Zhang <haiyangz@microsoft.com>; David S. Miller
> <davem@davemloft.net>; Simon Xiao <sixiao@microsoft.com>;
> devel@linuxdriverproject.org; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org
> Subject: [PATCH] netvsc: don't access netdev->num_rx_queues directly
> 
> This structure member is hidden behind CONFIG_SYSFS, and we
> get a build error when that is disabled:
> 
> drivers/net/hyperv/netvsc_drv.c: In function 'netvsc_set_channels':
> drivers/net/hyperv/netvsc_drv.c:754:49: error: 'struct net_device' has
> no member named 'num_rx_queues'; did you mean 'num_tx_queues'?
> drivers/net/hyperv/netvsc_drv.c: In function 'netvsc_set_rxfh':
> drivers/net/hyperv/netvsc_drv.c:1181:25: error: 'struct net_device' has
> no member named 'num_rx_queues'; did you mean 'num_tx_queues'?
> 
> As the value is only set once to the argument of alloc_netdev_mq(),
> we can compare against that constant directly.
> 
> Fixes: ff4a44199012 ("netvsc: allow get/set of RSS indirection table")
> Fixes: 2b01888d1b45 ("netvsc: allow more flexible setting of number of
> channels")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Reviewed-by: Haiyang Zhang <haiyangz@microsoft.com>

Thanks.
