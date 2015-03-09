From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 2/2] net: bcmgenet: add support for xmit_more
Date: Mon, 9 Mar 2015 15:49:14 -0700
Message-ID: <CAGVrzcba9BEgcxAk3rbAzW137HyEGpoo_wn+8mibAq7yOc=kYA@mail.gmail.com>
References: <1425937937-26955-1-git-send-email-f.fainelli@gmail.com>
 <1425937937-26955-3-git-send-email-f.fainelli@gmail.com> <1425939020.8261.17.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAGVrzcYKYGtGWdUGK8OW_DeWba2OG78t+SObwsQPMARtz_aHvA@mail.gmail.com> <1425940574.8261.21.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Petri Gynther <pgynther@google.com>,
	Jaedon Shin <jaedon.shin@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:42646 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753363AbbCIWtz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 18:49:55 -0400
Received: by iecvy18 with SMTP id vy18so43658680iec.9
        for <netdev@vger.kernel.org>; Mon, 09 Mar 2015 15:49:55 -0700 (PDT)
In-Reply-To: <1425940574.8261.21.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2015-03-09 15:36 GMT-07:00 Eric Dumazet <eric.dumazet@gmail.com>:
> On Mon, 2015-03-09 at 15:13 -0700, Florian Fainelli wrote:
>
>> bcmgenet_xmit() and bcmgenet_tx_reclaim() are the only two functions
>> that can stop a queue, and they are using a spinlock to avoid that.
>
> It does not matter.
>
> If you hit the condition :
>
> if (ring->free_bds <= (MAX_SKB_FRAGS + 1))
>      netif_tx_stop_queue(txq);
>
> Then maybe you filled the ring buffer with skb having xmit_more set, and
> you never did a bcmgenet_tdma_ring_writel()

Right, thanks for pointing that out.

>
> Look at other drivers using xmit_more, because you have to reverse
> things.
>
> The skeleton is :
>
> maybe_stop_tx();
>
> if (netif_xmit_stopped(txring_txq(tx_ring)) || !skb->xmit_more) {
>     mmiiowb();
>     ...
> }
>

Will fix that, thanks
-- 
Florian
