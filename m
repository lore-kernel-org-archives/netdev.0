From: Soheil Hassas Yeganeh <soheil@google.com>
Subject: Re: [PATCH net] inet: Fix missing return value in inet6_hash
Date: Tue, 25 Oct 2016 18:36:37 -0400
Message-ID: <CACSApvbWRQkRwRLFi0Tq8-dMjg28gX4ybm607FgLkU6MFYK0HA@mail.gmail.com>
References: <1477433329-165391-1-git-send-email-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Craig Gallek <kraigatgoog@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f180.google.com ([209.85.213.180]:36786 "EHLO
        mail-yb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753657AbcJYWhT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2016 18:37:19 -0400
Received: by mail-yb0-f180.google.com with SMTP id f133so6402218ybc.3
        for <netdev@vger.kernel.org>; Tue, 25 Oct 2016 15:37:18 -0700 (PDT)
In-Reply-To: <1477433329-165391-1-git-send-email-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 25, 2016 at 6:08 PM, Craig Gallek <kraigatgoog@gmail.com> wrote:
> From: Craig Gallek <kraig@google.com>
>
> As part of a series to implement faster SO_REUSEPORT lookups,
> commit 086c653f5862 ("sock: struct proto hash function may error")
> added return values to protocol hash functions and
> commit 496611d7b5ea ("inet: create IPv6-equivalent inet_hash function")
> implemented a new hash function for IPv6.  However, the latter does
> not respect the former's convention.
>
> This properly propagates the hash errors in the IPv6 case.
>
> Fixes: 496611d7b5ea ("inet: create IPv6-equivalent inet_hash function")
> Reported-by: Soheil Hassas Yeganeh <soheil@google.com>
> Signed-off-by: Craig Gallek <kraig@google.com>
Acked-by: Soheil Hassas Yeganeh <soheil@google.com>

> ---
>  net/ipv6/inet6_hashtables.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
>
> diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
> index 2fd0374a35b1..02761c9fe43e 100644
> --- a/net/ipv6/inet6_hashtables.c
> +++ b/net/ipv6/inet6_hashtables.c
> @@ -264,13 +264,15 @@ EXPORT_SYMBOL_GPL(inet6_hash_connect);
>
>  int inet6_hash(struct sock *sk)
>  {
> +       int err = 0;
> +
>         if (sk->sk_state != TCP_CLOSE) {
>                 local_bh_disable();
> -               __inet_hash(sk, NULL, ipv6_rcv_saddr_equal);
> +               err = __inet_hash(sk, NULL, ipv6_rcv_saddr_equal);
>                 local_bh_enable();
>         }
>
> -       return 0;
> +       return err;
>  }
>  EXPORT_SYMBOL_GPL(inet6_hash);

Thanks for the fix!

> --
> 2.8.0.rc3.226.g39d4020
>
