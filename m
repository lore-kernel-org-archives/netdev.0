From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 7/8] net/mlx5e: XDP TX forwarding support
Date: Tue, 20 Sep 2016 09:13:56 -0700
Message-ID: <1474388036.23058.26.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1474293539-2595-1-git-send-email-tariqt@mellanox.com>
         <1474293539-2595-8-git-send-email-tariqt@mellanox.com>
         <20160920102943.24732097@brouer.com> <20160920133300.144037fd@redhat.com>
         <96b40925-0e8e-0230-0701-96c11d6921a1@gmail.com>
         <20160920154036.GA98644@ast-mbp.thefacebook.com>
         <CALx6S34YBsmSJr7z2wGsu1VvLkjoqTN+Q8JJ0j-H_DehMJzQ5g@mail.gmail.com>
         <1474387110.23058.24.camel@edumazet-glaptop3.roam.corp.google.com>
         <20160920180609.148874b5@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Tariq Toukan <ttoukan.linux@gmail.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eran Ben Elisha <eranbe@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Rana Shahout <ranas@mellanox.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:33267 "EHLO
        mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933100AbcITQN6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 12:13:58 -0400
Received: by mail-pa0-f68.google.com with SMTP id oz2so1109375pac.0
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 09:13:58 -0700 (PDT)
In-Reply-To: <20160920180609.148874b5@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-09-20 at 18:06 +0200, Jesper Dangaard Brouer wrote:
> On Tue, 20 Sep 2016 08:58:30 -0700
> Eric Dumazet <eric.dumazet@gmail.com> wrote:

> > Same for XDP_TX if/when packet is dropped because output ring is full.
> 
> For the XDP_TX case a counter is already incremented[1] but it is a
> local ring counter (ring->tx_dropped++).
> 
> Do you think we should maintain separate counters for XDP? (to have a
> more consistent interface across drivers...)

No, as long as the admin can learn drops are occurring.

"perf ... -e skb:kfree_skb ..." or drop monitor wont work,
unfortunately.
