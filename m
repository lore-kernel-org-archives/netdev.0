From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next 7/8] net/mlx5e: XDP TX forwarding support
Date: Tue, 20 Sep 2016 18:06:09 +0200
Message-ID: <20160920180609.148874b5@redhat.com>
References: <1474293539-2595-1-git-send-email-tariqt@mellanox.com>
        <1474293539-2595-8-git-send-email-tariqt@mellanox.com>
        <20160920102943.24732097@brouer.com>
        <20160920133300.144037fd@redhat.com>
        <96b40925-0e8e-0230-0701-96c11d6921a1@gmail.com>
        <20160920154036.GA98644@ast-mbp.thefacebook.com>
        <CALx6S34YBsmSJr7z2wGsu1VvLkjoqTN+Q8JJ0j-H_DehMJzQ5g@mail.gmail.com>
        <1474387110.23058.24.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Tariq Toukan <ttoukan.linux@gmail.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eran Ben Elisha <eranbe@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Rana Shahout <ranas@mellanox.com>, brouer@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48680 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754132AbcITQGP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Sep 2016 12:06:15 -0400
In-Reply-To: <1474387110.23058.24.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 20 Sep 2016 08:58:30 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Tue, 2016-09-20 at 08:51 -0700, Tom Herbert wrote:
> > On Tue, Sep 20, 2016 at 8:40 AM, Alexei Starovoitov
> > <alexei.starovoitov@gmail.com> wrote:  
> > > On Tue, Sep 20, 2016 at 03:53:10PM +0300, Tariq Toukan wrote:  
> > >> >>>+  case XDP_ABORTED:  
> > >> >>It is not clearly defined, but I believe XDP_ABORTED should also result
> > >> >>in a warning (calling bpf_warn_invalid_xdp_action(act)).  
> > >> I'll add this.  
> > >
> > > Certainly NOT.
> > > XDP_ABORTED is an exception case when program does divide by zero.
> > > It should NOT do bpf_warn. It must drop the packet.
> > > We discussed it several months ago.
> > > See mlx4/en_rx.c for canonical implementation.
> > >  
> > It should at least bump a counter so that the user knows that aborts
> > are happening.  

I agree.

> Same for XDP_TX if/when packet is dropped because output ring is full.

For the XDP_TX case a counter is already incremented[1] but it is a
local ring counter (ring->tx_dropped++).

Do you think we should maintain separate counters for XDP? (to have a
more consistent interface across drivers...)


[1] https://github.com/torvalds/linux/blob/master/drivers/net/ethernet/mellanox/mlx4/en_tx.c#L1181

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
