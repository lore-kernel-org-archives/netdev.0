From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp_v4_send_reset: binding oif to iif in no sock case
Date: Sat, 04 Feb 2012 22:49:16 +0100
Message-ID: <1328392156.2731.49.camel@edumazet-laptop>
References: <RE: [PATCH] tcp_v4_send_reset: binding oif to iif in no sock case>
	 <1328391897-15241-1-git-send-email-shawn.lu@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, xiaoclu@gmail.com
To: Shawn Lu <shawn.lu@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:65333 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751405Ab2BDVtX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2012 16:49:23 -0500
Received: by werb13 with SMTP id b13so3486136wer.19
        for <netdev@vger.kernel.org>; Sat, 04 Feb 2012 13:49:21 -0800 (PST)
In-Reply-To: <1328391897-15241-1-git-send-email-shawn.lu@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 04 f=C3=A9vrier 2012 =C3=A0 13:44 -0800, Shawn Lu a =C3=A9cri=
t :
> Binding RST packet outgoing interface to incoming interface
> for tcp v4 when there is no socket associate with it.
> This has few benefits:
> 1. tcp_v6_send_reset already did that.
> 2. This helps tcp connect with SO_BINDTODEVICE set. When
> connection is lost, we still able to sending out RST using
> same interface.
> 3. we are sending reply, it is most likely to be succeed
> if iif is used
>=20
> Signed-off-by: Shawn Lu <shawn.lu@ericsson.com>
> ---
> V3: reformat comments as suggested
>  net/ipv4/tcp_ipv4.c |    5 +++++
>  1 files changed, 5 insertions(+), 0 deletions(-)
>=20
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index 90e4793..4d6f81c 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -676,6 +676,11 @@ static void tcp_v4_send_reset(struct sock *sk, s=
truct sk_buff *skb)
>  				      arg.iov[0].iov_len, IPPROTO_TCP, 0);
>  	arg.csumoffset =3D offsetof(struct tcphdr, check) / 2;
>  	arg.flags =3D (sk && inet_sk(sk)->transparent) ? IP_REPLY_ARG_NOSRC=
CHECK : 0;
> +	/* When socket is gone, all binding information is lost.
> +	 * routing might fail in this case. using iif for oif to
> +	 * make sure we can deliver it
> +	 */
> +	arg.bound_dev_if =3D sk ? sk->sk_bound_dev_if : inet_iif(skb);
> =20
>  	net =3D dev_net(skb_dst(skb)->dev);
>  	arg.tos =3D ip_hdr(skb)->tos;

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
