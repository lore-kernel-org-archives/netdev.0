From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC 0/3] tun zerocopy stats
Date: Mon, 09 Oct 2017 20:52:28 -0700 (PDT)
Message-ID: <20171009.205228.714368596112967819.davem@davemloft.net>
References: <20171006222516.90654-1-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com, jasowang@redhat.com,
        willemb@google.com
To: willemdebruijn.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34488 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755048AbdJJDwa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 23:52:30 -0400
In-Reply-To: <20171006222516.90654-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Date: Fri,  6 Oct 2017 18:25:13 -0400

> From: Willem de Bruijn <willemb@google.com>
> 
> Add zerocopy transfer statistics to the vhost_net/tun zerocopy path.
> 
> I've been using this to verify recent changes to zerocopy tuning [1].
> Sharing more widely, as it may be useful in similar future work.
> 
> Use ethtool stats as interface, as these are defined per device
> driver and can easily be extended.
> 
> Make the zerocopy release callback take an extra hop through the tun
> driver to allow the driver to increment its counters.
> 
> Care must be taken to avoid adding an alloc/free to this hot path.
> Since the caller already must allocate a ubuf_info, make it allocate
> two at a time and grant one to the tun device.
> 
>  1/3: introduce ethtool stats (`ethtool -S $DEV`) for tun devices
>  2/3: add zerocopy tx and tx_err counters
>  3/3: convert vhost_net to pass a pair of ubuf_info to tun
> 
> [1] http://patchwork.ozlabs.org/patch/822613/

This looks mostly fine to me, but I don't know enough about how vhost
and tap interact to tell whether this makes sense to upstream.

What are the runtime costs for these new statistics?
