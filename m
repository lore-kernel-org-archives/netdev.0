From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bpf: do not disable/enable BH in bpf_map_free_id()
Date: Tue, 19 Sep 2017 15:43:34 -0700 (PDT)
Message-ID: <20170919.154334.1938133697292090820.davem@davemloft.net>
References: <1505837759.29839.64.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kafai@fb.com, ast@kernel.org, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49108 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751581AbdISWnf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 18:43:35 -0400
In-Reply-To: <1505837759.29839.64.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 19 Sep 2017 09:15:59 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> syzkaller reported following splat [1]
> 
> Since hard irq are disabled by the caller, bpf_map_free_id()
> should not try to enable/disable BH.
> 
> Another solution would be to change htab_map_delete_elem() to
> defer the free_htab_elem() call after
> raw_spin_unlock_irqrestore(&b->lock, flags), but this might be not
> enough to cover other code paths.
> 
> [1]
 ...
> Fixes: f3f1c054c288 ("bpf: Introduce bpf_map ID")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Martin KaFai Lau <kafai@fb.com>

Applied and queued up for -stable, thanks Eric.
