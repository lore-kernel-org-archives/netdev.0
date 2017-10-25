From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH] rxrpc: recvmsg: use BUG_ON instead of if condition
 followed by BUG
Date: Tue, 24 Oct 2017 18:41:00 -0700
Message-ID: <CALx6S34LmkS1kYmYxaNZcUHFc8=f_oxauojG0b-t0zAD1YRKkQ@mail.gmail.com>
References: <20171024162004.GA29376@embeddedor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
To: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:50061 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932084AbdJYBlB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 21:41:01 -0400
Received: by mail-qt0-f194.google.com with SMTP id k31so32935932qta.6
        for <netdev@vger.kernel.org>; Tue, 24 Oct 2017 18:41:01 -0700 (PDT)
In-Reply-To: <20171024162004.GA29376@embeddedor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please combine these related patches fixing BUG in rxrpc into a patch
set with proper annotation,

Also, can any of these BUG_ONs be replaced by WARN_ONs? Warnings are
generally preferable to crashing the system.

Tom


On Tue, Oct 24, 2017 at 9:20 AM, Gustavo A. R. Silva
<garsilva@embeddedor.com> wrote:
> Use BUG_ON instead of if condition followed by BUG.
>
> This issue was detected with the help of Coccinelle.
>
> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
> ---
>  net/rxrpc/recvmsg.c | 6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
>
> diff --git a/net/rxrpc/recvmsg.c b/net/rxrpc/recvmsg.c
> index bdece21..9598b92 100644
> --- a/net/rxrpc/recvmsg.c
> +++ b/net/rxrpc/recvmsg.c
> @@ -243,8 +243,7 @@ static int rxrpc_verify_packet(struct rxrpc_call *call, struct sk_buff *skb,
>          */
>         if ((annotation & RXRPC_RX_ANNO_JUMBO) > 1) {
>                 __be16 tmp;
> -               if (skb_copy_bits(skb, offset - 2, &tmp, 2) < 0)
> -                       BUG();
> +               BUG_ON(skb_copy_bits(skb, offset - 2, &tmp, 2) < 0);
>                 cksum = ntohs(tmp);
>                 seq += (annotation & RXRPC_RX_ANNO_JUMBO) - 1;
>         }
> @@ -503,8 +502,7 @@ int rxrpc_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
>
>         release_sock(&rx->sk);
>
> -       if (test_bit(RXRPC_CALL_RELEASED, &call->flags))
> -               BUG();
> +       BUG_ON(test_bit(RXRPC_CALL_RELEASED, &call->flags));
>
>         if (test_bit(RXRPC_CALL_HAS_USERID, &call->flags)) {
>                 if (flags & MSG_CMSG_COMPAT) {
> --
> 2.7.4
>
