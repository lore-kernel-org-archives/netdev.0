From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net/ipv6/sit.c: return unhandled skb to tunnel4_rcv
Date: Tue, 30 Nov 2010 07:12:44 +0100
Message-ID: <1291097564.2725.15.camel@edumazet-laptop>
References: <20101130053234.GA28609@mcafee.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David McCullough <david_mccullough@mcafee.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:36810 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751730Ab0K3GMu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 01:12:50 -0500
Received: by wwa36 with SMTP id 36so5671986wwa.1
        for <netdev@vger.kernel.org>; Mon, 29 Nov 2010 22:12:49 -0800 (PST)
In-Reply-To: <20101130053234.GA28609@mcafee.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 30 novembre 2010 =C3=A0 15:32 +1000, David McCullough a =C3=A9=
crit :
> Hi all,
>=20
> I found a problem using an IPv6 over IPv4 tunnel.  When CONFIG_IPV6_S=
IT
> was enabled, the packets would be rejected as net/ipv6/sit.c was catc=
hing
> all IPPROTO_IPV6 packets and returning an ICMP port unreachable error=
=2E
>=20
> I think this patch fixes the problem cleanly.  I believe the code in
> net/ipv4/tunnel4.c:tunnel4_rcv takes care of it properly if none of t=
he
> handlers claim the skb.
>=20
> Patch is against 2.6.35,  bit still applies to current.
>=20
> Cheers,
> Davidm
>=20
> Signed-off-by: David McCullough <david_mccullough@mcafee.com>
>=20
> diff -u -r1.1.1.45 sit.c
> --- a/net/ipv6/sit.c	12 Aug 2010 00:16:26 -0000	1.1.1.45
> +++ b/net/ipv6/sit.c	30 Nov 2010 05:01:19 -0000
> @@ -575,8 +575,9 @@
>  		return 0;
>  	}
> =20
> -	icmp_send(skb, ICMP_DEST_UNREACH, ICMP_PORT_UNREACH, 0);
> +	/* no tunnel matched,  let upstream know, ipsec may handle it */
>  	rcu_read_unlock();
> +	return 1;
>  out:
>  	kfree_skb(skb);
>  	return 0;
>=20

Good catch !

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>



