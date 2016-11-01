From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Why does tcp collapse behavior depend on nr_frags?
Date: Tue, 01 Nov 2016 06:33:09 -0700
Message-ID: <1478007189.7065.331.camel@edumazet-glaptop3.roam.corp.google.com>
References: <VI1PR0502MB29577BA8C670D1379CC4F1B7D4A10@VI1PR0502MB2957.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        tls-fpga-sw-dev <tls-fpga-sw-dev@mellanox.com>,
        Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
To: Ilya Lesokhin <ilyal@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:35035 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1424280AbcKANdL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 09:33:11 -0400
Received: by mail-pf0-f179.google.com with SMTP id i88so2092309pfk.2
        for <netdev@vger.kernel.org>; Tue, 01 Nov 2016 06:33:11 -0700 (PDT)
In-Reply-To: <VI1PR0502MB29577BA8C670D1379CC4F1B7D4A10@VI1PR0502MB2957.eurprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-11-01 at 08:15 +0000, Ilya Lesokhin wrote:
> Hi,
> I've notice that tcp_can_collapse() returns false if skb_shinfo(skb)->nr_frags != 0.
> Is there a reason why we want to base the collapse decision in retransmission on whether
> the data is located in a frag or the linear part?
> 
> The relevant commit is
> 	 tcp: collapse more than two on retransmission  ('4a17fc3add594fcc1c778e93a95b6ecf47f630e5')
> 
> Thanks,
> Ilya

Good point.

I am guessing you see this after commit
3613b3dbd1ade9a6a626dae1f608c57638eb5e8a
("tcp: prepare skbs for better sack shifting")  ?

Problem is that the left skb might have no skb_availroom() anyway...

We could theoretically use the same helpers we use at sack shifting,
but are these collapse events frequent enough we should care ?

Thanks !
