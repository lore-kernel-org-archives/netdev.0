From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next 7/8] net/mlx5e: XDP TX forwarding support
Date: Tue, 20 Sep 2016 18:27:17 +0200
Message-ID: <20160920182717.2de9541e@redhat.com>
References: <1474293539-2595-1-git-send-email-tariqt@mellanox.com>
        <1474293539-2595-8-git-send-email-tariqt@mellanox.com>
        <20160920102943.24732097@brouer.com>
        <20160920133300.144037fd@redhat.com>
        <96b40925-0e8e-0230-0701-96c11d6921a1@gmail.com>
        <20160920154036.GA98644@ast-mbp.thefacebook.com>
        <CALx6S34YBsmSJr7z2wGsu1VvLkjoqTN+Q8JJ0j-H_DehMJzQ5g@mail.gmail.com>
        <1474387110.23058.24.camel@edumazet-glaptop3.roam.corp.google.com>
        <20160920180609.148874b5@redhat.com>
        <1474388036.23058.26.camel@edumazet-glaptop3.roam.corp.google.com>
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
Received: from mx1.redhat.com ([209.132.183.28]:52186 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754743AbcITQ1X (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Sep 2016 12:27:23 -0400
In-Reply-To: <1474388036.23058.26.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 20 Sep 2016 09:13:56 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Tue, 2016-09-20 at 18:06 +0200, Jesper Dangaard Brouer wrote:
> > On Tue, 20 Sep 2016 08:58:30 -0700
> > Eric Dumazet <eric.dumazet@gmail.com> wrote:  
> 
> > > Same for XDP_TX if/when packet is dropped because output ring is full.  
> > 
> > For the XDP_TX case a counter is already incremented[1] but it is a
> > local ring counter (ring->tx_dropped++).
> > 
> > Do you think we should maintain separate counters for XDP? (to have a
> > more consistent interface across drivers...)  
> 
> No, as long as the admin can learn drops are occurring.

Okay, so recording these drops is important for an admin, agreed.  Now
that we have the chance to define the API, wouldn't is be nice if the
admin across drive drivers knew what counter to look for???

> "perf ... -e skb:kfree_skb ..." or drop monitor wont work,
> unfortunately.

That is actually a good idea... why not add a trace point for these
rare drop cases, which is a hassle to debug for an admin?
Let's actually take advantage of all the nice infrastructure the kernel
provides(?)

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
