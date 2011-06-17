From: Tomasz Chmielewski <mangoo@wpkg.org>
Subject: Re: what's causing "ip_rt_bug"?
Date: Fri, 17 Jun 2011 23:37:46 +0200
Message-ID: <4DFBC92A.2030901@wpkg.org>
References: <4DFBB270.8000003@wpkg.org> <1308342993.3539.30.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.virtall.com ([178.63.195.102]:45643 "EHLO mail.virtall.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751049Ab1FQVhu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 17:37:50 -0400
In-Reply-To: <1308342993.3539.30.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17.06.2011 22:36, Eric Dumazet wrote:
> Le vendredi 17 juin 2011 =C3=A0 22:00 +0200, Tomasz Chmielewski a =C3=
=A9crit :
>> I have a system pushing around 800 Mbit/s, ~130 kpps.
>>
>> It uses 2.6.35.12 kernel.
>>
>>
>> Several times a minute, I can see entries like (a.b.c.d - IP of this=
 system):
>>
>> Jun 18 02:39:19 KOR-SV22 kernel: [37187.665951] ip_rt_bug: 110.x.x.x=
 ->  a.b.c.d, ?
>> Jun 18 02:39:19 KOR-SV22 kernel: [37187.685419] ip_rt_bug: 110.x.x.x=
 ->  a.b.c.d, ?
>> Jun 18 02:40:31 KOR-SV22 kernel: [37259.199315] ip_rt_bug: 124.x.x.x=
 ->  a.b.c.d, ?
>> Jun 18 02:40:36 KOR-SV22 kernel: [37263.828000] ip_rt_bug: 124.x.x.x=
 ->  a.b.c.d, ?
>> Jun 18 02:44:16 KOR-SV22 kernel: [37484.120689] ip_rt_bug: 110.x.x.x=
 ->  a.b.c.d, ?
>> Jun 18 02:44:19 KOR-SV22 kernel: [37487.114357] ip_rt_bug: 110.x.x.x=
 ->  a.b.c.d, ?
>>
>=20
> Hi
>=20
> What your routing table looks like ? (ip ro)

It's just a proxy, no special routing set:

# ip ro
58.185.117.18 via 119.46.110.193 dev eth0=20
119.46.240.13 via 119.46.110.193 dev eth0=20
58.185.117.29 via 119.46.110.193 dev eth0=20
119.46.241.13 via 119.46.110.193 dev eth0=20
58.185.117.28 via 119.46.110.193 dev eth0=20
119.46.110.192/26 dev eth0  proto kernel  scope link  src 119.46.110.19=
7=20
169.254.0.0/16 dev eth0  scope link=20
default via 119.46.110.195 dev eth0=20


The box is also crashing every few days; and I really had no clue why (=
just connected a serial console to catch any new oops/panic).


The last time it crashed, I have this entry in syslog:

Jun 17 16:16:17 TRUE-SC02 kernel: [172488.602629] ip_rt_bug: 124.121.15=
5.197 -> 119.46.110.197, ?
Jun 17 16:17:00 TRUE-SC02 kernel: [172531.239041] BUG: unable to handle=
 kernel NULL pointer dereference at (null)
Jun 17 16:17:00 TRUE-SC02 kernel: [172531.239409] IP: [<ffffffff81361ca=
e>] dev_queue_xmit+0x1e3/0x441
Jun 17 16:17:00 TRUE-SC02 kernel: [172531.239760] PGD 43c30b067 PUD 439=
e63067 PMD 0
Jun 17 16:17:00 TRUE-SC02 kernel: [172531.240103] Oops: 0000 [#1] SMP
Jun 17 16:19:58 TRUE-SC02 syslogd 1.4.1: restart.



Right now, it uses the newest igb driver, and I started seeing "Out of =
socket memory" quite a bit (didn't have it with the original igb driver=
 from 2.6.35.12).

So I doubled this value to be:

 net.ipv4.tcp_max_orphans =3D 256000


and "Out of socket memory" stopped showing up.

Instead, "ip_rt_bug" shows up.


--=20
Tomasz Chmielewski
http://wpkg.org
