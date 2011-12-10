From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH 11/13] udp_diag: Implement the get_exact dumping functionality
Date: Sat, 10 Dec 2011 13:07:51 +0400
Message-ID: <4EE32167.2080202@parallels.com>
References: <4EE23561.5020804@parallels.com>	 <4EE23626.6000104@parallels.com> <1323467297.4016.10.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:44751 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752089Ab1LJJIA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Dec 2011 04:08:00 -0500
In-Reply-To: <1323467297.4016.10.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/10/2011 01:48 AM, Eric Dumazet wrote:
> Le vendredi 09 d=C3=A9cembre 2011 =C3=A0 20:24 +0400, Pavel Emelyanov=
 a =C3=A9crit :
>> Do the same as TCP does -- lookup a socket in the given udp_table,
>> check cookie, fill the reply message with existing inet socket dumpi=
ng
>> helper and send one back.
>>
>> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
>=20
>> +
>> +	if (req->sdiag_family =3D=3D AF_INET)
>> +		sk =3D __udp4_lib_lookup(&init_net,
>> +				req->id.idiag_src[0], req->id.idiag_sport,
>> +				req->id.idiag_dst[0], req->id.idiag_dport,
>> +				req->id.idiag_if, tbl);
>> +	else if (req->sdiag_family =3D=3D AF_INET6)
>> +		sk =3D __udp6_lib_lookup(&init_net,
>> +				(struct in6_addr *)req->id.idiag_src,
>> +				req->id.idiag_sport,
>> +				(struct in6_addr *)req->id.idiag_dst,
>> +				req->id.idiag_dport,
>> +				req->id.idiag_if, tbl);
>> +	else
>=20
> OK, but what happens if IPv6 is a module ?

And the udp_diag is built-in, right?

>   LD      .tmp_vmlinux1
> net/built-in.o: In function `udp_dump_one':
> udp_diag.c:(.text+0xa2b40): undefined reference to `__udp6_lib_lookup=
'
> make: *** [.tmp_vmlinux1] Erreur 1

Crap :( I suppose the Kconfig rule should be fixed, I will try to provi=
de a fix...

Thanks,
Pavel
