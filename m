From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/mlx5_core: Fix trimming down IRQ number
Date: Sun, 17 Jan 2016 12:08:35 -0500 (EST)
Message-ID: <20160117.120835.1470956284086358406.davem@davemloft.net>
References: <1453022747-1993-1-git-send-email-matanb@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, talal@mellanox.com, majd@mellanox.com,
	ogerlitz@mellanox.com, doront@mellanox.com
To: matanb@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57680 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751233AbcAQRIh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jan 2016 12:08:37 -0500
In-Reply-To: <1453022747-1993-1-git-send-email-matanb@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matan Barak <matanb@mellanox.com>
Date: Sun, 17 Jan 2016 11:25:47 +0200

> From: Doron Tsur <doront@mellanox.com>
> 
> With several ConnectX-4 cards installed on a server, one may receive
> irqn > 255 from the kernel API, which we mistakenly trim to 8bit.
> 
> This causes EQ creation failure with the following stack trace:
> [<ffffffff812a11f4>] dump_stack+0x48/0x64
> [<ffffffff810ace21>] __setup_irq+0x3a1/0x4f0
> [<ffffffff810ad7e0>] request_threaded_irq+0x120/0x180
> [<ffffffffa0923660>] ? mlx5_eq_int+0x450/0x450 [mlx5_core]
> [<ffffffffa0922f64>] mlx5_create_map_eq+0x1e4/0x2b0 [mlx5_core]
> [<ffffffffa091de01>] alloc_comp_eqs+0xb1/0x180 [mlx5_core]
> [<ffffffffa091ea99>] mlx5_dev_init+0x5e9/0x6e0 [mlx5_core]
> [<ffffffffa091ec29>] init_one+0x99/0x1c0 [mlx5_core]
> [<ffffffff812e2afc>] local_pci_probe+0x4c/0xa0
> 
> Fixing it by changing of the irqn type from u8 to unsigned int to
> support values > 255
> 
> Fixes: 61d0e73e0a5a ('net/mlx5_core: Use the the real irqn in eq->irqn')
> Reported-by: Jiri Pirko <jiri@mellanox.com>
> Signed-off-by: Doron Tsur <doront@mellanox.com>
> Signed-off-by: Matan Barak <matanb@mellanox.com>

Applied and queued up for -stable, thanks.
