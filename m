From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [2.6 patch] net/llc/llc_conn.c: fix possible NULL dereference
Date: Sat, 19 May 2007 15:43:37 +1000
Message-ID: <E1HpHj7-0001M4-00@gondolin.me.apana.org.au>
References: <464E8763.3010609@redhat.com>
Cc: linux-kernel@vger.kernel.org, acme@redhat.com,
	netdev@vger.kernel.org
To: eteo@redhat.com (Eugene Teo)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2463 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755525AbXESFnk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 May 2007 01:43:40 -0400
In-Reply-To: <464E8763.3010609@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eugene Teo <eteo@redhat.com> wrote:
>
> diff --git a/net/llc/llc_conn.c b/net/llc/llc_conn.c
> index 3b8cfbe..28a3994 100644
> --- a/net/llc/llc_conn.c
> +++ b/net/llc/llc_conn.c
> @@ -323,7 +323,8 @@ int llc_conn_remove_acked_pdus(struct sock *sk, u8 nr, u16
> *how_many_unacked)
> 
>        if (!q_len)
>                goto out;
> -       skb = skb_peek(&llc->pdu_unack_q);
> +       if (! (skb = skb_peek(&llc->pdu_unack_q)))
> +               goto out;

Actually we just checked that the queue length is non-zero so there
must be a packet there unless someone's just removed it.  If it were
possible for someone else to remove it in parallel, then we've got
bigger problems to worry about :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
