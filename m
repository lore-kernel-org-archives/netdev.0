From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Re: [PATCH net-next-2.6 1/2] mq: support for bonding
Date: Sun, 28 Feb 2010 10:05:38 +0100
Message-ID: <1267347938.9082.60.camel@edumazet-laptop>
References: <310461267277260@webmail48.yandex.ru>
	 <1267288154.9082.23.camel@edumazet-laptop>
	 <96591267345513@webmail87.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "\"Oleg A. Arkhangelsky\"" <sysoleg@yandex.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:35114 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031496Ab0B1JFo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Feb 2010 04:05:44 -0500
Received: by bwz1 with SMTP id 1so564230bwz.21
        for <netdev@vger.kernel.org>; Sun, 28 Feb 2010 01:05:42 -0800 (PST)
In-Reply-To: <96591267345513@webmail87.yandex.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 28 f=C3=A9vrier 2010 =C3=A0 11:25 +0300, "Oleg A. Arkhangel=
sky" a
=C3=A9crit :
> Hi Eric,
>=20
> 27.02.10, 17:29, "Eric Dumazet" <eric.dumazet@gmail.com>:
>=20
> >  My dev machine has 16 cpus, and my network card has 16 queues per =
NIC
>=20
> We should borrow this number from real device when enslaving it, pick=
ing
> maximum value from among slaves. But the main problem is that we don'=
t
> known anything about slaves in bond_create() and there is no way to c=
hange
> number of tx queues later. Maybe we could solve this by adding new mo=
dule
> parameter for bonding (num_tx_queues)?
>=20

It would be pretty hard to dynamically adjust number of txqueues
dynamically. Only current choice would be a sysfs parameter, to size
subsequent bond_create() queues, and also visible as a module parameter
so that implicit bond devices have the right number of queues.



> >  Every xmit has to get this lock(s) and performance is not optimal.
>=20
> You're right. I don't notice it. I see two solutions:
>=20
> 1) Convert all rw_locks to RCU mechanism
> 2) Use plain array instead of linked list to store list of slaves. In=
 this case we
> don't need to lock when doing bond_for_each_slave().
>=20

Best thing would be RCU of course, at least for the active/backup mode.


