From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: fix numa_node validation
Date: Tue, 05 Sep 2017 09:10:27 -0700 (PDT)
Message-ID: <20170905.091027.204977527174006202.davem@davemloft.net>
References: <1504590062.15310.36.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kafai@fb.com, daniel@iogearbox.net,
        ast@fb.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34284 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750858AbdIEQKb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2017 12:10:31 -0400
In-Reply-To: <1504590062.15310.36.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 04 Sep 2017 22:41:02 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> syzkaller reported crashes in bpf map creation or map update [1]
> 
> Problem is that nr_node_ids is a signed integer,
> NUMA_NO_NODE is also an integer, so it is very tempting
> to declare numa_node as a signed integer.
> 
> This means the typical test to validate a user provided value :
> 
>         if (numa_node != NUMA_NO_NODE &&
>             (numa_node >= nr_node_ids ||
>              !node_online(numa_node)))
> 
> must be written :
> 
>         if (numa_node != NUMA_NO_NODE &&
>             ((unsigned int)numa_node >= nr_node_ids ||
>              !node_online(numa_node)))
> 
> 
> [1]
 ...
> Fixes: 96eabe7a40aa ("bpf: Allow selecting numa node during map creation")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
