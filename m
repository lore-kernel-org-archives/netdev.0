From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [net-next PATCH 0/4] net: frag patchset for fixing LRU scalability issue
Date: Wed, 24 Apr 2013 19:27:03 +0200
Message-ID: <20130424172703.GA11974@order.stressinduktion.org>
References: <20130424154624.16883.40974.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:33045 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755559Ab3DXR1F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Apr 2013 13:27:05 -0400
Content-Disposition: inline
In-Reply-To: <20130424154624.16883.40974.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 24, 2013 at 05:47:55PM +0200, Jesper Dangaard Brouer wrote:
> This patchset replaces my prevous patchset:
>   "net: frag code fixes and RFC for LRU removal"
>   http://thread.gmane.org/gmane.linux.network/266323/
> 
> I have dropped the idea of doing "direct hash cleaning".  Instead I
> have simply choosen to solve the global LRU list problem, by making
> the LRU list be per CPU.
> 
> 
> Patch-01: Revert "inet: limit length of fragment queue hash table bucket lists"
> - Sorry this patch is broken and need to be reverted.
>   I'll leave it up to Hannes for come up with a better solution,
>   perhaps better IPv6 hashing for frag queues.

In general I am fine with this approach. I will have a look if we can
mitigate the IPv6 hash collisions without reverting 279e9f2 ("ipv6:
optimize inet6_hash_frag()") ontop of this patchset. I will send a patch
if these changes land in net-next.

> Patch-02: net: increase frag hash size
> - Simply increase the hash size
> 
> Patch-03: net: avoid false perf interpretations in frag code
> - The compiler make us misinterpret performance issues in the frag
>   code, because its auto inlining functions.  This cause too many
>   arguments between developers on the list.
> 
> Patch-04: net: frag LRU list per CPU
> - Change the global LRU list to be per CPU instead.

I will review the other patches later today. Btw. do we have to deal
with online cpu-addition/removal here?

Thanks,

  Hannes
