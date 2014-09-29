From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v2 net-next] mlx4: optimize xmit path
Date: Mon, 29 Sep 2014 10:46:00 -0700
Message-ID: <CAMEtUuw0UjJuDqSDrK9L-CUWaVdKni1p9cib+VGCOYtBbrCY4Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <or.gerlitz@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:59205 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754041AbaI2RqC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 13:46:02 -0400
Received: by mail-wi0-f180.google.com with SMTP id em10so1647518wid.1
        for <netdev@vger.kernel.org>; Mon, 29 Sep 2014 10:46:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 28, 2014 at 9:19 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>         send_doorbell = !skb->xmit_more || netif_xmit_stopped(ring->tx_queue);
>
>         if (ring->bf_enabled && desc_size <= MAX_BF && !bounce &&
>             !vlan_tx_tag_present(skb) && send_doorbell) {

This patch is good,

but I've been thinking more about bf+xmit_more and want
to double check my understanding in that scenario:
xmit_more=true will queue descriptors normally and
the last xmit_more=false packet will write into BF.
I guess BF suppose to pick up the earlier ones from
the queue, otherwise the whole thing is broken.
So if indeed BF can pick up the whole chain, then
it should be the faster way than doing iowrite32(), right?
