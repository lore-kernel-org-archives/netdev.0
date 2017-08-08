From: Wei Wang <weiwan@google.com>
Subject: Re: [PATCH net] tcp: fastopen: tcp_connect() must refresh the route
Date: Tue, 8 Aug 2017 10:04:20 -0700
Message-ID: <CAEA6p_C6WHbmTgreXNFkMJdEVP+QdbeBACQzGiYtEDmf+TnOFg@mail.gmail.com>
References: <1502181718.4487.9.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Yuchung Cheng <ycheng@google.com>,
        Dmitry Vyukov <dvyukov@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f169.google.com ([209.85.217.169]:36536 "EHLO
        mail-ua0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752092AbdHHREV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2017 13:04:21 -0400
Received: by mail-ua0-f169.google.com with SMTP id k43so17798807uaf.3
        for <netdev@vger.kernel.org>; Tue, 08 Aug 2017 10:04:21 -0700 (PDT)
In-Reply-To: <1502181718.4487.9.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 8, 2017 at 1:41 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> With new TCP_FASTOPEN_CONNECT socket option, there is a possibility
> to call tcp_connect() while socket sk_dst_cache is either NULL
> or invalid.
>
>  +0 socket(..., SOCK_STREAM, IPPROTO_TCP) = 4
>  +0 fcntl(4, F_SETFL, O_RDWR|O_NONBLOCK) = 0
>  +0 setsockopt(4, SOL_TCP, TCP_FASTOPEN_CONNECT, [1], 4) = 0
>  +0 connect(4, ..., ...) = 0
>
> << sk->sk_dst_cache becomes obsolete, or even set to NULL >>
>
>  +1 sendto(4, ..., 1000, MSG_FASTOPEN, ..., ...) = 1000
>
>
> We need to refresh the route otherwise bad things can happen,
> especially when syzkaller is running on the host :/
>
> Fixes: 19f6d3f3c8422 ("net/tcp-fastopen: Add new API support")
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Wei Wang <weiwan@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> ---

Thanks a lot for the fix, Eric.

Acked-by: Wei Wang <weiwan@google.com>
