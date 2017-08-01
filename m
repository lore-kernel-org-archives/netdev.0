From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH-net-next] net: add skb_frag_foreach_page and use with
 kmap_atomic
Date: Tue, 01 Aug 2017 16:07:36 -0700 (PDT)
Message-ID: <20170801.160736.94696246128929572.davem@davemloft.net>
References: <20170731121547.23736-1-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, willemb@google.com
To: willemdebruijn.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39702 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750854AbdHAXHh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 19:07:37 -0400
In-Reply-To: <20170731121547.23736-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Date: Mon, 31 Jul 2017 08:15:47 -0400

> From: Willem de Bruijn <willemb@google.com>
> 
> Skb frags may contain compound pages. Various operations map frags
> temporarily using kmap_atomic, but this function works on single
> pages, not whole compound pages. The distinction is only relevant
> for high mem pages that require temporary mappings.
> 
> Introduce a looping mechanism that for compound highmem pages maps
> one page at a time, does not change behavior on other pages.
> Use the loop in the kmap_atomic callers in net/core/skbuff.c.
> 
> Verified by triggering skb_copy_bits with
> 
>     tcpdump -n -c 100 -i ${DEV} -w /dev/null &
>     netperf -t TCP_STREAM -H ${HOST}
> 
>   and by triggering __skb_checksum with
> 
>     ethtool -K ${DEV} tx off
> 
>   repeated the tests with looping on a non-highmem platform
>   (x86_64) by making skb_frag_must_loop always return true.
> 
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Ok, this looks good.

Thanks for following up on this.

Applied.
