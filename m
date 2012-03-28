From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH] tcp: remove useless update for flag parameter in tcp_enter_frto_loss()
Date: Tue, 27 Mar 2012 22:27:09 -0700
Message-ID: <CAK6E8=fFfU=53U8KxPRgxPhhaCMv+1R+z0EtVHQd=6S9Gcy5tg@mail.gmail.com>
References: <4F729235.8040706@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Li Yu <raise.sail@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:64503 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750941Ab2C1F1a convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2012 01:27:30 -0400
Received: by obbeh20 with SMTP id eh20so862249obb.19
        for <netdev@vger.kernel.org>; Tue, 27 Mar 2012 22:27:30 -0700 (PDT)
In-Reply-To: <4F729235.8040706@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 27, 2012 at 9:23 PM, Li Yu <raise.sail@gmail.com> wrote:
>
> It seem that we forget remove below two lines after copying code :)
>
> This update never impacts others.
>
> Sorry for last mail with legal notices improperly, I used wrong
> mail.
>
> Signed-off-by Li Yu <bingtian.ly@taobao.com>
>
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index e886e2f..b2f8ada 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -2169,8 +2169,6 @@ static void tcp_enter_frto_loss(struct sock *sk=
,
> int allowed_segments, int flag)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* For some reason thi=
s R-bit might get cleared? */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (TCP_SKB_CB(skb)->s=
acked & TCPCB_SACKED_RETRANS)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tp->re=
trans_out +=3D tcp_skb_pcount(skb);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* ...enter this if bra=
nch just for the first segment */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 flag |=3D FLAG_DATA_ACK=
ED;

The comment explicitly explains why the flag is marked for.


> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} else {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (TCP_SKB_CB(skb)->s=
acked & TCPCB_RETRANS)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tp->un=
do_marker =3D 0;
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
