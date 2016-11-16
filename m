From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netronome: don't access real_num_rx_queues directly
Date: Wed, 16 Nov 2016 17:06:05 -0500 (EST)
Message-ID: <20161116.170605.1685419597650175744.davem@davemloft.net>
References: <20161116141118.1893244-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jakub.kicinski@netronome.com, rolf.neugebauer@netronome.com,
        oss-drivers@netronome.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161116141118.1893244-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 16 Nov 2016 15:10:49 +0100

> The netdev->real_num_rx_queues setting is only available if CONFIG_SYSFS
> is enabled, so we now get a build failure when that is turned off:
> 
> netronome/nfp/nfp_net_common.c: In function 'nfp_net_ring_swap_enable':
> netronome/nfp/nfp_net_common.c:2489:18: error: 'struct net_device' has no member named 'real_num_rx_queues'; did you mean 'real_num_tx_queues'?
> 
> As far as I can tell, the check here is only used as an optimization that
> we can skip in order to fix the compilation. If sysfs is disabled,
> the following netif_set_real_num_rx_queues() has no effect.
> 
> Fixes: 164d1e9e5d52 ("nfp: add support for ethtool .set_channels")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied, thanks.
