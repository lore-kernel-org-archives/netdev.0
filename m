From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sock: validate data_len before allocating skb in
 sock_alloc_send_pskb()
Date: Wed, 30 May 2012 03:02:05 -0400 (EDT)
Message-ID: <20120530.030205.1337682162603770949.davem@davemloft.net>
References: <20120530054702.6146.8503.stgit@amd-6168-8-1.englab.nay.redhat.com>
	<1338360383.2760.84.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jasowang@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org,
	mst@redhat.com
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1338360383.2760.84.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 30 May 2012 08:46:23 +0200

> Why doing this test in the while (1) block, it should be done before the
> loop...
> 
> Or even in the caller, note net/unix/af_unix.c does this right.
> 
>         if (len > SKB_MAX_ALLOC)
>                 data_len = min_t(size_t,
>                                  len - SKB_MAX_ALLOC,
>                                  MAX_SKB_FRAGS * PAGE_SIZE);
> 
>         skb = sock_alloc_send_pskb(sk, len - data_len, data_len,
>                                    msg->msg_flags & MSG_DONTWAIT, &err);

My impression is that the callers should be fixed to.  It makes no sense
to penalize the call sites that get this right.

And yes, if we do check it in sock_alloc_send_pskb() it should be done
at function entry, not inside the loop.
