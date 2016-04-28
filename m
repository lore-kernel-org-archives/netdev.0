From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net/mlx5e: avoid stack overflow in
 mlx5e_open_channels
Date: Thu, 28 Apr 2016 16:47:40 -0400 (EDT)
Message-ID: <20160428.164740.1969113968588250026.davem@davemloft.net>
References: <1461685993-1049370-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: saeedm@mellanox.com, matanb@mellanox.com, leonro@mellanox.com,
	achiad@mellanox.com, ogerlitz@mellanox.com, amir@vadai.me,
	tariqt@mellanox.com, netdev@vger.kernel.org,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42092 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753297AbcD1Urn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 16:47:43 -0400
In-Reply-To: <1461685993-1049370-1-git-send-email-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 26 Apr 2016 17:52:33 +0200

> struct mlx5e_channel_param is a large structure that is allocated
> on the stack of mlx5e_open_channels, and with a recent change
> it has grown beyond the warning size for the maximum stack
> that a single function should use:
> 
> mellanox/mlx5/core/en_main.c: In function 'mlx5e_open_channels':
> mellanox/mlx5/core/en_main.c:1325:1: error: the frame size of 1072 bytes is larger than 1024 bytes [-Werror=frame-larger-than=]
> 
> The function is already using dynamic allocation and is not in
> a fast path, so the easiest workaround is to use another kzalloc
> for allocating the channel parameters.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: d3c9bc2743dc ("net/mlx5e: Added ICO SQs")
> ---
> v2: move allocation back into caller, as suggested by Saeed Mahameed

Applied, thanks Arnd.
