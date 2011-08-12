From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] neigh: reduce arp latency
Date: Fri, 12 Aug 2011 02:57:08 -0700 (PDT)
Message-ID: <20110812.025708.1569052368114569085.davem@davemloft.net>
References: <1312904434.2371.39.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<alpine.LFD.2.00.1108091959250.1527@ja.ssi.bg>
	<1312913758.2547.8.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ja@ssi.bg, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52077 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752537Ab1HLJ5S convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2011 05:57:18 -0400
In-Reply-To: <1312913758.2547.8.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 09 Aug 2011 20:15:58 +0200

> Le mardi 09 ao=FBt 2011 =E0 20:06 +0300, Julian Anastasov a =E9crit :
>=20
>> 	To be correct with old NUD_INCOMPLETE logic may be we can use=20
>> max(neigh->parms->retrans_time, HZ/2) here instead of HZ?
>>=20
>=20
> Thanks Julian a lot for reviewing, here is v2 adressing this point.
>=20
> [PATCH v2 net-next] neigh: reduce arp latency
>=20
> Remove the artificial HZ latency on arp resolution.
>=20
> Instead of firing a timer in one jiffy (up to 10 ms if HZ=3D100), let=
s
> send the ARP message immediately.
>=20
> Before patch :
>=20
> # arp -d 192.168.20.108 ; ping -c 3 192.168.20.108
> PING 192.168.20.108 (192.168.20.108) 56(84) bytes of data.
> 64 bytes from 192.168.20.108: icmp_seq=3D1 ttl=3D64 time=3D9.91 ms
> 64 bytes from 192.168.20.108: icmp_seq=3D2 ttl=3D64 time=3D0.065 ms
> 64 bytes from 192.168.20.108: icmp_seq=3D3 ttl=3D64 time=3D0.061 ms
>=20
> After patch :
>=20
> $ arp -d 192.168.20.108 ; ping -c 3 192.168.20.108
> PING 192.168.20.108 (192.168.20.108) 56(84) bytes of data.
> 64 bytes from 192.168.20.108: icmp_seq=3D1 ttl=3D64 time=3D0.152 ms
> 64 bytes from 192.168.20.108: icmp_seq=3D2 ttl=3D64 time=3D0.064 ms
> 64 bytes from 192.168.20.108: icmp_seq=3D3 ttl=3D64 time=3D0.074 ms
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
