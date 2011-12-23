From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] rps: fix insufficient bounds checking in
 store_rps_dev_flow_table_cnt()
Date: Thu, 22 Dec 2011 22:37:38 -0500 (EST)
Message-ID: <20111222.223738.869939610976955478.davem@davemloft.net>
References: <1324493459-19764-1-git-send-email-xi.wang@gmail.com>
	<4EF3BEBA.4040402@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, therbert@google.com, netdev@vger.kernel.org
To: xi.wang@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40308 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752843Ab1LWDhp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Dec 2011 22:37:45 -0500
In-Reply-To: <4EF3BEBA.4040402@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xi Wang <xi.wang@gmail.com>
Date: Thu, 22 Dec 2011 18:35:22 -0500

> Setting a large rps_flow_cnt like (1 << 30) on 32-bit platform will
> cause a kernel oops due to insufficient bounds checking.
> 
> 	if (count > 1<<30) {
> 		/* Enforce a limit to prevent overflow */
> 		return -EINVAL;
> 	}
> 	count = roundup_pow_of_two(count);
> 	table = vmalloc(RPS_DEV_FLOW_TABLE_SIZE(count));
> 
> Note that the macro RPS_DEV_FLOW_TABLE_SIZE(count) is defined as:
> 
> 	... + (count * sizeof(struct rps_dev_flow))
> 
> where sizeof(struct rps_dev_flow) is 8.  (1 << 30) * 8 will overflow
> 32 bits.
> 
> This patch replaces the magic number (1 << 30) with a symbolic bound.
> 
> Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Xi Wang <xi.wang@gmail.com>

Applied.
