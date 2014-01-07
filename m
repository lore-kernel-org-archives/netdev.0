From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net-next V2 3/3] net: Add GRO support for vxlan traffic
Date: Tue, 7 Jan 2014 21:43:55 +0200
Message-ID: <CAJZOPZ+8bNi+HZ=eyGBwzFDdrkroMVyPzoGERFqcnZPq3rBZ6Q@mail.gmail.com>
References: <1389108594-665-1-git-send-email-ogerlitz@mellanox.com>
	<1389108594-665-4-git-send-email-ogerlitz@mellanox.com>
	<1389112461.26646.29.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Or Gerlitz <ogerlitz@mellanox.com>, Jerry Chu <hkchu@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Yan Burman <yanb@mellanox.com>,
	Shlomo Pongratz <shlomop@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:49567 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752610AbaAGTn4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 14:43:56 -0500
Received: by mail-pd0-f170.google.com with SMTP id g10so774036pdj.29
        for <netdev@vger.kernel.org>; Tue, 07 Jan 2014 11:43:56 -0800 (PST)
In-Reply-To: <1389112461.26646.29.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 7, 2014 at 6:34 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2014-01-07 at 17:29 +0200, Or Gerlitz wrote:
>> Add gro handlers for vxlan using the udp gro infrastructure
>>
>
>
>>  static void vxlan_notify_add_rx_port(struct sock *sk)
>>  {
>> @@ -568,6 +661,8 @@ static void vxlan_notify_add_rx_port(struct sock *sk)
>>                       dev->netdev_ops->ndo_add_vxlan_port(dev, sa_family,
>>                                                           port);
>>       }
>> +     if (sa_family == AF_INET)
>> +             udp_add_offload(&vxlan_offload, port);
>>       rcu_read_unlock();
>>  }
>>
>
> This means two vxlan tunnels can not share same port.
> Is that a valid assertion ?

nope -- the vxlan driver opens a listener udp socket per per listening
port, but N > 1 vxlan tunnels can sit on that port, the driver does
further demuxing based on the vnid carried in the vxlan header, see
the call to vxlan_find_vni() from vxlan_rcv()
