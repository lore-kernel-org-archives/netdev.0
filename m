From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [BUG] net_sched: failed bisection
Date: Wed, 23 Mar 2011 07:45:58 +0100
Message-ID: <1300862758.2717.41.camel@edumazet-laptop>
References: <1299087087.2920.27.camel@edumazet-laptop>
	 <1299140868.2456.35.camel@edumazet-laptop>
	 <1299148820.2983.56.camel@edumazet-laptop>
	 <1299165497.2983.104.camel@edumazet-laptop>
	 <20110303161912.GC29685@gandalf.sssup.it>
	 <1299170053.2983.134.camel@edumazet-laptop>
	 <20110303181339.GD29685@gandalf.sssup.it>
	 <1299180567.2547.4.camel@edumazet-laptop>
	 <1299192974.2547.13.camel@edumazet-laptop>
	 <20110304064302.GE29685@gandalf.sssup.it>
	 <1299222074.2547.50.camel@edumazet-laptop>
	 <AANLkTinAGjZ5SAOA1iUAFu5rtYydeb6Soy_Xg5kMvn-z@mail.gmail.com>
	 <1299274468.2758.4.camel@edumazet-laptop>
	 <AANLkTikeQCfShKfZWq2Y7V_MA4iRjQvWWtkC68rK9nUm@mail.gmail.com>
	 <1299277003.2758.52.camel@edumazet-laptop>
	 <AANLkTinR7QDC2uGjQurJQ1JfBA7q1pxyewePggh87z8E@mail.gmail.com>
	 <1299278778.2758.53.camel@edumazet-laptop>
	 <AANLkTikBoQd+ZA1kY0F0MvUsJ8Y=9KwGkfmZNdi4hLXz@mail.gmail.com>
	 <20110304150741.5d4aa354@nehalam>
	 <AANLkTi=HBDayfd0bEA+AQqzjTKMajghet=UJAw9vL56A@mail.gmail.com>
	 <20110309110242.3307ca69@nehalam>
	 <1300016057.2761.16.camel@edumazet-laptop>
	 <1300034690.2761.29.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Fabio Checconi <fchecconi@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:61183 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751876Ab1CWGqF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2011 02:46:05 -0400
Received: by bwz15 with SMTP id 15so6444556bwz.19
        for <netdev@vger.kernel.org>; Tue, 22 Mar 2011 23:46:03 -0700 (PDT)
In-Reply-To: <1300034690.2761.29.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 13 mars 2011 =C3=A0 17:44 +0100, Eric Dumazet a =C3=A9crit =
:
> Le dimanche 13 mars 2011 =C3=A0 12:34 +0100, Eric Dumazet a =C3=A9cri=
t :
> > Le mercredi 09 mars 2011 =C3=A0 11:02 -0800, Stephen Hemminger a =C3=
=A9crit :
> > > This is an implementation of the Quick Fair Queue scheduler devel=
oped
> > > by Fabio Checconi. The same algorithm is already implemented in i=
pfw
> > > in FreeBSD. Fabio had an earlier version developed on Linux, I ju=
st
> > > cleaned it up.  Thanks to Eric Dumazet for doing the testing and
> > > finding bugs.
> > >=20
> > > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> > >=20
> >=20
> > Hi Stephen
> >=20
> > My stress tests run fine on this version, please send it to David a=
nd
> > netdev and feel free to add my :
> >=20
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> >=20
>=20
> Ah well, no... sorry
>=20
> After a while, I restarted some udpflood tests and no packet was goin=
g
> through my dummy0 device. So I wanted to restart my qfq_setup script =
and
> it froze :
>=20
> root      9265 97.0  0.0  2056  440 pts/1    R+   17:41   0:29 tc qdi=
sc del dev dummy0 root
> root      9268  0.0  0.0  2452  760 pts/0    R+   17:42   0:00 ps aux=
w
>=20
> a bit later :
>=20
> root      9265 99.3  0.0  2056  440 pts/1    R+   17:41   2:43 tc qdi=
sc del dev dummy0 root
>=20
>=20

Hi guys

QFQ scheduler update :

While polishing QFQ scheduler, and tracking a bug in it, I finally
replaced in my tc scripts "QFQ experimental" by "SFQ rock solid" and
found I could have a hang in some situations :(

I made a bisection and found :

# git bisect good
7a6362800cb7d1d618a697a650c7aaed3eb39320 is the first bad commit

It seems I am stuck...

# git bisect log
git bisect start
# bad: [c360d5b53a7fec44ae4402e1f13fc888f57ddc3b] Merge branch 'master'
of git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6
git bisect bad c360d5b53a7fec44ae4402e1f13fc888f57ddc3b
# good: [07a2039b8eb0af4ff464efd3dfd95de5c02648c6] Linux 2.6.30
git bisect good 07a2039b8eb0af4ff464efd3dfd95de5c02648c6
# good: [2ec8c6bb5d8f3a62a79f463525054bae1e3d4487] Merge branch 'master=
'
of /home/davem/src/GIT/linux-2.6/
git bisect good 2ec8c6bb5d8f3a62a79f463525054bae1e3d4487
# good: [e0e170bd7ded2ec16e2813d63c0faff43193fde8] Merge branch 'next'
of git://git.monstr.eu/linux-2.6-microblaze
git bisect good e0e170bd7ded2ec16e2813d63c0faff43193fde8
# good: [40c73abbb37e399eba274fe49e520ffa3dd65bdb] Merge branch
'for_linus' of
git://git.kernel.org/pub/scm/linux/kernel/git/jack/linux-fs-2.6
git bisect good 40c73abbb37e399eba274fe49e520ffa3dd65bdb
# good: [4b66fef9b591b95f447aea12242a1133deb0bd22] mcast: net_device de=
v
not used
git bisect good 4b66fef9b591b95f447aea12242a1133deb0bd22
# bad: [7a6362800cb7d1d618a697a650c7aaed3eb39320] Merge
git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next-2.6
git bisect bad 7a6362800cb7d1d618a697a650c7aaed3eb39320
# good: [971f115a50afbe409825c9f3399d5a3b9aca4381] Merge branch
'usb-next' of
git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/usb-2.6
git bisect good 971f115a50afbe409825c9f3399d5a3b9aca4381
# good: [5917def58ab9f5848f2d1da835a33a490d0c8c69] staging/easycap:
reduce code nesting in easycap_sound.c
git bisect good 5917def58ab9f5848f2d1da835a33a490d0c8c69
# good: [6445ced8670f37cfc2c5e24a9de9b413dbfc788d] Merge branch
'staging-next' of
git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/staging-2.6
git bisect good 6445ced8670f37cfc2c5e24a9de9b413dbfc788d
# good: [da91981bee8de20bcd06ee0dbddd53d62d23b1bd] ipv4: Use flowi4 in
ipmr code.
git bisect good da91981bee8de20bcd06ee0dbddd53d62d23b1bd
# good: [106af2c99a5249b809aaed45b8353ac087821f4a] Merge branch 'master=
'
of
git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-2.=
6
into for-davem
git bisect good 106af2c99a5249b809aaed45b8353ac087821f4a
# good: [638be344593b66ccca6802c6076a5b3d9200829d] Phonet: fix
aligned-mode pipe socket buffer header reserve
git bisect good 638be344593b66ccca6802c6076a5b3d9200829d
# good: [c337ffb68e1e71bad069b14d2246fa1e0c31699c] Merge branch 'master=
'
of master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6
git bisect good c337ffb68e1e71bad069b14d2246fa1e0c31699c
# good: [ee0caa79569a9c44febc18480beef4847aa8cecd] Merge branch 'master=
'
of git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-next-2.6
git bisect good ee0caa79569a9c44febc18480beef4847aa8cecd
# good: [0bd80dad57d82676ee484fb1f9aa4c5e8b5bc469] net: get rid of
multiple bond-related netdevice->priv_flags
git bisect good 0bd80dad57d82676ee484fb1f9aa4c5e8b5bc469
# good: [8a4eb5734e8d1dc60a8c28576bbbdfdcc643626d] net: introduce
rx_handler results and logic around that
git bisect good 8a4eb5734e8d1dc60a8c28576bbbdfdcc643626d
# good: [ceda86a108671294052cbf51660097b6534672f5] bonding: enable
netpoll without checking link status
git bisect good ceda86a108671294052cbf51660097b6534672f5

Any idea how we can find the problem ?

Script to reproduce the problem :


modprobe dummy

ifconfig dummy0 10.2.2.254 netmask 255.255.255.0 up

for i in `seq 1 240`
do
 arp -H ether -i dummy0 -s 10.2.2.$i 00:00:0c:07:ac:$(printf %02x $i)
done


DEV=3Ddummy0
RATE=3D"rate 40Mbit"
TNETS=3D"10.2.2.0/25"
ALLOT=3D"allot 20000"


tc qdisc del dev dummy0 root 2>/dev/null


tc qdisc add dev $DEV root handle 1: est 1sec 8sec cbq avpkt 1000 rate =
100Mbit \
	bandwidth 100Mbit
tc class add dev $DEV parent 1: classid 1:1 \
	est 1sec 8sec cbq allot 10000 mpu 64 \
	rate 100Mbit prio 1 avpkt 1500 bounded

# output to test nets :  40 Mbit limit
tc class add dev $DEV parent 1:1 classid 1:11 \
	est 1sec 8sec cbq $ALLOT mpu 64      \
	$RATE prio 2 avpkt 1400 bounded

tc qdisc add dev $DEV parent 1:11 handle 11:  \
	est 1sec 8sec sfq


for privnet in $TNETS
do
	tc filter add dev $DEV parent 1: protocol ip prio 100 u32 \
		match ip dst $privnet flowid 1:11
done

tc filter add dev $DEV parent 1: protocol ip prio 100 u32 \
	match ip protocol 0 0x00 flowid 1:1


iperf -u -c 10.2.2.1 -P 32 -l 50
iperf -u -c 10.2.2.1 -P 32 -l 50
iperf -u -c 10.2.2.1 -P 32 -l 50
tc -s -d qdisc show dev dummy0


