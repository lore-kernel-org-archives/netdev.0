From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net 0/5] net: fix races accessing page->_count
Date: Thu, 9 Oct 2014 22:37:34 -0700
Message-ID: <CAL3LdT4B3eN55ALtJFxC0ZxgkopOg+5B5JbpDajXJ=0-QOVfuA@mail.gmail.com>
References: <1412918694-22882-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.h.duyck@redhat.com>,
	Andres Lagar-Cavilla <andreslc@google.com>,
	Greg Thelen <gthelen@google.com>,
	Hugh Dickins <hughd@google.com>,
	David Rientjes <rientjes@google.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:64688 "EHLO
	mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750905AbaJJFhg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 01:37:36 -0400
Received: by mail-oi0-f50.google.com with SMTP id i138so5614922oig.9
        for <netdev@vger.kernel.org>; Thu, 09 Oct 2014 22:37:36 -0700 (PDT)
In-Reply-To: <1412918694-22882-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 9, 2014 at 10:24 PM, Eric Dumazet <edumazet@google.com> wrote:
> This is illegal to use atomic_set(&page->_count, ...) even if we 'own'
> the page. Other entities in the kernel need to use get_page_unless_zero()
> to get a reference to the page before testing page properties, so we could
> loose a refcount increment.
>
> The only case it is valid is when page->_count is 0, we can use this in
> __netdev_alloc_frag()
>
> Note that I never seen crashes caused by these races, the issue was reported
> by Andres Lagar-Cavilla and Hugh Dickins.
>
> Eric Dumazet (5):
>   fm10k: fix race accessing page->_count
>   igb: fix race accessing page->_count
>   igb: fix race accessing page->_count

Looks like the ixgbe patch has the incorrect title, or you patch igb twice. :-)

>   mlx4: fix race accessing page->_count
>   net: fix races in page->_count manipulation
>
>  drivers/net/ethernet/intel/fm10k/fm10k_main.c |  7 +++----
>  drivers/net/ethernet/intel/igb/igb_main.c     |  7 +++----
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |  8 +++-----
>  drivers/net/ethernet/mellanox/mlx4/en_rx.c    |  6 +++---
>  net/core/skbuff.c                             | 25 ++++++++++++++++++-------
>  5 files changed, 30 insertions(+), 23 deletions(-)
>
> --
> 2.1.0.rc2.206.gedb03e5
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Cheers,
Jeff
