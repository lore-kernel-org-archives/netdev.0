From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/4] flowcache: make flow_cache_hash_size() return
 "unsigned int"
Date: Sun, 19 Mar 2017 16:13:41 -0700
Message-ID: <1489965221.16816.14.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170319222449.GB17015@avx2>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
        davem@davemloft.net, netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33021 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752143AbdCSXNo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 19 Mar 2017 19:13:44 -0400
Received: by mail-pf0-f195.google.com with SMTP id p189so9235949pfp.0
        for <netdev@vger.kernel.org>; Sun, 19 Mar 2017 16:13:43 -0700 (PDT)
In-Reply-To: <20170319222449.GB17015@avx2>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-03-20 at 01:24 +0300, Alexey Dobriyan wrote:
> Hash size can't negative so "unsigned int" is logically correct.


>  	struct flow_cache_percpu *fcp = per_cpu_ptr(fc->percpu, cpu);
> -	size_t sz = sizeof(struct hlist_head) * flow_cache_hash_size(fc);
> +	unsigned int sz = sizeof(struct hlist_head) * flow_cache_hash_size(fc);
>  
>  	if (!fcp->hash_table) {
>  		fcp->hash_table = kzalloc_node(sz, GFP_KERNEL, cpu_to_node(cpu));
>  		if (!fcp->hash_table) {
> -			pr_err("NET: failed to allocate flow cache sz %zu\n", sz);
> +			pr_err("NET: failed to allocate flow cache sz %u\n", sz);


I do not see any improvement here.

What is wrong with size_t exactly ?
