From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gso: Validate assumption of frag_list segementation
Date: Mon, 17 Apr 2017 15:32:59 -0400 (EDT)
Message-ID: <20170417.153259.1519976990479511796.davem@davemloft.net>
References: <20170416080007.15990-1-ilant@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexander.h.duyck@intel.com,
        eric.dumazet@gmail.com, steffen.klassert@secunet.com,
        borisp@mellanox.com, ilyal@mellanox.com
To: ilant@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57384 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753906AbdDQTdB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2017 15:33:01 -0400
In-Reply-To: <20170416080007.15990-1-ilant@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <ilant@mellanox.com>
Date: Sun, 16 Apr 2017 11:00:07 +0300

> From: Ilan Tayari <ilant@mellanox.com>
> 
> Commit 07b26c9454a2 ("gso: Support partial splitting at the frag_list
> pointer") assumes that all SKBs in a frag_list (except maybe the last
> one) contain the same amount of GSO payload.
> 
> This assumption is not always correct, resulting in the following
> warning message in the log:
>     skb_segment: too many frags
> 
> For example, mlx5 driver in Striding RQ mode creates some RX SKBs with
> one frag, and some with 2 frags.
> After GRO, the frag_list SKBs end up having different amounts of payload.
> If this frag_list SKB is then forwarded, the aforementioned assumption
> is violated.
> 
> Validate the assumption, and fall back to software GSO if it not true.
> 
> Fixes: 07b26c9454a2 ("gso: Support partial splitting at the frag_list pointer")
> Signed-off-by: Ilan Tayari <ilant@mellanox.com>
> Signed-off-by: Ilya Lesokhin <ilyal@mellanox.com>
> ---

Your commit message mentions a fixes tag which make this change seem
relevant for 'net', but your patch depends upon things in 'net-next'
and therefore only applies there.

I've added this change to net-next, but I want an explanation of why
this change is not targettting 'net' if it seems to fix a problem
there.

Thanks.
