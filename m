From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: Re: SFQ on HFSC leaf does not seem to work
Date: Fri, 23 Dec 2011 10:26:53 -0500
Message-ID: <1324654013.10184.597.camel@denise.theartistscloset.com>
References: <1324620022.10184.100.camel@denise.theartistscloset.com>
	 <1324627808.10854.6.camel@edumazet-laptop>
	 <1324645986.10184.571.camel@denise.theartistscloset.com>
	 <1324647920.2223.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1324648822.2223.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1324651128.10184.586.camel@denise.theartistscloset.com>
	 <1324652361.2223.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.194]:52352 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754113Ab1LWP05 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2011 10:26:57 -0500
In-Reply-To: <1324652361.2223.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for asking those questions as I had questions about them but fel=
t
I was doing enough spamming of the list.  I am also just in the midst o=
f
gather some of the other information you requested.  I'll respond in
line - John

On Fri, 2011-12-23 at 15:59 +0100, Eric Dumazet wrote:
> Le vendredi 23 d=C3=A9cembre 2011 =C3=A0 09:38 -0500, John A. Sulliva=
n III a
> =C3=A9crit :
>=20
> > Thanks very much, Eric.  gso and gso only was enabled but disabling=
 it
> > does not seem to have solved the problem when I activate netem:
> >=20
>=20
> And your kernel version is ?
root@testswitch01:~# uname -a
Linux testswitch01 2.6.32-5-686 #1 SMP Mon Oct 3 04:15:24 UTC 2011 i686
GNU/Linux

This is Debian Squeeze i386

As described, I'm running two netcats - one going to the default queue
along with the pings and the other going to a different queue.
>=20
> > root@testswitch01:~# ./tcplay
> > root@testswitch01:~# man ethtool
> > root@testswitch01:~# ethtool -k eth1
> > Offload parameters for eth1:
> > rx-checksumming: on
> > tx-checksumming: on
> > scatter-gather: on
> > tcp-segmentation-offload: off
> > udp-fragmentation-offload: off
> > generic-segmentation-offload: on
> > generic-receive-offload: off
> > large-receive-offload: off
> > ntuple-filters: off
> > receive-hashing: off
> > root@testswitch01:~# ethtool -K eth1 gso off
> > root@testswitch01:~# ethtool -k eth1
> > Offload parameters for eth1:
> > rx-checksumming: on
> > tx-checksumming: on
> > scatter-gather: on
> > tcp-segmentation-offload: off
> > udp-fragmentation-offload: off
> > generic-segmentation-offload: off
> > generic-receive-offload: off
> > large-receive-offload: off
> > ntuple-filters: off
> > receive-hashing: off
> > ip ro flush cache
> >=20
> > 64 bytes from 192.168.223.84: icmp_req=3D16 ttl=3D64 time=3D42.6 ms
> > 64 bytes from 192.168.223.84: icmp_req=3D17 ttl=3D64 time=3D39.1 ms
> > 64 bytes from 192.168.223.84: icmp_req=3D18 ttl=3D64 time=3D45.5 ms
> > 64 bytes from 192.168.223.84: icmp_req=3D19 ttl=3D64 time=3D406 ms
> > 64 bytes from 192.168.223.84: icmp_req=3D20 ttl=3D64 time=3D919 ms
> > 64 bytes from 192.168.223.84: icmp_req=3D21 ttl=3D64 time=3D920 ms
> > 64 bytes from 192.168.223.84: icmp_req=3D22 ttl=3D64 time=3D1013 ms
> > 64 bytes from 192.168.223.84: icmp_req=3D23 ttl=3D64 time=3D1158 ms
> > 64 bytes from 192.168.223.84: icmp_req=3D24 ttl=3D64 time=3D1521 ms
> > 64 bytes from 192.168.223.84: icmp_req=3D25 ttl=3D64 time=3D1915 ms
> > 64 bytes from 192.168.223.84: icmp_req=3D26 ttl=3D64 time=3D2371 ms
> > 64 bytes from 192.168.223.84: icmp_req=3D27 ttl=3D64 time=3D2797 ms
> > 64 bytes from 192.168.223.84: icmp_req=3D28 ttl=3D64 time=3D3161 ms
> > 64 bytes from 192.168.223.84: icmp_req=3D29 ttl=3D64 time=3D3162 ms
> > 64 bytes from 192.168.223.84: icmp_req=3D30 ttl=3D64 time=3D3163 ms
> >=20
> > Just in case something is amiss in my methodology, I have four ssh
> > sessions open to the test firewall; ssh is in a separate prioritize=
d
> > queue.  In one session I run:
> > 	ping 192.168.223.84
> > Then, in another, I do:
> > 	nc 192.168.223.100 443 >/dev/null - this should go into a non-defa=
ult,
>=20
> So you _receive_ trafic ?
Yes
>=20
> Are you aware you dont have SFQ in your ingress setup, only egress  ?
Yes.  This is a problem I have with netem on ingress traffic.  I use th=
e
filter on ffff: to redirect to ifb0 for the ingress traffic shaping.  I
cannot figure out a way to redirect a second time to ifb1 for the netem
qdisc.  I tried putting two action mirred statements in the filter but
that did not work.  Unlike eth1, I cannot attach a filter further down
the ifb0 hfsc hierarchy because one can't redirect one ifb into another
ifb.  Thus, the only way I could figure out how to do inbound netem was
to replace the terminal qdisc with netem rather than SFQ.  I'd love to
be able to do that differently.  I tried attaching netem to the SFQ but
that failed (I assume because SFQ is classless) and I tried the other
way around, attaching SFQ to netem since you mentioned netem could take
a class but that did not work either.
>=20
> > prioritized queue.
> > Pings are OK at this point.
> > Then, in a third, I do:
> > 	nc 192.168.223.100 80 >/dev/null - this goes into the default queu=
e,
>=20
> same here ?
Yes.
>=20
> > the same as ping, and is when the trouble starts.
> >=20
> > I did alter the queue lengths in a recommendation from Dave Taht.  =
Here
> > is my current script with netem:
> >=20
> > tc qdisc add dev eth1 root handle 1: hfsc default 20
> > tc class add dev eth1 parent 1: classid 1:1 hfsc sc rate 1490kbit u=
l
> > rate 1490kbit
> > tc class add dev eth1 parent 1:1 classid 1:20 hfsc rt rate 400kbit =
ls
> > rate 200kbit
> > tc qdisc add dev eth1 parent 1:20 handle 1201 sfq perturb 60 limit =
30
> > tc class add dev eth1 parent 1:1 classid 1:10 hfsc rt umax 16kbit d=
max
> > 50ms rate 200kbit ls rate 1000kbit
> > tc qdisc add dev eth1 parent 1:10 handle 1101 sfq perturb 60 limit =
30
> > tc class add dev eth1 parent 1:1 classid 1:30 hfsc rt umax 1514b dm=
ax
> > 20ms rate 20kbit
> > tc qdisc add dev eth1 parent 1:30 handle 1301 sfq perturb 60 limit =
30
> > iptables -t mangle -A POSTROUTING -p 6 --syn --dport 443 -j CONNMAR=
K
> > --set-mark 0x10
> > iptables -t mangle -A PREROUTING -p 6 --syn --dport 822 -j CONNMARK
> > --set-mark 0x11
> > iptables -t mangle -A POSTROUTING -o eth1 -p 6 -j CONNMARK
> > --restore-mark
> > modprobe ifb
> > ifconfig ifb0 up
> > ifconfig ifb1 up
> > tc qdisc add dev ifb0 root handle 1: hfsc default 20
> > tc class add dev ifb0 parent 1: classid 1:1 hfsc sc rate 1490kbit u=
l
> > rate 1490kbit
> > tc class add dev ifb0 parent 1:1 classid 1:20 hfsc rt rate 400kbit =
ls
> > rate 200kbit
> > tc qdisc add dev ifb0 parent 1:20 handle 1201 netem delay 25ms 5ms
> > distribution normal loss 0.1% 30%
> > tc class add dev ifb0 parent 1:1 classid 1:10 hfsc rt umax 16kbit d=
max
> > 50ms rate 200kbit ls rate 1000kbit
> > tc qdisc add dev ifb0 parent 1:10 handle 1101 netem delay 25ms 5ms
> > distribution normal loss 0.1% 30%
> > tc class add dev ifb0 parent 1:1 classid 1:30 hfsc rt umax 1514b dm=
ax
> > 20ms rate 20kbit
> > tc qdisc add dev ifb0 parent 1:30 handle 1301 netem delay 25ms 5ms
> > distribution normal loss 0.1% 30%
> > tc filter add dev ifb0 parent 1:0 protocol ip prio 1 handle 6: u32
> > divisor 1
> > tc filter add dev ifb0 parent 1:0 protocol ip prio 1 u32 match ip
> > protocol 6 0xff link 6: offset at 0 mask 0x0f00 shift 6 plus 0 eat
>=20
>=20
> > tc filter add dev ifb0 parent 1:0 protocol ip prio 1 u32 ht 6:0 mat=
ch
> > tcp src 443 0x00ff flowid 1:10
>=20
> why "src 443 0x00ff" ? It should be "src 443 0xffff"
That's what I tried at first but nothing matched the filter.  I assumed
it was because it objected to a value in the dst field so I masked it
off and it worked.
>=20
> > tc filter add dev ifb0 parent 1:0 protocol ip prio 1 u32 ht 6:0 mat=
ch
> > tcp dst 822 0xff00 flowid 1:30
>=20
> same here : "dst 822 0xffff"
Same as above.  No filter matches when using that mask.
>=20
> > tc qdisc add dev ifb1 root handle 2 netem delay 25ms 5ms distributi=
on
> > normal loss 0.1% 30%
> > tc qdisc add dev eth1 ingress
> > tc filter add dev eth1 parent ffff: protocol ip prio 50 u32 match u=
32 0
> > 0 action mirred egress redirect dev ifb0
> > tc filter add dev eth1 parent 1:1 protocol ip prio 1 handle 0x11 fw
> > flowid 1:30
> > tc filter add dev eth1 parent 1:1 protocol ip prio 1 handle 0x10 fw
> > flowid 1:10
> > tc filter add dev eth1 parent 1:1 protocol ip prio 2 u32 match u32 =
0 0
> > flowid 1:20
> > tc filter add dev eth1 parent 1:0 protocol ip prio 1 u32 match u32 =
0 0
> > flowid 1:1 action mirred egress redirect dev ifb1
> > ip link set eth1 txqueuelen 100
> > ip link set ifb1 txqueuelen 100
> > ip link set ifb0 txqueuelen 100
> >=20
> > I'd love to solve this.  Just when I thought I was all finished hav=
ing
> > cracked the multiple filter problem to add netem to hfsc, I hit thi=
s.
> > Thanks again - John
> >=20
>=20
> Add some SFQ to your ingress too...
<grin> how with netem?  Thanks very much again - John
>=20
>=20
>=20
PS - I also manually disabled gro in case that was a problem even thoug=
h
it was showing off already.  It made no difference.
