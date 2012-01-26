From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] fix ip_gre lockless xmits
Date: Thu, 26 Jan 2012 21:58:11 +0100
Message-ID: <1327611491.4140.12.camel@edumazet-laptop>
References: <1327610075-5833-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:62106 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751971Ab2AZU6P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2012 15:58:15 -0500
Received: by wics10 with SMTP id s10so729382wic.19
        for <netdev@vger.kernel.org>; Thu, 26 Jan 2012 12:58:14 -0800 (PST)
In-Reply-To: <1327610075-5833-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 26 janvier 2012 =C3=A0 15:34 -0500, Willem de Bruijn a =C3=A9c=
rit :
> Tunnel devices set NETIF_F_LLTX to bypass HARD_TX_LOCK.  Sit and
> ipip set this unconditionally in ops->setup, but gre enables it
> conditionally after parameter passing in ops->newlink. This is
> not called during tunnel setup as below, however, so GRE tunnels are
> still taking the lock.
>=20
> modprobe ip_gre
> ip tunnel add test0 mode gre remote 10.5.1.1 dev lo
> ip link set test0 up
> ip addr add 10.6.0.1 dev test0
>  # cat /sys/class/net/test0/features
>  # $DIR/test_tunnel_xmit 10 10.5.2.1
> ip route add 10.5.2.0/24 dev test0
> ip tunnel del test0
>=20

> Signed-off-by: Willem de Bruijn <willemb@google.com>

Sure !

When I did the original patch, I used following setup sequence.

ip link add gre34 type gre remote 1.2.3.4

I was not aware of the "ip tunnel add ..."

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
