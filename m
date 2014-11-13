From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next] tcp: limit GSO packets to half cwnd
Date: Thu, 13 Nov 2014 13:24:42 -0500
Message-ID: <CADVnQynzuVJLh9GYWDVkVcQhDo9mAtxs9UhTML-HF2EOVEdgLA@mail.gmail.com>
References: <1415900722.17262.22.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Nandita Dukkipati <nanditad@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f42.google.com ([209.85.192.42]:42254 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932648AbaKMSYo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2014 13:24:44 -0500
Received: by mail-qg0-f42.google.com with SMTP id i50so11132961qgf.29
        for <netdev@vger.kernel.org>; Thu, 13 Nov 2014 10:24:43 -0800 (PST)
In-Reply-To: <1415900722.17262.22.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 13, 2014 at 12:45 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> In DC world, GSO packets initially cooked by tcp_sendmsg() are usually
> big, as sk_pacing_rate is high.
>
> When network is congested, cwnd can be smaller than the GSO packets
> found in socket write queue. tcp_write_xmit() splits GSO packets
> using the available cwnd, and we end up sending a single GSO packet,
> consuming all available cwnd.
>
> With GRO aggregation on the receiver, we might handle a single GRO
> packet, sending back a single ACK.
>
> 1) This single ACK might be lost
>    TLP or RTO are forced to attempt a retransmit.
> 2) This ACK releases a full cwnd, sender sends another big GSO packet,
>    in a ping pong mode.
>
> This behavior does not fill the pipes in the best way, because of
> scheduling artifacts.
>
> Make sure we always have at least two GSO packets in flight.
>
> This allows us to safely increase GRO efficiency without risking
> spurious retransmits.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  net/ipv4/tcp_output.c |   12 ++++++++----
>  1 file changed, 8 insertions(+), 4 deletions(-)

Acked-by: Neal Cardwell <ncardwell@google.com>

Thanks, Eric!

neal
