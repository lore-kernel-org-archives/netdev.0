From: Soheil Hassas Yeganeh <soheil@google.com>
Subject: Re: [PATCH net-next 02/15] tcp: introduce tcp_jiffies32
Date: Wed, 17 May 2017 09:43:09 -0400
Message-ID: <CACSApvYvWvDHmdfzCRmA8pJ87jcW-aPKC98c699Simnr1vwdzw@mail.gmail.com>
References: <20170516210014.31176-1-edumazet@google.com> <20170516210014.31176-3-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S . Miller" <davem@davemloft.net>,
        Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Wei Wang <weiwan@google.com>, netdev <netdev@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:33540 "EHLO
        mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753322AbdEQNoB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 17 May 2017 09:44:01 -0400
Received: by mail-io0-f177.google.com with SMTP id p24so9396035ioi.0
        for <netdev@vger.kernel.org>; Wed, 17 May 2017 06:44:01 -0700 (PDT)
In-Reply-To: <20170516210014.31176-3-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 16, 2017 at 5:00 PM, Eric Dumazet <edumazet@google.com> wrote:
> We abuse tcp_time_stamp for two different cases :
>
> 1) base to generate TCP Timestamp options (RFC 7323)
>
> 2) A 32bit version of jiffies since some TCP fields
>    are 32bit wide to save memory.
>
> Since we want in the future to have 1ms TCP TS clock,
> regardless of HZ value, we want to cleanup things.
>
> tcp_jiffies32 is the truncated jiffies value,
> which will be used only in places where we want a 'host'
> timestamp.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Acked-by: Soheil Hassas Yeganeh <soheil@google.com>

> ---
>  include/net/tcp.h | 13 ++++++++-----
>  1 file changed, 8 insertions(+), 5 deletions(-)
>
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index b4dc93dae98c2d175ccadce150083705d237555e..4b45be5708215bae4551a5430b63ab2777baf447 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -700,11 +700,14 @@ u32 __tcp_select_window(struct sock *sk);
>
>  void tcp_send_window_probe(struct sock *sk);
>
> -/* TCP timestamps are only 32-bits, this causes a slight
> - * complication on 64-bit systems since we store a snapshot
> - * of jiffies in the buffer control blocks below.  We decided
> - * to use only the low 32-bits of jiffies and hide the ugly
> - * casts with the following macro.
> +/* TCP uses 32bit jiffies to save some space.
> + * Note that this is different from tcp_time_stamp, which
> + * historically has been the same until linux-4.13.
> + */
> +#define tcp_jiffies32 ((u32)jiffies)
> +
> +/* Generator for TCP TS option (RFC 7323)
> + * Currently tied to 'jiffies' but will soon be driven by 1 ms clock.
>   */
>  #define tcp_time_stamp         ((__u32)(jiffies))
>
> --
> 2.13.0.303.g4ebf302169-goog
>
