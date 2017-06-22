From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netvsc: don't access netdev->num_rx_queues directly
Date: Thu, 22 Jun 2017 13:28:23 -0400 (EDT)
Message-ID: <20170622.132823.1130047650794574808.davem@davemloft.net>
References: <20170621221714.278724-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sthemmin@microsoft.com, kys@microsoft.com, haiyangz@microsoft.com,
        sixiao@microsoft.com, devel@linuxdriverproject.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170621221714.278724-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Thu, 22 Jun 2017 00:16:37 +0200

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

Applied and queued up for -stable, thank you.
