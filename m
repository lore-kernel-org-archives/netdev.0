From: Kumar S <ps2kumar@yahoo.com>
Subject: Re: Memory leak in ip_dst_cache
Date: Mon, 12 Sep 2011 10:16:41 -0700 (PDT)
Message-ID: <1315847801.41447.YahooMailNeo@web113916.mail.gq1.yahoo.com>
References: <1315544674.20226.YahooMailNeo@web113902.mail.gq1.yahoo.com>  <1315546223.5410.23.camel@edumazet-laptop>  <1315593553.98279.YahooMailNeo@web113904.mail.gq1.yahoo.com>  <1315596786.2606.3.camel@edumazet-laptop>  <1315601283.91185.YahooMailNeo@web113908.mail.gq1.yahoo.com>  <1315604820.2606.13.camel@edumazet-laptop>  <1315605497.25052.YahooMailNeo@web113916.mail.gq1.yahoo.com>  <1315606125.2606.19.camel@edumazet-laptop>  <1315608825.98066.YahooMailNeo@web113914.mail.gq1.yahoo.com>  <20110910130416.GA2005@neilslaptop.think-freely.org>  <1315798710.96027.YahooMailNeo@web113913.mail.gq1.yahoo.com>  <1315806031.3174.16.camel@edumazet-laptop>  <1315807643.92529.YahooMailNeo@web113911.mail.gq1.yahoo.com> <1315808931.3174.17.camel@edumazet-laptop>
Reply-To: Kumar S <ps2kumar@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neil Horman <nhorman@tuxdriver.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm6-vm4.bullet.mail.ne1.yahoo.com ([98.138.91.166]:29343 "HELO
	nm6-vm4.bullet.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752761Ab1ILRWO convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Sep 2011 13:22:14 -0400
In-Reply-To: <1315808931.3174.17.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

----- Original Message -----
=46rom: Eric Dumazet <eric.dumazet@gmail.com>
To: Kumar S <ps2kumar@yahoo.com>
Cc: Neil Horman <nhorman@tuxdriver.com>; netdev <netdev@vger.kernel.org=
>
Sent: Sunday, September 11, 2011 11:28 PM
Subject: Re: Memory leak in ip_dst_cache

Le dimanche 11 septembre 2011 =E0 23:07 -0700, Kumar S a =E9crit :
>> ----- Original Message -----
>> From: Eric Dumazet <eric.dumazet@gmail.com>
> >To: Kumar S <ps2kumar@yahoo.com>
> >Cc: Neil Horman <nhorman@tuxdriver.com>; netdev <netdev@vger.kernel.=
org>
> >Sent: Sunday, September 11, 2011 10:40 PM
> Subject: Re: Memory leak in ip_dst_cache
> >
>> Le dimanche 11 septembre 2011 =E0 20:38 -0700, Kumar S a =E9crit :
>>=20
>> Please dont top post.
>>=20
> >>> Thanks Neil. I did try with prink(). I do see entries getting age=
d
> >>> out, but they are not getting deallocated. This seems to be happe=
ning
> >>>because of "ref_cnt". When the route entries are added the ref_cnt=
 is
> >>> set to 1. Looks this is causing trouble clearing the entries
> >>> completely. If I set the ref_cnt to 0, I can see it working. Now =
I'm
> >>> trying to understand whether this is right. Please let me know if=
 you
> >>> have any thoughts on it.
>>=20
> >>I believe I already explained what was happening.
>>=20
> >>A tcp socket has a pointer to a dst, so it holds a reference on it,=
 to
> >>make sure no freeing of dst can happen while at least some socket s=
till
> >>can reference dst. (It could reference freed memory and crash)
>>=20
> >>As soon as the tcp socket will try to transmit some data, the dst w=
ill
> >>be checked and we notice its obsolete : We then release the refcoun=
t and
> >>dst pointer.
> >
> >>Later, the garbage collector can notice dst refcount is zero and ca=
n
> >>free dst.
> >
> >>If you have dormant tcp sockets (no trafic at all), they hold their=
 dst.
> >>A dormant tcp socket has a pretty more expensive memory cost than i=
ts
> >>dst. (Socket structure, dentry, inode, and probably in user land a
> >>thread or process, and data)
>=A0>=20
>> Thanks Eric for detailed explanation. You did mention this before.
>> What I see is the cache entries related to the TCP sockets are getti=
ng
> >cleared, whenever they age out. But the issue we see here is with th=
e
> >broadcast messages such as SMB messages and network neighbor hood
>> messages. They never get freed. There is no traffic to those
> >destinations from our board.=20

>What do you mean ? Your box is a router only ?

>Those SMB messages are going through it ?
=A0
Our box is a stand-alone system with L2 Quick Engine. This QE forwards =
all broadcast to the other ports and also a copy to the CPU port.=20
