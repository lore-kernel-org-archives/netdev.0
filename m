From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net] bpf: do not disable/enable BH in bpf_map_free_id()
Date: Tue, 19 Sep 2017 10:36:18 -0700
Message-ID: <20170919173618.atfumkgstgwr4tgx@kafai-mbp>
References: <1505837759.29839.64.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Miller <davem@davemloft.net>,
        Alexei Starovoitov <ast@kernel.org>,
        netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:36278 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750919AbdISRg1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 13:36:27 -0400
Content-Disposition: inline
In-Reply-To: <1505837759.29839.64.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 19, 2017 at 04:15:59PM +0000, Eric Dumazet wrote:
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
Thanks for fixing it.

Acked-by: Martin KaFai Lau <kafai@fb.com>
