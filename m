From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH v2 net-next 2/2] tcp: reduce out_of_order memory use
Date: Sun, 18 Mar 2012 23:53:08 -0400
Message-ID: <CADVnQymJzY-cGg9z8rWXh3EGL8OfPwaCM5UXR7a05G8TERkCTw@mail.gmail.com>
References: <1332077854.3722.52.camel@edumazet-laptop>
	<CADVnQy=_Adr9xTd=7aUFT6m38YQ8V-V7KQc9c6L4nej-dfvekQ@mail.gmail.com>
	<1332104867.3597.1.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	=?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	"H.K. Jerry Chu" <hkchu@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:52731 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755527Ab2CSDxJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Mar 2012 23:53:09 -0400
Received: by qcqw6 with SMTP id w6so1058977qcq.19
        for <netdev@vger.kernel.org>; Sun, 18 Mar 2012 20:53:09 -0700 (PDT)
In-Reply-To: <1332104867.3597.1.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 18, 2012 at 5:07 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> With increasing receive window sizes, but speed of light not improved
> that much, out of order queue can contain a huge number of skbs, waiting
> to be moved to receive_queue when missing packets can fill the holes.
>
> Some devices happen to use fat skbs (truesize of 4096 + sizeof(struct
> sk_buff)) to store regular (MTU <= 1500) frames. This makes highly
> probable sk_rmem_alloc hits sk_rcvbuf limit, which can be 4Mbytes in
> many cases.
>
> When limit is hit, tcp stack calls tcp_collapse_ofo_queue(), a true
> latency killer and cpu cache blower.
>
> Doing the coalescing attempt each time we add a frame in ofo queue
> permits to keep memory use tight and in many cases avoid the
> tcp_collapse() thing later.
>
> Tested on various wireless setups (b43, ath9k, ...) known to use big skb
> truesize, this patch removed the "packets collapsed in receive queue due
> to low socket buffer" I had before.
>
> This also reduced average memory used by tcp sockets.
>
> With help from Neal Cardwell.
>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
