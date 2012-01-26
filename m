From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix ip_gre lockless xmits
Date: Thu, 26 Jan 2012 16:36:16 -0500 (EST)
Message-ID: <20120126.163616.1469086973420297146.davem@davemloft.net>
References: <1327610075-5833-1-git-send-email-willemb@google.com>
	<1327611491.4140.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: willemb@google.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34807 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753874Ab2AZVgV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2012 16:36:21 -0500
In-Reply-To: <1327611491.4140.12.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 26 Jan 2012 21:58:11 +0100

> Le jeudi 26 janvier 2012 =E0 15:34 -0500, Willem de Bruijn a =E9crit =
:
>> Tunnel devices set NETIF_F_LLTX to bypass HARD_TX_LOCK.  Sit and
>> ipip set this unconditionally in ops->setup, but gre enables it
>> conditionally after parameter passing in ops->newlink. This is
>> not called during tunnel setup as below, however, so GRE tunnels are
>> still taking the lock.
>>=20
>> modprobe ip_gre
>> ip tunnel add test0 mode gre remote 10.5.1.1 dev lo
>> ip link set test0 up
>> ip addr add 10.6.0.1 dev test0
>>  # cat /sys/class/net/test0/features
>>  # $DIR/test_tunnel_xmit 10 10.5.2.1
>> ip route add 10.5.2.0/24 dev test0
>> ip tunnel del test0
>>=20
>=20
>> Signed-off-by: Willem de Bruijn <willemb@google.com>
>=20
> Sure !
>=20
> When I did the original patch, I used following setup sequence.
>=20
> ip link add gre34 type gre remote 1.2.3.4
>=20
> I was not aware of the "ip tunnel add ..."
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
