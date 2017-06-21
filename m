From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] netvsc: don't access netdev->num_rx_queues directly
Date: Wed, 21 Jun 2017 16:19:05 -0700
Message-ID: <20170621161905.340c2be2@xeon-e3>
References: <20170621221714.278724-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <sthemmin@microsoft.com>, netdev@vger.kernel.org,
        Haiyang Zhang <haiyangz@microsoft.com>,
        linux-kernel@vger.kernel.org, devel@linuxdriverproject.org,
        "David S. Miller" <davem@davemloft.net>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170621221714.278724-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 22 Jun 2017 00:16:37 +0200
Arnd Bergmann <arnd@arndb.de> wrote:

> This structure member is hidden behind CONFIG_SYSFS, and we
> get a build error when that is disabled:
> 
> drivers/net/hyperv/netvsc_drv.c: In function 'netvsc_set_channels':
> drivers/net/hyperv/netvsc_drv.c:754:49: error: 'struct net_device' has no member named 'num_rx_queues'; did you mean 'num_tx_queues'?
> drivers/net/hyperv/netvsc_drv.c: In function 'netvsc_set_rxfh':
> drivers/net/hyperv/netvsc_drv.c:1181:25: error: 'struct net_device' has no member named 'num_rx_queues'; did you mean 'num_tx_queues'?
> 
> As the value is only set once to the argument of alloc_netdev_mq(),
> we can compare against that constant directly.
> 
> Fixes: ff4a44199012 ("netvsc: allow get/set of RSS indirection table")
> Fixes: 2b01888d1b45 ("netvsc: allow more flexible setting of number of channels")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Yes this makes sense. The checks when changing values with ethtool are to avoid
to large a value > 64.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
