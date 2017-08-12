From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 01/15] i40e/i40evf: fix some minor type mismatches
Date: Sat, 12 Aug 2017 13:01:18 -0700 (PDT)
Message-ID: <20170812.130118.1497247269239499736.davem@davemloft.net>
References: <20170812110848.18264-1-jeffrey.t.kirsher@intel.com>
        <20170812110848.18264-2-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesse.brandeburg@intel.com, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51578 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750948AbdHLUBV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 12 Aug 2017 16:01:21 -0400
In-Reply-To: <20170812110848.18264-2-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sat, 12 Aug 2017 04:08:33 -0700

> @@ -1830,7 +1830,7 @@ static struct sk_buff *i40e_construct_skb(struct i40e_ring *rx_ring,
>  	/* prefetch first cache line of first page */
>  	prefetch(xdp->data);
>  #if L1_CACHE_BYTES < 128
> -	prefetch(xdp->data + L1_CACHE_BYTES);
> +	prefetch((void *)(xdp->data + L1_CACHE_BYTES));
>  #endif

This cast seems unnecessary:

[davem@localhost net]$ cat x.c
extern void foo(const void *x);

void bar(void *x)
{
	foo(x);
}
[davem@localhost net]$ gcc -Wall -O2 -c -o x.o x.c
[davem@localhost net]$
