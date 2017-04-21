From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] gso: Validate assumption of frag_list segementation
Date: Fri, 21 Apr 2017 13:30:52 -0400 (EDT)
Message-ID: <20170421.133052.1192709001555652314.davem@davemloft.net>
References: <20170419182607.2342-1-ilant@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexander.h.duyck@intel.com,
        eric.dumazet@gmail.com, steffen.klassert@secunet.com,
        borisp@mellanox.com, ilyal@mellanox.com
To: ilant@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36046 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1423281AbdDUSHh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 14:07:37 -0400
In-Reply-To: <20170419182607.2342-1-ilant@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <ilant@mellanox.com>
Date: Wed, 19 Apr 2017 21:26:07 +0300

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
> Change-Id: Ia03983f4a47b6534dd987d7a2aad96d54d46d212
> Fixes: 07b26c9454a2 ("gso: Support partial splitting at the frag_list pointer")
> Signed-off-by: Ilan Tayari <ilant@mellanox.com>
> Signed-off-by: Ilya Lesokhin <ilyal@mellanox.com>

Applied.
