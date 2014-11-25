From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/mlx4_core: Limit count field to 24 bits in
 qp_alloc_res
Date: Tue, 25 Nov 2014 14:16:20 -0500 (EST)
Message-ID: <20141125.141620.1331667846639491375.davem@davemloft.net>
References: <1416909271-28840-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, matanb@mellanox.com, amirv@mellanox.com,
	jackm@dev.mellanox.co.il
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37231 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751382AbaKYTQX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 14:16:23 -0500
In-Reply-To: <1416909271-28840-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Tue, 25 Nov 2014 11:54:31 +0200

>  	case RES_OP_RESERVE:
> -		count = get_param_l(&in_param);
> +		count = get_param_l(&in_param) & 0xffffff;

I think if these high bits are set, you should be using the maximum
value rather then truncating.
