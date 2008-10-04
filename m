From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: key: Free dumping state on socket close
Date: Sat, 04 Oct 2008 22:17:23 +0800
Message-ID: <E1Km7wh-00029a-VU@gondolin.me.apana.org.au>
References: <48DC7C68.1060507@iki.fi>
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: timo.teras@iki.fi (Timo Ter??s)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:51215 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752857AbYJDORa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Oct 2008 10:17:30 -0400
In-Reply-To: <48DC7C68.1060507@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Timo Ter??s <timo.teras@iki.fi> wrote:
> Fix a xfrm_{state,policy}_walk leak if pfkey socket is closed while
> dumping is on-going.
> 
> Signed-off-by: Timo Teras <timo.teras@iki.fi>
> ---
> Checked netlink code and the dumper clean up is done in there in
> netlink_sock_destruct.
> 
> I'll update the "put dumpers on dump list" patch by making the
> state release a function since there's the skb to free too.
> 
> net/key/af_key.c |    8 ++++++++
> 1 files changed, 8 insertions(+), 0 deletions(-)
> 
> diff --git a/net/key/af_key.c b/net/key/af_key.c
> index d628df9..97007de 100644
> --- a/net/key/af_key.c
> +++ b/net/key/af_key.c
> @@ -89,6 +89,14 @@ static int pfkey_do_dump(struct pfkey_sock *pfk)
> 
> static void pfkey_sock_destruct(struct sock *sk)
> {
> +       struct pfkey_sock *pfk = pfkey_sk(sk);
> +
> +       if (pfk->dump.dump) {
> +               pfk->dump.done(pfk);
> +               pfk->dump.dump = NULL;
> +               pfk->dump.done = NULL;
> +       }
> +
>        skb_queue_purge(&sk->sk_receive_queue);
> 
>        if (!sock_flag(sk, SOCK_DEAD)) {

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
