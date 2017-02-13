From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH v3 net-next 08/14] mlx4: use order-0 pages for RX
Date: Mon, 13 Feb 2017 15:22:59 -0800
Message-ID: <CANn89iJfLu8ai1SDGDt5aowAGibdxumDA89Y44f6SjTTt+sGBg@mail.gmail.com>
References: <20170213195858.5215-1-edumazet@google.com> <20170213195858.5215-9-edumazet@google.com>
 <CAKgT0Ufx0Y=9kjLax36Gx4e7Y-A7sKZDNYxgJ9wbCT4_vxHhGA@mail.gmail.com>
 <CANn89iLkPB_Dx1L2dFfwOoeXOmPhu_C3OO2yqZi8+Rvjr=-EtA@mail.gmail.com> <CAKgT0UeB_e_Z7LM1_r=en8JJdgLhoYFstWpCDQN6iawLYZJKDA@mail.gmail.com>
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
Received: from mail-it0-f49.google.com ([209.85.214.49]:38075 "EHLO
        mail-it0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751079AbdBMXXB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2017 18:23:01 -0500
Received: by mail-it0-f49.google.com with SMTP id c7so8353998itd.1
        for <netdev@vger.kernel.org>; Mon, 13 Feb 2017 15:23:00 -0800 (PST)
In-Reply-To: <CAKgT0UeB_e_Z7LM1_r=en8JJdgLhoYFstWpCDQN6iawLYZJKDA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 13, 2017 at 3:16 PM, Alexander Duyck
<alexander.duyck@gmail.com> wrote:

> Any plans to add the bulk page count updates back at some point?  I
> just got around to adding it for igb in commit bd4171a5d4c2 ("igb:
> update code to better handle incrementing page count").  I should have
> patches for ixgbe, i40e, and i40evf here pretty soon.  That was one of
> the reasons why I implemented __page_frag_cache_drain in the first
> place.  As I'm sure Jesper will probably point out the atomic op for
> get_page/page_ref_inc can be pretty expensive if I recall correctly.

As a matter of fact I did this last week, but could not show any
improvement on one TCP flow,
so decided to not include this in this patch series.

Maybe the issue was more a sender issue, I might revisit this later.
