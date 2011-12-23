From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: Re: SFQ on HFSC leaf does not seem to work
Date: Fri, 23 Dec 2011 09:38:48 -0500
Message-ID: <1324651128.10184.586.camel@denise.theartistscloset.com>
References: <1324620022.10184.100.camel@denise.theartistscloset.com>
	 <1324627808.10854.6.camel@edumazet-laptop>
	 <1324645986.10184.571.camel@denise.theartistscloset.com>
	 <1324647920.2223.14.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1324648822.2223.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.194]:65445 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753951Ab1LWOiz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2011 09:38:55 -0500
In-Reply-To: <1324648822.2223.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-12-23 at 15:00 +0100, Eric Dumazet wrote:
> Le vendredi 23 d=C3=A9cembre 2011 =C3=A0 14:45 +0100, Eric Dumazet a =
=C3=A9crit :
>=20
> > 1) What kernel version do you use ?
> >=20
> > 2) How many concurrent flows are running (number of netperf/netcat)
> >=20
> > 3) Remind that 'perturb xxx' introduces a temporary doubling of the
> > number of flows.
> >=20
> > 4) Had you disabled tso on eth1 ?
> >    (If not, you might send 64Kbytes packets, and at 400kbit, they t=
ake a
> > lot of time to transmit : more than one second ...)
> >=20
> >=20
>=20
> Using your script on net-next, (only using eth3 instead of eth1) and
>=20
> ethtool -K eth3 tso off
> ethtool -K eth3 gso off
> ip ro flush cache
>=20
> one ssh : dd if=3D/dev/zero | ssh 192.168.0.1 "dd of=3D/dev/null"
> my ping is quite good :
>=20
>=20
> $ ping -c 20 192.168.0.1
> PING 192.168.0.1 (192.168.0.1) 56(84) bytes of data.
> 2011/11/23 14:57:01.106 64 bytes from 192.168.0.1: icmp_seq=3D1 ttl=3D=
64 time=3D59.4 ms
> 2011/11/23 14:57:02.121 64 bytes from 192.168.0.1: icmp_seq=3D2 ttl=3D=
64 time=3D72.7 ms
> 2011/11/23 14:57:03.109 64 bytes from 192.168.0.1: icmp_seq=3D3 ttl=3D=
64 time=3D60.3 ms
> 2011/11/23 14:57:04.108 64 bytes from 192.168.0.1: icmp_seq=3D4 ttl=3D=
64 time=3D57.8 ms
> 2011/11/23 14:57:05.115 64 bytes from 192.168.0.1: icmp_seq=3D5 ttl=3D=
64 time=3D62.6 ms
> 2011/11/23 14:57:06.116 64 bytes from 192.168.0.1: icmp_seq=3D6 ttl=3D=
64 time=3D62.6 ms
> 2011/11/23 14:57:07.112 64 bytes from 192.168.0.1: icmp_seq=3D7 ttl=3D=
64 time=3D57.6 ms
> 2011/11/23 14:57:08.127 64 bytes from 192.168.0.1: icmp_seq=3D8 ttl=3D=
64 time=3D70.9 ms
> 2011/11/23 14:57:09.123 64 bytes from 192.168.0.1: icmp_seq=3D9 ttl=3D=
64 time=3D65.4 ms
> 2011/11/23 14:57:10.113 64 bytes from 192.168.0.1: icmp_seq=3D10 ttl=3D=
64 time=3D53.5 ms
> 2011/11/23 14:57:11.127 64 bytes from 192.168.0.1: icmp_seq=3D11 ttl=3D=
64 time=3D66.7 ms
> 2011/11/23 14:57:12.129 64 bytes from 192.168.0.1: icmp_seq=3D12 ttl=3D=
64 time=3D67.4 ms
> 2011/11/23 14:57:13.119 64 bytes from 192.168.0.1: icmp_seq=3D13 ttl=3D=
64 time=3D56.3 ms
> 2011/11/23 14:57:14.127 64 bytes from 192.168.0.1: icmp_seq=3D14 ttl=3D=
64 time=3D64.0 ms
> 2011/11/23 14:57:15.116 64 bytes from 192.168.0.1: icmp_seq=3D15 ttl=3D=
64 time=3D51.9 ms
> 2011/11/23 14:57:16.127 64 bytes from 192.168.0.1: icmp_seq=3D16 ttl=3D=
64 time=3D61.2 ms
> 2011/11/23 14:57:17.127 64 bytes from 192.168.0.1: icmp_seq=3D17 ttl=3D=
64 time=3D60.4 ms
> 2011/11/23 14:57:18.135 64 bytes from 192.168.0.1: icmp_seq=3D18 ttl=3D=
64 time=3D68.2 ms
> 2011/11/23 14:57:19.137 64 bytes from 192.168.0.1: icmp_seq=3D19 ttl=3D=
64 time=3D69.1 ms
> 2011/11/23 14:57:20.136 64 bytes from 192.168.0.1: icmp_seq=3D20 ttl=3D=
64 time=3D67.0 ms
>=20
> --- 192.168.0.1 ping statistics ---
> 20 packets transmitted, 20 received, 0% packet loss, time 19022ms
> rtt min/avg/max/mdev =3D 51.909/62.796/72.751/5.579 ms
>=20
> $ tc -s -d class show dev eth3
> class hfsc 1: root=20
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)=20
>  backlog 0b 0p requeues 0=20
>  period 0 level 2=20
>=20
> class hfsc 1:1 parent 1: sc m1 0bit d 0us m2 1490Kbit ul m1 0bit d 0u=
s m2 1490Kbit=20
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)=20
>  backlog 0b 0p requeues 0=20
>  period 69 work 38559740 bytes level 1=20
>=20
> class hfsc 1:10 parent 1:1 leaf 1101: rt m1 327680bit d 50.0ms m2 200=
000bit ls m1 0bit d 0us m2 1000Kbit=20
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)=20
>  backlog 0b 0p requeues 0=20
>  period 0 level 0=20
>=20
> class hfsc 1:20 parent 1:1 leaf 1201: rt m1 0bit d 0us m2 400000bit l=
s m1 0bit d 0us m2 200000bit=20
>  Sent 38587058 bytes 27022 pkt (dropped 0, overlimits 0 requeues 0)=20
>  backlog 0b 19p requeues 0=20
>  period 69 work 38559740 bytes rtwork 10358780 bytes level 0=20
>=20
> class hfsc 1:30 parent 1:1 leaf 1301: rt m1 605600bit d 20.0ms m2 200=
00bit=20
>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)=20
>  backlog 0b 0p requeues 0=20
>  period 0 level 0=20
>=20
> class sfq 1201:f7 parent 1201:=20
>  (dropped 0, overlimits 0 requeues 0)=20
>  backlog 25804b 18p requeues 0=20
>  allot -1336=20
>=20
>=20
> Hmm... we probably could fill hfsc class information with non null by=
tes backlog...
> I'll take a look.
>=20
>=20
>=20
Thanks very much, Eric.  gso and gso only was enabled but disabling it
does not seem to have solved the problem when I activate netem:

root@testswitch01:~# ./tcplay
root@testswitch01:~# man ethtool
root@testswitch01:~# ethtool -k eth1
Offload parameters for eth1:
rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp-segmentation-offload: off
udp-fragmentation-offload: off
generic-segmentation-offload: on
generic-receive-offload: off
large-receive-offload: off
ntuple-filters: off
receive-hashing: off
root@testswitch01:~# ethtool -K eth1 gso off
root@testswitch01:~# ethtool -k eth1
Offload parameters for eth1:
rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp-segmentation-offload: off
udp-fragmentation-offload: off
generic-segmentation-offload: off
generic-receive-offload: off
large-receive-offload: off
ntuple-filters: off
receive-hashing: off
ip ro flush cache

64 bytes from 192.168.223.84: icmp_req=3D16 ttl=3D64 time=3D42.6 ms
64 bytes from 192.168.223.84: icmp_req=3D17 ttl=3D64 time=3D39.1 ms
64 bytes from 192.168.223.84: icmp_req=3D18 ttl=3D64 time=3D45.5 ms
64 bytes from 192.168.223.84: icmp_req=3D19 ttl=3D64 time=3D406 ms
64 bytes from 192.168.223.84: icmp_req=3D20 ttl=3D64 time=3D919 ms
64 bytes from 192.168.223.84: icmp_req=3D21 ttl=3D64 time=3D920 ms
64 bytes from 192.168.223.84: icmp_req=3D22 ttl=3D64 time=3D1013 ms
64 bytes from 192.168.223.84: icmp_req=3D23 ttl=3D64 time=3D1158 ms
64 bytes from 192.168.223.84: icmp_req=3D24 ttl=3D64 time=3D1521 ms
64 bytes from 192.168.223.84: icmp_req=3D25 ttl=3D64 time=3D1915 ms
64 bytes from 192.168.223.84: icmp_req=3D26 ttl=3D64 time=3D2371 ms
64 bytes from 192.168.223.84: icmp_req=3D27 ttl=3D64 time=3D2797 ms
64 bytes from 192.168.223.84: icmp_req=3D28 ttl=3D64 time=3D3161 ms
64 bytes from 192.168.223.84: icmp_req=3D29 ttl=3D64 time=3D3162 ms
64 bytes from 192.168.223.84: icmp_req=3D30 ttl=3D64 time=3D3163 ms

Just in case something is amiss in my methodology, I have four ssh
sessions open to the test firewall; ssh is in a separate prioritized
queue.  In one session I run:
	ping 192.168.223.84
Then, in another, I do:
	nc 192.168.223.100 443 >/dev/null - this should go into a non-default,
prioritized queue.
Pings are OK at this point.
Then, in a third, I do:
	nc 192.168.223.100 80 >/dev/null - this goes into the default queue,
the same as ping, and is when the trouble starts.

I did alter the queue lengths in a recommendation from Dave Taht.  Here
is my current script with netem:

tc qdisc add dev eth1 root handle 1: hfsc default 20
tc class add dev eth1 parent 1: classid 1:1 hfsc sc rate 1490kbit ul
rate 1490kbit
tc class add dev eth1 parent 1:1 classid 1:20 hfsc rt rate 400kbit ls
rate 200kbit
tc qdisc add dev eth1 parent 1:20 handle 1201 sfq perturb 60 limit 30
tc class add dev eth1 parent 1:1 classid 1:10 hfsc rt umax 16kbit dmax
50ms rate 200kbit ls rate 1000kbit
tc qdisc add dev eth1 parent 1:10 handle 1101 sfq perturb 60 limit 30
tc class add dev eth1 parent 1:1 classid 1:30 hfsc rt umax 1514b dmax
20ms rate 20kbit
tc qdisc add dev eth1 parent 1:30 handle 1301 sfq perturb 60 limit 30
iptables -t mangle -A POSTROUTING -p 6 --syn --dport 443 -j CONNMARK
--set-mark 0x10
iptables -t mangle -A PREROUTING -p 6 --syn --dport 822 -j CONNMARK
--set-mark 0x11
iptables -t mangle -A POSTROUTING -o eth1 -p 6 -j CONNMARK
--restore-mark
modprobe ifb
ifconfig ifb0 up
ifconfig ifb1 up
tc qdisc add dev ifb0 root handle 1: hfsc default 20
tc class add dev ifb0 parent 1: classid 1:1 hfsc sc rate 1490kbit ul
rate 1490kbit
tc class add dev ifb0 parent 1:1 classid 1:20 hfsc rt rate 400kbit ls
rate 200kbit
tc qdisc add dev ifb0 parent 1:20 handle 1201 netem delay 25ms 5ms
distribution normal loss 0.1% 30%
tc class add dev ifb0 parent 1:1 classid 1:10 hfsc rt umax 16kbit dmax
50ms rate 200kbit ls rate 1000kbit
tc qdisc add dev ifb0 parent 1:10 handle 1101 netem delay 25ms 5ms
distribution normal loss 0.1% 30%
tc class add dev ifb0 parent 1:1 classid 1:30 hfsc rt umax 1514b dmax
20ms rate 20kbit
tc qdisc add dev ifb0 parent 1:30 handle 1301 netem delay 25ms 5ms
distribution normal loss 0.1% 30%
tc filter add dev ifb0 parent 1:0 protocol ip prio 1 handle 6: u32
divisor 1
tc filter add dev ifb0 parent 1:0 protocol ip prio 1 u32 match ip
protocol 6 0xff link 6: offset at 0 mask 0x0f00 shift 6 plus 0 eat
tc filter add dev ifb0 parent 1:0 protocol ip prio 1 u32 ht 6:0 match
tcp src 443 0x00ff flowid 1:10
tc filter add dev ifb0 parent 1:0 protocol ip prio 1 u32 ht 6:0 match
tcp dst 822 0xff00 flowid 1:30
tc qdisc add dev ifb1 root handle 2 netem delay 25ms 5ms distribution
normal loss 0.1% 30%
tc qdisc add dev eth1 ingress
tc filter add dev eth1 parent ffff: protocol ip prio 50 u32 match u32 0
0 action mirred egress redirect dev ifb0
tc filter add dev eth1 parent 1:1 protocol ip prio 1 handle 0x11 fw
flowid 1:30
tc filter add dev eth1 parent 1:1 protocol ip prio 1 handle 0x10 fw
flowid 1:10
tc filter add dev eth1 parent 1:1 protocol ip prio 2 u32 match u32 0 0
flowid 1:20
tc filter add dev eth1 parent 1:0 protocol ip prio 1 u32 match u32 0 0
flowid 1:1 action mirred egress redirect dev ifb1
ip link set eth1 txqueuelen 100
ip link set ifb1 txqueuelen 100
ip link set ifb0 txqueuelen 100

I'd love to solve this.  Just when I thought I was all finished having
cracked the multiple filter problem to add netem to hfsc, I hit this.
Thanks again - John
