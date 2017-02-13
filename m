From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH v3 net-next 08/14] mlx4: use order-0 pages for RX
Date: Mon, 13 Feb 2017 15:29:18 -0800
Message-ID: <CANn89iLgUsPDL0wbuHk5RaehzJ+TRLQ=WkVBMTB65scrEjO3Ug@mail.gmail.com>
References: <20170213195858.5215-1-edumazet@google.com> <20170213195858.5215-9-edumazet@google.com>
 <CAKgT0Ufx0Y=9kjLax36Gx4e7Y-A7sKZDNYxgJ9wbCT4_vxHhGA@mail.gmail.com>
 <CANn89iLkPB_Dx1L2dFfwOoeXOmPhu_C3OO2yqZi8+Rvjr=-EtA@mail.gmail.com>
 <CAKgT0UeB_e_Z7LM1_r=en8JJdgLhoYFstWpCDQN6iawLYZJKDA@mail.gmail.com>
 <CANn89iJfLu8ai1SDGDt5aowAGibdxumDA89Y44f6SjTTt+sGBg@mail.gmail.com> <CAKgT0UdgnKzJ8PJFPfvJiOSZQ3E3Sw5nWjyrROuERv0=-dxmxQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Martin KaFai Lau <kafai@fb.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Willem de Bruijn <willemb@google.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f43.google.com ([209.85.214.43]:37522 "EHLO
        mail-it0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751079AbdBMX3U (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2017 18:29:20 -0500
Received: by mail-it0-f43.google.com with SMTP id x75so8644920itb.0
        for <netdev@vger.kernel.org>; Mon, 13 Feb 2017 15:29:19 -0800 (PST)
In-Reply-To: <CAKgT0UdgnKzJ8PJFPfvJiOSZQ3E3Sw5nWjyrROuERv0=-dxmxQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 13, 2017 at 3:26 PM, Alexander Duyck
<alexander.duyck@gmail.com> wrote:

>
> Odds are for a single TCP flow you won't notice.  This tends to be
> more of a small packets type performance issue.  If you hammer on he
> Rx using pktgen you would be more likely to see it.
>
> Anyway patch looks fine from a functional perspective so I am okay
> with it.  The page count bulking is something that can be addressed
> later.

Well, if we hammer enough, pages are not recycled because we cycle
through RX ring buffer too fast.

This might be different for PowerPC though, because of its huge PAGE_SIZE.
