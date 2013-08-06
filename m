From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH] tcp: cubic: fix overflow error in bictcp_update()
Date: Tue, 6 Aug 2013 11:12:51 -0400
Message-ID: <CADVnQykEFKDdPBsry_rVHvfufUEo-R0QfW0YkGOkBQVXHoqq0A@mail.gmail.com>
References: <1375747815.4457.59.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Van Jacobson <vanj@google.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f43.google.com ([74.125.83.43]:51006 "EHLO
	mail-ee0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755148Ab3HFPMw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Aug 2013 11:12:52 -0400
Received: by mail-ee0-f43.google.com with SMTP id e52so283837eek.2
        for <netdev@vger.kernel.org>; Tue, 06 Aug 2013 08:12:51 -0700 (PDT)
In-Reply-To: <1375747815.4457.59.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 5, 2013 at 8:10 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> commit 17a6e9f1aa9 ("tcp_cubic: fix clock dependency") added an
> overflow error in bictcp_update() in following code :
>
> /* change the unit from HZ to bictcp_HZ */
> t = ((tcp_time_stamp + msecs_to_jiffies(ca->delay_min>>3) -
>       ca->epoch_start) << BICTCP_HZ) / HZ;
>
> Because msecs_to_jiffies() being unsigned long, compiler does
> implicit type promotion.
>
> We really want to constrain (tcp_time_stamp - ca->epoch_start)
> to a signed 32bit value, or else 't' has unexpected high values.
>
> This bugs triggers an increase of retransmit rates ~24 days after
> boot [1], as the high order bit of tcp_time_stamp flips.
>
> [1] for hosts with HZ=1000
>
> Big thanks to Van Jacobson for spotting this problem.
>
> Diagnosed-by: Van Jacobson <vanj@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> Cc: Stephen Hemminger <stephen@networkplumber.org>

Acked-by: Neal Cardwell <ncardwell@google.com>

Also a nice catch!

neal
