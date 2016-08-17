From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net] tcp: fix use after free in tcp_xmit_retransmit_queue()
Date: Wed, 17 Aug 2016 10:09:16 -0400
Message-ID: <CADVnQykh+sN58E=+yKVOLBkvctMmTSovbOuhSEh=PaN9rmOHsQ@mail.gmail.com>
References: <20160816104551.GA28052@kroah.com> <1471361940.4943.4.camel@edumazet-glaptop3.roam.corp.google.com>
 <1471372748.4943.7.camel@edumazet-glaptop3.roam.corp.google.com> <1471438586.4943.28.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Marco Grassi <marco.gra@gmail.com>,
	Yuchung Cheng <ycheng@google.com>,
	Greg KH <gregkh@linuxfoundation.org>,
	=?UTF-8?Q?Ilpo_J=C3=A4rvinen?= <ilpo.jarvinen@helsinki.fi>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:33879 "EHLO
	mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751539AbcHQOJt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 10:09:49 -0400
Received: by mail-oi0-f51.google.com with SMTP id l203so139408659oib.1
        for <netdev@vger.kernel.org>; Wed, 17 Aug 2016 07:09:48 -0700 (PDT)
In-Reply-To: <1471438586.4943.28.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 17, 2016 at 8:56 AM, Eric Dumazet <eric.dumazet@gmail.com> wrot=
e:
>
> From: Eric Dumazet <edumazet@google.com>
>
> When tcp_sendmsg() allocates a fresh and empty skb, it puts it at the
> tail of the write queue using tcp_add_write_queue_tail()
>
> Then it attempts to copy user data into this fresh skb.
>
> If the copy fails, we undo the work and remove the fresh skb.
>
> Unfortunately, this undo lacks the change done to tp->highest_sack and
> we can leave a dangling pointer (to a freed skb)
>
> Later, tcp_xmit_retransmit_queue() can dereference this pointer and
> access freed memory. For regular kernels where memory is not unmapped,
> this might cause SACK bugs because tcp_highest_sack_seq() is buggy,
> returning garbage instead of tp->snd_nxt, but with various debug
> features like CONFIG_DEBUG_PAGEALLOC, this can crash the kernel.
>
> This bug was found by Marco Grassi thanks to syzkaller.
>
> Fixes: 6859d49475d4 ("[TCP]: Abstract tp->highest_sack accessing & point =
to next skb")
> Reported-by: Marco Grassi <marco.gra@gmail.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
> Cc: Yuchung Cheng <ycheng@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>

Acked-by: Neal Cardwell <ncardwell@google.com>

Thanks, Eric.

neal
