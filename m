From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 2.6.35.11 bridge drops fragmented packets
Date: Thu, 11 Aug 2011 16:17:10 +0200
Message-ID: <1313072230.3261.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1313066585.14145.18.camel@ierdnac-hp>
	 <1313069946.3261.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1313070275.814.2.camel@ierdnac-hp>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ierdnah@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:54009 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751241Ab1HKORL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2011 10:17:11 -0400
Received: by wwf5 with SMTP id 5so2093377wwf.1
        for <netdev@vger.kernel.org>; Thu, 11 Aug 2011 07:17:10 -0700 (PDT)
In-Reply-To: <1313070275.814.2.camel@ierdnac-hp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 11 ao=C3=BBt 2011 =C3=A0 16:44 +0300, Andrei Popa a =C3=A9crit=
 :
> On Thu, 2011-08-11 at 15:39 +0200, Eric Dumazet wrote:=20
> > Le jeudi 11 ao=C3=BBt 2011 =C3=A0 15:43 +0300, Andrei Popa a =C3=A9=
crit :
> > > Hello,
> > >=20
> > > We've got a problem with kernel 2.6.35.11 as it does not forward
> > > fragmented packets on a bridge.
> > > I've seen this thread
> > > http://lkml.indiana.edu/hypermail/linux/kernel/0604.0/0201.html a=
nd I
> > > thought to email you.
> > >=20
> > > The command "echo 0 > /proc/sys/net/bridge/bridge-nf-call-iptable=
s"
> > > fixes the problem.
> > >=20
> > > The config from the kernel is attached.
> > > The network configuration is as follows:
> > > cisco, interace in mode trunk with allowed vlan 1501,299 -> linux=
 ->
> > > cisco, interface in mode trunk with allowed vlan 1501
> > >=20
> > > The MTU on cisco and on linux interfaces is set to 1500.
> > > Packets with size 1500 and no fragments are forwarded succesfully=
,
> > > packets with size 1500 and fragments are not forwaded.
> > > On linux it's a bond comprised of eth1.1501 and eth0.1501.
> > > root@shaper_b2b_bucuresti:~# brctl show
> > > bridge name     bridge id               STP enabled     interface=
s
> > > br1501          8000.0015170ae7b8       no              eth0.1501
> > >                                                         eth1.1501
> > > I cand see the fragmented packets arriving on eth0 and eth0.1501 =
but I
> > > don't see them leaving on eth1 or eth1.1501.
> > >=20
> > > Andrei
> > >=20
> >=20
> > Could you give us output of 'netstat -s' to check if IP defrag drop=
s
> > some packets ?
> root@shaper_b2b_bucuresti:~# echo 1
> > /proc/sys/net/bridge/bridge-nf-call-iptables
>=20
> On a server behind the shaper:
>=20
> nl2 ~ # ping -s 65000 lg.telia.net
> PING juniperlg1-sn4.m-sp.skanova.net (81.228.10.74) 65000(65028) byte=
s
> of data.
> ^C
> ---=20

65000 bytes means 43 frames, and your network seems a bit busy.

If _one_ frame is lost (becasue of shaping for example), IP
fragmentation in bridge will fail -> all frames are discarded.

Could you try with "-s 2000" ?

I could not reproduce your problem on my dev machine (admitidly using a
more recent kernel)




