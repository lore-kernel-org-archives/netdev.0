From: Edward Cree <ecree@solarflare.com>
Subject: Re: [iovisor-dev] README: [PATCH RFC 11/11] net/mlx5e: XDP TX xmit
 more
Date: Tue, 13 Sep 2016 16:20:05 +0100
Message-ID: <d8a477c6-5394-ab33-443f-59d75a58f430@solarflare.com>
References: <1473252152-11379-1-git-send-email-saeedm@mellanox.com>
 <1473252152-11379-12-git-send-email-saeedm@mellanox.com>
 <20160908101147.1b351432@redhat.com>
 <20160909032202.GA62966@ast-mbp.thefacebook.com>
 <CALzJLG_r0pDJgxqqak5=NatT8tF7UP2NkGS1wjeWcS5C=Zvv2A@mail.gmail.com>
 <20160912121530.4b4f0ad7@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        iovisor-dev <iovisor-dev@lists.iovisor.org>,
        "Jamal Hadi Salim" <jhs@mojatatu.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        "Eric Dumazet" <edumazet@google.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Rana Shahout <rana.shahot@gmail.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>,
        Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:33139 "EHLO
        nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1758557AbcIMPUf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2016 11:20:35 -0400
In-Reply-To: <20160912121530.4b4f0ad7@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/09/16 11:15, Jesper Dangaard Brouer wrote:
> I'm reacting so loudly, because this is a mental model switch, that
> need to be applied to the full drivers RX path. Also for normal stack
> delivery of SKBs. As both Edward Cree[1] and I[2] have demonstrated,
> there is between 10%-25% perf gain here.
>
> [1] http://lists.openwall.net/netdev/2016/04/19/89
> [2] http://lists.openwall.net/netdev/2016/01/15/51
BTW, I'd also still rather like to see that happen, I never really
understood the objections people had to those patches when I posted them.  I
still believe that dealing in skb-lists instead of skbs, and thus
'automatically' bulking similar packets, is better than trying to categorise
packets into flows early on based on some set of keys.  The problem with the
latter approach is that there are now two definitions of "similar":
1) the set of fields used to index the flow
2) what will actually cause the stack's behaviour to differ if not using the
cached values.
Quite apart from the possibility of bugs if one changes but not the other,
this forces (1) to be conservative, only considering things "similar" if the
entire stack will.  Whereas with bundling, the stack can keep packets
together until they reach a layer at which they are no longer "similar"
enough.  Thus, for instance, packets with the same IP 3-tuple but different
port numbers can be grouped together for IP layer processing, then split
apart for L4.

-Ed
