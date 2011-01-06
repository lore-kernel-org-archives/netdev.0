From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2.6.36] vlan: Avoid hwaccel vlan packets when vid not
 used
Date: Fri, 07 Jan 2011 00:34:47 +0100
Message-ID: <1294356887.2704.13.camel@edumazet-laptop>
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
In-Reply-To: <AANLkTincX-wPQE9gs16v53E4=Skivzc4ZSJS43oNBLD_@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 06 janvier 2011 =C3=A0 16:01 -0500, Jesse Gross a =C3=A9crit :

> Hmm, I thought that it might be some interaction with a corner case i=
n
> the networking core but now it seems less likely.  There weren't too
> many vlan changes between the working and non-working states.  Plus,
> since the rx counter isn't increasing, the packets probably aren't
> making it anywhere.
>=20
> I see that tg3 increases the drop counter in one place, which also
> happens to be checking for vlan errors (at tg3.c:4753).  That seems
> suspicious - maybe the NIC is only partially configured for vlan
> offloading.  If we can confirm that is where the drop counter is bein=
g
> incremented and what the error code is maybe it would shed some light=
=2E
>=20

Hmm... I am pretty sure the drop counter is the dev rx_dropped (core
network handled, not tg3 one) incremented at the end of
__netif_receive_skb() : We found no suitable handler for packets.

atomic_long_inc(&skb->dev->rx_dropped);

But thats a guess, I'll have to check

> If it's a driver issue I don't have much insight - maybe Matt or
> bisect can help.
>=20
> >> If it works on bnx2, it would seem to be a driver problem but it w=
ould
> >> be good to confirm that the tag in skb->vlan_tci is not being
> >> delievered to the networking core in this case.
> >
> > Hmm, where do you want me to check this ?
>=20
> I was thinking right before vlan_gro_receive() at tg3.c:4837.  If my
> theory above is right then this obviously isn't relevant since it
> won't be hit at all.  Otherwise it would be good to know exactly what
> the driver is producing.
