From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] tcp: take care of truncations done by
 sk_filter()
Date: Sun, 13 Nov 2016 12:30:27 -0500 (EST)
Message-ID: <20161113.123027.772928399734865701.davem@davemloft.net>
References: <1478808780.8455.23.camel@edumazet-glaptop3.roam.corp.google.com>
        <1478811016.8455.33.camel@edumazet-glaptop3.roam.corp.google.com>
        <1478812355.8455.39.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vdronov@redhat.com, netdev@vger.kernel.org, marco.gra@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44230 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753258AbcKMRa3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 13 Nov 2016 12:30:29 -0500
In-Reply-To: <1478812355.8455.39.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 10 Nov 2016 13:12:35 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> With syzkaller help, Marco Grassi found a bug in TCP stack,
> crashing in tcp_collapse()
> 
> Root cause is that sk_filter() can truncate the incoming skb,
> but TCP stack was not really expecting this to happen.
> It probably was expecting a simple DROP or ACCEPT behavior.
> 
> We first need to make sure no part of TCP header could be removed.
> Then we need to adjust TCP_SKB_CB(skb)->end_seq
> 
> Many thanks to syzkaller team and Marco for giving us a reproducer.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Marco Grassi <marco.gra@gmail.com>
> Reported-by: Vladis Dronov <vdronov@redhat.com>
> ---
> v2: reload both th/iph in case skb->head changed.

Applied and queued up for -stable, thanks Eric.
