From: Yang Hongyang <yanghy@cn.fujitsu.com>
Subject: Re: [RFC][PATCH 3/3]ipv6:fix the outgoing interface selection order
 in udpv6_sendmsg()
Date: Wed, 10 Dec 2008 08:42:20 +0800
Message-ID: <493F106C.8030803@cn.fujitsu.com>
References: <493E1A7B.9070208@cn.fujitsu.com> <200812090932.56865.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: =?ISO-8859-1?Q?R=E9mi_Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:61481 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751825AbYLJAkt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Dec 2008 19:40:49 -0500
In-Reply-To: <200812090932.56865.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

R=E9mi Denis-Courmont wrote:
> On Tuesday 09 December 2008 09:12:59 ext Yang Hongyang, you wrote:
>> 1.When no interface is specified in an IPV6_PKTINFO ancillary data
>>   item, the interface specified in an IPV6_PKTINFO sticky optionis
>>   is used.
>=20
>> diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
>> index 8b48512..addd856 100644
>> --- a/net/ipv6/udp.c
>> +++ b/net/ipv6/udp.c
>> @@ -761,6 +761,9 @@ do_udp_sendmsg:
>>  	}
>>
>>  	if (!fl.oif)
>> +		fl.oif =3D np->sticky_pktinfo.ipi6_ifindex;
>> +
>> +	if (!fl.oif)
>>  		fl.oif =3D sk->sk_bound_dev_if;
>>
>>  	if (msg->msg_controllen) {
>=20
> I believe overriding the outgoing interface is only allowed for link-=
local=20
> destinations, _or_ with privileges (as with SO_BINDTODEVICE).
>=20
> This patch seems to change this, and I am not convinced it's a good i=
dea.
>=20

It does not overriding the outgoing interface.
when no interface is specified in an IPV6_PKTINFO ancillary data item(a=
s with
 SO_BINDTODEVICE), the interface specified in an IPV6_PKTINFO sticky=20
optionins  is used.

If outgoing interface is set with SO_BINDTODEVICE and also sticky pktin=
fo
the outgoing interface is exactly what SO_BINDTODEVICE set,because in m=
y
first patch,when set sticy pktinfo,outgoing interface set by SO_BINDTOD=
EVICE
is checked:

+		if(sk->sk_bound_dev_if && pkt.ipi6_ifindex !=3D sk->sk_bound_dev_if)
+			goto e_inval;


