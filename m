From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next v2] tcp: provide timestamps for partial writes
Date: Wed, 4 Jan 2017 17:22:26 -0500
Message-ID: <CAF=yD-KD2KVOdbMCVE3D6xwi+D5AC-YTOai521tLMymx8q=OPQ@mail.gmail.com>
References: <20170104161934.26849-1-soheil.kdev@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Network Development <netdev@vger.kernel.org>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Willem de Bruijn <willemb@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Neal Cardwell <ncardwell@google.com>,
        Martin KaFai Lau <kafai@fb.com>
To: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f193.google.com ([209.85.217.193]:33167 "EHLO
        mail-ua0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934222AbdADWYu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 17:24:50 -0500
Received: by mail-ua0-f193.google.com with SMTP id d5so30796543uag.0
        for <netdev@vger.kernel.org>; Wed, 04 Jan 2017 14:23:07 -0800 (PST)
In-Reply-To: <20170104161934.26849-1-soheil.kdev@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 4, 2017 at 11:19 AM, Soheil Hassas Yeganeh
<soheil.kdev@gmail.com> wrote:
> From: Soheil Hassas Yeganeh <soheil@google.com>
>
> For TCP sockets, TX timestamps are only captured when the user data
> is successfully and fully written to the socket. In many cases,
> however, TCP writes can be partial for which no timestamp is
> collected.
>
> Collect timestamps whenever any user data is (fully or partially)
> copied into the socket. Pass tcp_write_queue_tail to tcp_tx_timestamp
> instead of the local skb pointer since it can be set to NULL on
> the error path.
>
> Note that tcp_write_queue_tail can be NULL, even if bytes have been
> copied to the socket. This is because acknowledgements are being
> processed in tcp_sendmsg(), and by the time tcp_tx_timestamp is
> called tcp_write_queue_tail can be NULL. For such cases, this patch
> does not collect any timestamps (i.e., it is best-effort).
>
> This patch is written with suggestions from Willem de Bruijn and
> Eric Dumazet.
>
> Change-log V1 -> V2:
>         - Use sockc.tsflags instead of sk->sk_tsflags.
>         - Use the same code path for normal writes and errors.
>
> Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
> Acked-by: Yuchung Cheng <ycheng@google.com>
> Cc: Willem de Bruijn <willemb@google.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Neal Cardwell <ncardwell@google.com>
> Cc: Martin KaFai Lau <kafai@fb.com>

Acked-by: Willem de Bruijn <willemb@google.com>
