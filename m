From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH v2 net-next 00/14] mlx4: order-0 allocations and page recycling
Date: Thu, 9 Feb 2017 08:44:02 -0800
Message-ID: <CANn89i+sbU7b5CAhRq15Mk021X4afkB5E1ip+FRB4NevOrYJvQ@mail.gmail.com>
References: <20170209135838.16487-1-edumazet@google.com> <3c48eac5-0c4f-f43a-1d76-75399e5fc1b8@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Martin KaFai Lau <kafai@fb.com>,
        Willem de Bruijn <willemb@google.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Tariq Toukan <ttoukan.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f47.google.com ([209.85.214.47]:35700 "EHLO
        mail-it0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752906AbdBIQpA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 11:45:00 -0500
Received: by mail-it0-f47.google.com with SMTP id 203so129473714ith.0
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 08:44:03 -0800 (PST)
In-Reply-To: <3c48eac5-0c4f-f43a-1d76-75399e5fc1b8@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 9, 2017 at 8:41 AM, Tariq Toukan <ttoukan.linux@gmail.com> wrote:
> Hi Eric,
>
> Thanks again for your series.
>
> On 09/02/2017 3:58 PM, Eric Dumazet wrote:
>
> As mentioned half a year ago, we better switch mlx4 driver to order-0
> allocations and page recycling.
>
> This reduces vulnerability surface thanks to better skb->truesize
> tracking and provides better performance in most cases.
>
> v2 provides an ethtool -S new counter (rx_alloc_pages) and
> code factorization, plus Tariq fix.
>
> I see that you made significant changes to the previous series, especially
> patch 14 (RX CQE processing).
> Please notice that our work week has just finished here in Israel.
> I will review the series, especially the new patches (10 to 14), on Sunday.
>
> We need to test this series again in our functional and performance
> regression systems.
> It will be running during the weekend, so we can analyze the results and
> update you on Sunday.
>
> Previous performance results showed a degradation, especially in:
> - TCP single stream at 64KB length.

What RX ring size are you using ? I have not seen this at all.

> - TCP 16 streams at 1KB length.

TCP does not really care, it coalesces all these into TSO skbs, full size...

>
> This was probably because cache was too short, and many page allocations
> were needed.
> In CX4, we saw the same kind of degradation, much clearer and amplified as
> it's 2.5 times faster (100G).
>
> Regards,
> Tariq Toukan
