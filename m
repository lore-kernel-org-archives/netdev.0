From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: sr: fix BUG in HMAC init when preemption is
 enabled
Date: Tue, 10 Jan 2017 21:00:13 -0500 (EST)
Message-ID: <20170110.210013.2057547033044168090.davem@davemloft.net>
References: <1484055562-6414-1-git-send-email-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: david.lebrun@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34378 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751862AbdAKCAR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 21:00:17 -0500
In-Reply-To: <1484055562-6414-1-git-send-email-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Lebrun <david.lebrun@uclouvain.be>
Date: Tue, 10 Jan 2017 14:39:22 +0100

> When CONFIG_PREEMPT=y, CONFIG_IPV6=m and CONFIG_SEG6_HMAC=y,
> seg6_hmac_init() is called during the initialization of the ipv6 module.
> This causes a subsequent call to smp_processor_id() with preemption
> enabled, resulting in the following trace.
 ...
> This patch disable BHs in seg6_hmac_init() and seg6_hmac_exit(). BHs are
> re-enabled for the call to crypto_alloc_shash. Indeed, this function might
> call try_module_get(), which cannot be called in atomic context.
> 
> Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
 ...
> -		char *ring = kzalloc(SEG6_HMAC_RING_SIZE, GFP_KERNEL);
> +		char *ring = kzalloc(SEG6_HMAC_RING_SIZE, GFP_ATOMIC);

I agree with Eric that moving to GFP_ATOMIC in this spots is a major step
backwards, and that fixing the per-cpu access during this initializer
is a much better direction to go.

Thanks.
