From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] tcp: use an RB tree for ooo receive queue
Date: Wed, 7 Sep 2016 15:26:37 -0700
Message-ID: <20160907152637.7df3f9d9@xeon-e3>
References: <1473284968.15733.8.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Yaogong Wang <wygivan@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Neal Cardwell <ncardwell@google.com>,
        Ilpo =?UTF-8?B?SsOkcnZpbmVu?= <ilpo.jarvinen@helsinki.fi>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:32896 "EHLO
        mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750992AbcIGW02 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 18:26:28 -0400
Received: by mail-pa0-f43.google.com with SMTP id cm16so10332804pac.0
        for <netdev@vger.kernel.org>; Wed, 07 Sep 2016 15:26:28 -0700 (PDT)
In-Reply-To: <1473284968.15733.8.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 07 Sep 2016 14:49:28 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> From: Yaogong Wang <wygivan@google.com>
>=20
> Over the years, TCP BDP has increased by several orders of magnitude,
> and some people are considering to reach the 2 Gbytes limit.
>=20
> Even with current window scale limit of 14, ~1 Gbytes maps to ~740,000
> MSS.
>    =20
> In presence of packet losses (or reorders), TCP stores incoming packets
> into an out of order queue, and number of skbs sitting there waiting for
> the missing packets to be received can be in the 10^5 range.
>=20
> Most packets are appended to the tail of this queue, and when
> packets can finally be transferred to receive queue, we scan the queue
> from its head.
>=20
> However, in presence of heavy losses, we might have to find an arbitrary
> point in this queue, involving a linear scan for every incoming packet,
> throwing away cpu caches.
>=20
> This patch converts it to a RB tree, to get bounded latencies.
>=20
> Yaogong wrote a preliminary patch about 2 years ago.
> Eric did the rebase, added ofo_last_skb cache, polishing and tests.
>=20
> Tested with network dropping between 1 and 10 % packets, with good
> success (about 30 % increase of throughput in stress tests)
>=20
> Next step would be to also use an RB tree for the write queue at sender
> side ;)
>=20
> Signed-off-by: Yaogong Wang <wygivan@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> Cc: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>

How much does this grow the size of tcp socket structure?
