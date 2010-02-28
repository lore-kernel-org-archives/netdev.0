From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Adding inode field to /proc/net/netlink
Date: Sun, 28 Feb 2010 10:44:06 +0100
Message-ID: <1267350246.9082.69.camel@edumazet-laptop>
References: <20100228.144537.445518512048328806.yamato@redhat.com>
	 <20100228.010057.229746532.davem@davemloft.net>
	 <20100228.185045.366957605052790072.yamato@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Masatake YAMATO <yamato@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:53212 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031694Ab0B1JoL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Feb 2010 04:44:11 -0500
Received: by bwz1 with SMTP id 1so573027bwz.21
        for <netdev@vger.kernel.org>; Sun, 28 Feb 2010 01:44:10 -0800 (PST)
In-Reply-To: <20100228.185045.366957605052790072.yamato@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 28 f=C3=A9vrier 2010 =C3=A0 18:50 +0900, Masatake YAMATO a =
=C3=A9crit :

> I understood but it has been already breaking:
>=20
>     [yamato@xxx /proc/net]$ uname -a; cat /proc/net/netlink=20
>     Linux xxx.redhat.com 2.6.29.6-217.2.16.fc11.x86_64 #1 SMP Mon Aug=
 24 17:17:40 EDT 2009 x86_64 x86_64 x86_64 GNU/Linux
>     sk       Eth Pid    Groups   Rmem     Wmem     Dump     Locks
>     ffff8801bbde0400 0   2758   00000111 0        0        (null) 2
>     ...
>=20
>     [yamato@yyy /proc/net]$ uname -a; cat /proc/net/netlink=20
>     Linux yyy.redhat.com 2.6.30.10-105.2.23.fc11.x86_64 #1 SMP Thu Fe=
b 11 07:06:34 UTC 2010 x86_64 x86_64 x86_64 GNU/Linux
>     sk       Eth Pid    Groups   Rmem     Wmem     Dump     Locks    =
 Drops
>     ffff8800d83f5800 0   1783   00000001 0        0        (null) 2  =
      0      =20
>=20
> Drops field may be added between 2.6.29 and 2.6.30.
> Adding one more field is really problem?
> In other word, why "Drops" field was acceptable?
>=20
> lsof uses following technique. It parses the header raw
> (here "    sk       Eth Pid    Groups   Rmem     Wmem     Dump     Lo=
cks     Drops")
> and picks values from columns only if the columns exits in the header=
 raw.
> e.g. If "Inode" exists in the header, lsof tries to use Inode value.
> With the technique just adding(not deleting or swapping) a new column=
 is not a big problem.
>=20
> Masatake YAMATO
>=20

Indeed :)

I am a big fan of Vic Abell lsof tool that I used before Linux was even
born :)



