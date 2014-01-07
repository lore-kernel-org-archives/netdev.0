From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next V2 3/3] net: Add GRO support for vxlan traffic
Date: Tue, 07 Jan 2014 12:04:02 -0800
Message-ID: <1389125042.26646.56.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1389108594-665-1-git-send-email-ogerlitz@mellanox.com>
	 <1389108594-665-4-git-send-email-ogerlitz@mellanox.com>
	 <1389112461.26646.29.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAJZOPZ+8bNi+HZ=eyGBwzFDdrkroMVyPzoGERFqcnZPq3rBZ6Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <ogerlitz@mellanox.com>, Jerry Chu <hkchu@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Yan Burman <yanb@mellanox.com>,
	Shlomo Pongratz <shlomop@mellanox.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f42.google.com ([209.85.213.42]:33765 "EHLO
	mail-yh0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753379AbaAGUEG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 15:04:06 -0500
Received: by mail-yh0-f42.google.com with SMTP id z6so122198yhz.1
        for <netdev@vger.kernel.org>; Tue, 07 Jan 2014 12:04:05 -0800 (PST)
In-Reply-To: <CAJZOPZ+8bNi+HZ=eyGBwzFDdrkroMVyPzoGERFqcnZPq3rBZ6Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-01-07 at 21:43 +0200, Or Gerlitz wrote:
> On Tue, Jan 7, 2014 at 6:34 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Tue, 2014-01-07 at 17:29 +0200, Or Gerlitz wrote:
> >> Add gro handlers for vxlan using the udp gro infrastructure
> >>
> >
> >
> >>  static void vxlan_notify_add_rx_port(struct sock *sk)
> >>  {
> >> @@ -568,6 +661,8 @@ static void vxlan_notify_add_rx_port(struct sock *sk)
> >>                       dev->netdev_ops->ndo_add_vxlan_port(dev, sa_family,
> >>                                                           port);
> >>       }
> >> +     if (sa_family == AF_INET)
> >> +             udp_add_offload(&vxlan_offload, port);
> >>       rcu_read_unlock();
> >>  }
> >>
> >
> > This means two vxlan tunnels can not share same port.
> > Is that a valid assertion ?
> 
> nope -- the vxlan driver opens a listener udp socket per per listening
> port, but N > 1 vxlan tunnels can sit on that port, the driver does
> further demuxing based on the vnid carried in the vxlan header, see
> the call to vxlan_find_vni() from vxlan_rcv()
> --

So if we use same port, it seems to me udp_del_offload() of the first
dismantled tunnel will remove the offload for the remaining tunnel.

You forgot to implement a refcount somehow.
