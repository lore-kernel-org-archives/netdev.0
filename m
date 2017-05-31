From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] udp: reduce cache pressure
Date: Wed, 31 May 2017 12:47:34 -0400 (EDT)
Message-ID: <20170531.124734.427032219057695744.davem@davemloft.net>
References: <cover.1496070490.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40884 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750898AbdEaQrg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 12:47:36 -0400
In-Reply-To: <cover.1496070490.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Mon, 29 May 2017 17:27:22 +0200

> In the most common use case, many skb fields are not used by recvmsg(), and
> the few ones actually accessed lays on cold cachelines, which leads to several
> cache miss per packet.
> 
> This patch series attempts to reduce such misses with different strategies:
> * caching the interesting fields in the scratched space
> * avoid accessing at all uninteresting fields
> * prefetching
> 
> Tested using the udp_sink program by Jesper[1] as the receiver, an h/w l4 rx
> hash on the ingress nic, so that the number of ingress nic rx queues hit by the
> udp traffic could be controlled via ethtool -L.
> 
> The udp_sink program was bound to the first idle cpu, to get more
> stable numbers.
> 
> On a single numa node receiver:
> 
> nic rx queues           vanilla                 patched kernel      delta
> 1                       1850 kpps               1850 kpps           0%
> 2                       2370 kpps               2700 kpps           13.9%
> 16                      2000 kpps               2220 kpps           11%
> 
> [1] https://github.com/netoptimizer/network-testing/blob/master/src/udp_sink.c

Eric can you give this a quick review when you get a chance?

Thanks.
