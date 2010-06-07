From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: RFS seems to have incompatiblities with bridged vlans
Date: Tue, 08 Jun 2010 00:19:20 +0200
Message-ID: <1275949160.2775.24.camel@edumazet-laptop>
References: <62C40338-045A-417E-9B90-E59A320E1343@dlh.net>
	 <20100607145910.2458ac87@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Peter Lieven <pl@dlh.net>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:56631 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753245Ab0FGWTZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jun 2010 18:19:25 -0400
Received: by wyi11 with SMTP id 11so2773148wyi.19
        for <netdev@vger.kernel.org>; Mon, 07 Jun 2010 15:19:24 -0700 (PDT)
In-Reply-To: <20100607145910.2458ac87@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 07 juin 2010 =C3=A0 14:59 -0700, Stephen Hemminger a =C3=A9cri=
t :
> On Mon, 7 Jun 2010 22:36:11 +0200
> Peter Lieven <pl@dlh.net> wrote:
>=20
> > Hi,
> >=20
> > i today tried out 2.6.32-rc2 and I see a lot of warning messages li=
ke this:
> >=20
> > Jun  7 22:33:15 172.21.55.20 kernel: [ 3012.575884] br141 received =
packet on queue 4, but number of RX queues is 1
> >=20
> > The host is a SMP system with 8 cores, so I think there is expected=
 to be one rx queue per CPU, but it seems
> > the bridge iface has only one.
> >=20
>=20
> The bridge interface has no queues. It doesn't queue any packets.=20
> The test in receive packet path is not appropriate in this case.
> Not sure what the right fix is. Pretending the bridge device has
> multiple queues (num_queues =3D=3D NUM_CPUS) is a possibility but
> seems like overhead without real increase in parallelism.

We have same problem with bonding and multiqueue devices...

It does make sense to pretend we have several queues, in case we have
another stage like

eth0	+
  	+-> bond0  -> vlan.1000
eth1	+

because in this case, vlan.1000 would also be multiqueue, so tx will be
parallelized on several queues.



