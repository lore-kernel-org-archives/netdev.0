From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: reorganize sk_buff for faster
 __copy_skb_header()
Date: Sun, 28 Sep 2014 17:37:59 -0400 (EDT)
Message-ID: <20140928.173759.584339934179620924.davem@davemloft.net>
References: <1411659380.16953.29.camel@edumazet-glaptop2.roam.corp.google.com>
	<1411678046.16953.45.camel@edumazet-glaptop2.roam.corp.google.com>
	<1411680004.16953.57.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com,
	john.r.fastabend@intel.com, brouer@redhat.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47735 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753581AbaI1ViC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Sep 2014 17:38:02 -0400
In-Reply-To: <1411680004.16953.57.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 25 Sep 2014 14:20:04 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> With proliferation of bit fields in sk_buff, __copy_skb_header() became
> quite expensive, showing as the most expensive function in a GSO
> workload.
> 
> __copy_skb_header() performance is also critical for non GSO TCP
> operations, as it is used from skb_clone()
> 
> This patch carefully moves all the fields that were not copied in a
> separate zone : cloned, nohdr, fclone, peeked, head_frag, xmit_more
> 
> Then I moved all other fields and all other copied fields in a section
> delimited by headers_start[0]/headers_end[0] section so that we
> can use a single memcpy() call, inlined by compiler using long
> word load/stores.
> 
> I also tried to make all copies in the natural orders of sk_buff,
> to help hardware prefetching.
> 
> I made sure sk_buff size did not change.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks!
