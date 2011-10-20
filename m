From: Jon Mason <mason@myri.com>
Subject: Re: [PATCH net-next] myri10ge: fix truesize underestimation
Date: Thu, 20 Oct 2011 15:33:58 -0500
Message-ID: <CAMaF-rN8K3hDiwwqh_eGQ0nrxskn+7r9Rn_yDJ46aesKR77nbg@mail.gmail.com>
References: <1319141403.2854.17.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Andrew Gallatin <gallatin@myri.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:33264 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752249Ab1JTUd7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2011 16:33:59 -0400
Received: by vcge1 with SMTP id e1so2813302vcg.19
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2011 13:33:58 -0700 (PDT)
In-Reply-To: <1319141403.2854.17.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 20, 2011 at 3:10 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> skb->truesize must account for allocated memory, not the used part of
> it. Doing this work is important to avoid unexpected OOM situations.
>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Acked-by: Jon Mason <mason@myri.com>

> CC: Jon Mason <mason@myri.com>
> ---
> =A0drivers/net/ethernet/myricom/myri10ge/myri10ge.c | =A0 =A03 ++-
> =A01 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c b/drive=
rs/net/ethernet/myricom/myri10ge/myri10ge.c
> index c970a48..0778edc 100644
> --- a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
> +++ b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
> @@ -1210,7 +1210,6 @@ myri10ge_rx_skb_build(struct sk_buff *skb, u8 *=
 va,
> =A0 =A0 =A0 =A0struct skb_frag_struct *skb_frags;
>
> =A0 =A0 =A0 =A0skb->len =3D skb->data_len =3D len;
> - =A0 =A0 =A0 skb->truesize =3D len + sizeof(struct sk_buff);
> =A0 =A0 =A0 =A0/* attach the page(s) */
>
> =A0 =A0 =A0 =A0skb_frags =3D skb_shinfo(skb)->frags;
> @@ -1385,6 +1384,8 @@ myri10ge_rx_done(struct myri10ge_slice_state *s=
s, int len, __wsum csum,
> =A0 =A0 =A0 =A0if (skb_frag_size(&skb_shinfo(skb)->frags[0]) <=3D 0) =
{
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0skb_frag_unref(skb, 0);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0skb_shinfo(skb)->nr_frags =3D 0;
> + =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb->truesize +=3D bytes * skb_shinfo(s=
kb)->nr_frags;
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0skb->protocol =3D eth_type_trans(skb, dev);
> =A0 =A0 =A0 =A0skb_record_rx_queue(skb, ss - &mgp->ss[0]);
>
>
>
