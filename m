From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 02/10] net/mlx4_core: Mask out host side
 virtualization features for guests
Date: Tue, 09 Dec 2014 14:40:46 -0500 (EST)
Message-ID: <20141209.144046.110046237866554513.davem@davemloft.net>
References: <1417698835-11050-1-git-send-email-ogerlitz@mellanox.com>
	<1417698835-11050-3-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, matanb@mellanox.com, amirv@mellanox.com,
	talal@mellanox.com, jackm@dev.mellanox.co.il
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37955 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751741AbaLITks (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 14:40:48 -0500
In-Reply-To: <1417698835-11050-3-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Thu,  4 Dec 2014 15:13:47 +0200

> @@ -1053,6 +1053,11 @@ int mlx4_QUERY_DEV_CAP_wrapper(struct mlx4_dev *dev, int slave,
>  	field &= ~0x80;
>  	MLX4_PUT(outbox->buf, field, QUERY_DEV_CAP_FLOW_STEERING_IPOIB_OFFSET);
>  
> +	/* turn off host side virt features (VST, FSM, etc) for guests */
> +	MLX4_GET(field32, outbox->buf, QUERY_DEV_CAP_EXT_2_FLAGS_OFFSET);
> +	field32 &= ~((1 << 26) | (1 << 21) | (1 << 20));
> +	MLX4_PUT(outbox->buf, field32, QUERY_DEV_CAP_EXT_2_FLAGS_OFFSET);
> +

Please use mnenomics instead of magic constants for this, thanks.
