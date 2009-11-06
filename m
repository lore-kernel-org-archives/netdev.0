From: Lucian Adrian Grijincu <lgrijincu@ixiacom.com>
Subject: Re: [PATCH net-next-2.6 take2] ipv6: udp: Optimise multicast reception
Date: Fri, 6 Nov 2009 19:19:46 +0200
Message-ID: <200911061919.47100.lgrijincu@ixiacom.com>
References: <200911052033.21964.lgrijincu@ixiacom.com> <4AF4506B.3080905@gmail.com> <4AF45796.8010409@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	opurdila@ixiacom.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:9933 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751780AbZKFRTn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 12:19:43 -0500
In-Reply-To: <4AF45796.8010409@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=CEn data de Vin 06 Noi 2009 19:06:30 Eric Dumazet a scris:
> +       for (i =3D 0; i < count; i++) {
> +               skb1 =3D (i =3D=3D final) ? skb : skb_clone(skb, GFP_=
ATOMIC);
> +
> +               if (skb1) {
> +                       sk =3D stack[i];
> +                       bh_lock_sock(sk);
> +                       if (!sock_owned_by_user(sk))
> +                               udpv6_queue_rcv_skb(sk, skb1);
> +                       else
> +                               sk_add_backlog(sk, skb1);
> +                       bh_unlock_sock(sk);
> +               }
> +       }

Is there any reason to continue this loop if we ever get a NULL skb1?

If once we can't get a GFP_ATOMIC clone, are there merrits to calling=20
skb_clone() like crazy (in a very tight loop) (whilst holding a spin lo=
ck in=20
some cases)?

--=20
Lucian
