From: David Miller <davem@davemloft.net>
Subject: Re: BUG: use-after-free in netlink_dump
Date: Mon, 16 May 2016 22:05:57 -0400 (EDT)
Message-ID: <20160516.220557.521063173502741385.davem@davemloft.net>
References: <573894B3.8030009@gmail.com>
	<CAM_iQpV90MKyP2X32yatwktO9Yk-CSb32Oaa+VpdU8e_k8m-yQ@mail.gmail.com>
	<20160516092816.GA2331@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, sploving1@gmail.com, chamaken@gmail.com,
	daniel@iogearbox.net, netdev@vger.kernel.org, fuzzyer0@gmail.com,
	pshelar@nicira.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41218 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751576AbcEQCGA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 22:06:00 -0400
In-Reply-To: <20160516092816.GA2331@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 16 May 2016 17:28:16 +0800

> Subject: netlink: Fix dump skb leak/double free
> 
> When we free cb->skb after a dump, we do it after releasing the
> lock.  This means that a new dump could have started in the time
> being and we'll end up freeing their skb instead of ours.
> 
> This patch saves the skb and module before we unlock so we free
> the right memory.
> 
> Fixes: 16b304f3404f ("netlink: Eliminate kmalloc in netlink dump operation.")
> Reported-by: Baozeng Ding <sploving1@gmail.com>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied and queued up for -stable, thanks.
