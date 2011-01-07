From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2.6.36] vlan: Avoid hwaccel vlan packets when vid not
 used
Date: Fri, 07 Jan 2011 02:20:01 +0100
Message-ID: <1294363201.2704.19.camel@edumazet-laptop>
References: <1291536233.2806.102.camel@edumazet-laptop>
	 <20101205105528.49fa9a9f@xenia.leun.net>
	 <20101205114404.7c0cddc2@xenia.leun.net>
	 <AANLkTikrDTCDxsyOG4m0XcrOY=3pTRwWqnPGsio9cBFj@mail.gmail.com>
	 <20101206203437.54b550e0@xenia.leun.net>
	 <AANLkTikKkAesHc4Fi4SwAkV0e65D0TQRztrRYoDNu3MP@mail.gmail.com>
	 <20101206222703.32fbe852@xenia.leun.net>
	 <AANLkTinLMCzKz7n45HdeAwNxsWjCADAkgfK+MjXVcFqh@mail.gmail.com>
	 <20101213224510.GB17400@mcarlson.broadcom.com>
	 <AANLkTi=9BYt=vkNkAiTBxnfnCjCX7AqCG=ML6coc4vdZ@mail.gmail.com>
	 <20101214191500.GD19951@mcarlson.broadcom.com>
	 <1293901393.2535.49.camel@edumazet-laptop>
	 <AANLkTinq9ABi0prxe0m1Ma6rno4UnAOzuW-b5L362ij9@mail.gmail.com>
	 <1293984348.2535.101.camel@edumazet-laptop>
	 <AANLkTincX-wPQE9gs16v53E4=Skivzc4ZSJS43oNBLD_@mail.gmail.com>
	 <1294356887.2704.13.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Matt Carlson <mcarlson@broadcom.com>,
	Michael Leun <lkml20101129@newton.leun.net>,
	Michael Chan <mchan@broadcom.com>,
	David Miller <davem@davemloft.net>,
	Ben Greear <greearb@candelatech.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1294356887.2704.13.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 07 janvier 2011 =C3=A0 00:34 +0100, Eric Dumazet a =C3=A9cr=
it :
> Le jeudi 06 janvier 2011 =C3=A0 16:01 -0500, Jesse Gross a =C3=A9crit=
 :
>=20
> > Hmm, I thought that it might be some interaction with a corner case=
 in
> > the networking core but now it seems less likely.  There weren't to=
o
> > many vlan changes between the working and non-working states.  Plus=
,
> > since the rx counter isn't increasing, the packets probably aren't
> > making it anywhere.
> >=20
> > I see that tg3 increases the drop counter in one place, which also
> > happens to be checking for vlan errors (at tg3.c:4753).  That seems
> > suspicious - maybe the NIC is only partially configured for vlan
> > offloading.  If we can confirm that is where the drop counter is be=
ing
> > incremented and what the error code is maybe it would shed some lig=
ht.
> >=20
>=20
> Hmm... I am pretty sure the drop counter is the dev rx_dropped (core
> network handled, not tg3 one) incremented at the end of
> __netif_receive_skb() : We found no suitable handler for packets.
>=20
> atomic_long_inc(&skb->dev->rx_dropped);
>=20
> But thats a guess, I'll have to check
>=20

wrong guess. Its really the tg3 which drops frames

increasing rx_missed_errors  (get_stat64(&hw_stats->rx_discards)

ip -s -s link show dev eth2
5: eth2: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc mq
master bond0 state UP qlen 1000
    link/ether 00:1e:0b:92:78:50 brd ff:ff:ff:ff:ff:ff
    RX: bytes  packets  errors  dropped overrun mcast  =20
    11627      167      0       0       0       2     =20
    RX errors: length  crc     frame   fifo    missed
               0        0       0       0       2713  =20
    TX: bytes  packets  errors  dropped carrier collsns=20
    2274       31       0       0       0       0     =20
    TX errors: aborted fifo    window  heartbeat
               0        0       0       0     =20



It would be nice Broadcom guys could help a bit ?
