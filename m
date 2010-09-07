From: =?UTF-8?B?S3J6eXN6dG9mIE9sxJlkemtp?= <ole@ans.pl>
Subject: Re: 2.6.34: Problem with UDP traffic on lo + poll(?)
Date: Tue, 07 Sep 2010 23:51:02 +0200
Message-ID: <4C86B3C6.7040809@ans.pl>
References: <alpine.LNX.1.10.1009061745280.20113@bizon.gios.gov.pl>	 <1283802132.2585.4.camel@edumazet-laptop>  <4C854737.5040503@ans.pl>	 <1283804955.2585.12.camel@edumazet-laptop> <4C8552B1.8020806@ans.pl>	 <4C855385.7030203@ans.pl>  <4C865C21.5010803@ans.pl>	 <1283877391.2313.62.camel@edumazet-laptop>	 <1283887569.2634.95.camel@edumazet-laptop>  <4C86AE96.40704@ans.pl> <1283895544.2634.256.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([195.187.34.71]:59519 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751056Ab0IGVvJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Sep 2010 17:51:09 -0400
In-Reply-To: <1283895544.2634.256.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2010-09-07 23:39, Eric Dumazet wrote:
> Le mardi 07 septembre 2010 =C3=A0 23:28 +0200, Krzysztof Ol=C4=99dzki=
 a =C3=A9crit :
>=20
>> With the above patch I'm no longer able to reproduce the problem. Th=
anks!
>>
>> Tested-by: Krzysztof Piotr Oledzki<ole@ans.pl>
>>
>=20
> Thanks a lot !
>=20
>> BTW: why it takes so long to trigger this bug and it is only possibl=
e
>> over a loopback interface?
>=20
> Its a bit tricky : You need at least 10 sockets linked in a particula=
r
> hash chain.
>=20
> To check this, you can :
>=20
> cat /proc/net/udp
>=20
> maybe you have many sockets on port 123 or 53 ?

On one affected host I have 3+7 and on the other, also affacted one, I =
have 3+6:

root@sowa:~# egrep -cw '(53|123):' /proc/net/udp
10
root@sowa:~# egrep -w '(53|123):' /proc/net/udp
   53: 3582A8C0:0035 00000000:0000 07 00000000:00000000 00:00000000 000=
00000     0        0 6084654 2 ffff8800cc012700 0
   53: 0100007F:0035 00000000:0000 07 00000000:00000000 00:00000000 000=
00000     0        0 6084652 2 ffff8800cc010900 0
  123: D683A8C0:007B 00000000:0000 07 00000000:00000000 00:00000000 000=
00000     0        0 4911 2 ffff88012de96400 0
  123: 7B85A8C0:007B 00000000:0000 07 00000000:00000000 00:00000000 000=
00000     0        0 4910 2 ffff88012de96100 0
  123: 8982A8C0:007B 00000000:0000 07 00000000:00000000 00:00000000 000=
00000     0        0 4909 2 ffff88012de95e00 0
  123: 7B82A8C0:007B 00000000:0000 07 00000000:00000000 00:00000000 000=
00000     0        0 4908 2 ffff88012de95b00 0
  123: 3582A8C0:007B 00000000:0000 07 00000000:00000000 00:00000000 000=
00000     0        0 4907 2 ffff88012de95800 0
  123: 1F7EA8C0:007B 00000000:0000 07 00000000:00000000 00:00000000 000=
00000     0        0 4906 2 ffff88012de95500 0
  123: 0100007F:007B 00000000:0000 07 00000000:00000000 00:00000000 000=
00000     0        0 4905 2 ffff88012de95200 0
  123: 00000000:007B 00000000:0000 07 00000000:00000000 00:00000000 000=
00000     0        0 4899 2 ffff88012de94c00 0

root@cmyk:~# egrep -cw '(53|123):' /proc/net/udp
9
root@cmyk:~# egrep -w '(53|123):' /proc/net/udp
   53: A2CD1253:0035 00000000:0000 07 00000000:00000000 00:00000000 000=
00000     0        0 3774 2 eeaa9840 0
   53: 0100A8C0:0035 00000000:0000 07 00000000:00000000 00:00000000 000=
00000     0        0 3772 2 eeaa9a40 0
   53: 0100007F:0035 00000000:0000 07 00000000:00000000 00:00000000 000=
00000     0        0 3770 2 eeaa9c40 0
  123: A6CD1253:007B 00000000:0000 07 00000000:00000000 00:00000000 000=
00000     0        0 4693 2 eeacdc80 0
  123: A5CD1253:007B 00000000:0000 07 00000000:00000000 00:00000000 000=
00000     0        0 4692 2 eeaa9640 0
  123: A2CD1253:007B 00000000:0000 07 00000000:00000000 00:00000000 000=
00000     0        0 4691 2 ed201700 0
  123: 0100A8C0:007B 00000000:0000 07 00000000:00000000 00:00000000 000=
00000     0        0 4690 2 eeacd880 0
  123: 0100007F:007B 00000000:0000 07 00000000:00000000 00:00000000 000=
00000     0        0 4689 2 ec649740 0
  123: 00000000:007B 00000000:0000 07 00000000:00000000 00:00000000 000=
00000     0        0 4683 2 ed201d00 0

But how 123 is related to 53?

> And about loopback, I have no idea... I am pretty sure I can trigger =
the
> bug with other interfaces.

OK. Probably it is because my other hosts have only a single IP and onl=
y
the problematic ones have both DNS server and multiple IP (many sockets=
).

Best regards,

			Krzysztof Ol=C4=99dzki
