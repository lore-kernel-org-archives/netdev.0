From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] flowcache: make struct
 flow_cache_percpu::hash_rnd_recalc bool
Date: Tue, 21 Mar 2017 19:09:48 -0700 (PDT)
Message-ID: <20170321.190948.1404708055619408272.davem@davemloft.net>
References: <20170319222743.GC17015@avx2>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
        netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60428 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932656AbdCVCJu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 22:09:50 -0400
In-Reply-To: <20170319222743.GC17015@avx2>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Mon, 20 Mar 2017 01:27:43 +0300

> ->hash_rnd_recalc is only used in boolean context.
> 
> Space savings on x86_64 come from the fact that "MOV rm8, imm8" is
> shorter than "MOV rm32, imm32" by at least 3 bytes.
> 
> 	add/remove: 0/0 grow/shrink: 0/3 up/down: 0/-10 (-10)
> 	function                                     old     new   delta
> 	flow_cache_new_hashrnd                       166     163      -3
> 	flow_cache_cpu_up_prep                       171     168      -3
> 	flow_cache_lookup                           1148    1144      -4
> 	Total: Before=170822872, After=170822862, chg -0.00%
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

I agree with Eric Dumazet that we might have atomicity issues in the
future because of this change.

Why don't you drop this and resubmit just the other 3 patches which
seem to be much less controversial?

Thanks.
