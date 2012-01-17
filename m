From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] mlx4_en: set number of rx rings used by RSS using
 ethtool
Date: Tue, 17 Jan 2012 12:18:41 -0500 (EST)
Message-ID: <20120117.121841.1486682892503842786.davem@davemloft.net>
References: <4F15A6D0.8040501@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.co.il
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55587 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750817Ab2AQRSs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2012 12:18:48 -0500
In-Reply-To: <4F15A6D0.8040501@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Tue, 17 Jan 2012 18:50:24 +0200

> +	/* RSS table size must be an order of 2 */
> +	if (rss_rings != (1 << order_base_2(rss_rings)))
> +		return -EINVAL;

This is an obscure way to make this kind of test.

The canonical way is:

	if (is_power_of_2(rss_rings))
