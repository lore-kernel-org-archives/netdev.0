From: Soheil Hassas Yeganeh <soheil@google.com>
Subject: Re: [PATCH net] net: clear sk_err_soft in sk_clone_lock()
Date: Fri, 28 Oct 2016 17:25:58 -0400
Message-ID: <CACSApvboAqh_PgTF7VWQfnm7qbo7f1W2EnMWzWVxzn6ri3wfCg@mail.gmail.com>
References: <1477687224.7065.261.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f170.google.com ([209.85.213.170]:34295 "EHLO
        mail-yb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S941762AbcJ1V0j (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2016 17:26:39 -0400
Received: by mail-yb0-f170.google.com with SMTP id f97so42413331ybi.1
        for <netdev@vger.kernel.org>; Fri, 28 Oct 2016 14:26:39 -0700 (PDT)
In-Reply-To: <1477687224.7065.261.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 28, 2016 at 4:40 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> At accept() time, it is possible the parent has a non zero
> sk_err_soft, leftover from a prior error.
>
> Make sure we do not leave this value in the child, as it
> makes future getsockopt(SO_ERROR) calls quite unreliable.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
Acked-by: Soheil Hassas Yeganeh <soheil@google.com>

> ---
>  net/core/sock.c |    1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/net/core/sock.c b/net/core/sock.c
> index d8e4532e89e7c28737c95c723e5f5b3d184a7805..662ccf1c40ed1b66ee253b063dcbfbd186deccee 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -1543,6 +1543,7 @@ struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority)
>                 RCU_INIT_POINTER(newsk->sk_reuseport_cb, NULL);
>
>                 newsk->sk_err      = 0;
> +               newsk->sk_err_soft = 0;
>                 newsk->sk_priority = 0;
>                 newsk->sk_incoming_cpu = raw_smp_processor_id();
>                 atomic64_set(&newsk->sk_cookie, 0);
>
>

Very nice catch! Thank you, Eric!
