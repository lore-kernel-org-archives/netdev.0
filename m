From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 05/12] net/mlx5e: Poll rx cq before tx cq to
 improve round-trip latency
Date: Sun, 21 Jun 2015 10:21:44 -0700 (PDT)
Message-ID: <20150621.102144.267706734504980452.davem@davemloft.net>
References: <1434554789-13758-1-git-send-email-ogerlitz@mellanox.com>
	<1434554789-13758-6-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com, talal@mellanox.com,
	achiad@mellanox.com, saeedm@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46794 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750997AbbFURJ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jun 2015 13:09:58 -0400
In-Reply-To: <1434554789-13758-6-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Wed, 17 Jun 2015 18:26:22 +0300

> From: Achiad Shochat <achiad@mellanox.com>
> 
> For better round trip latency, handle rx completions before
> tx completions.
> 
> Signed-off-by: Achiad Shochat <achiad@mellanox.com>
> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>

I completely disagree with this change.

TX completions should always be handled first because they free up resources
and therefore increase the likelyhood that RX processing will not fail due
to lack of resources (memory, etc.).
