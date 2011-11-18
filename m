From: =?UTF-8?B?UG96c8OhciBCYWzDoXpz?= <pozsy@uhulinux.hu>
Subject: Re: routing bug?
Date: Fri, 18 Nov 2011 14:23:23 +0100
Message-ID: <4EC65C4B.6050505@uhulinux.hu>
References: <4EC648C9.8080405@uhulinux.hu>	 <alpine.DEB.2.02.1111181346480.17023@aurora> <1321621796.3277.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sven-Haegar Koch <haegar@sdinet.de>,
	Linux-Kernel-Mailinglist <linux-kernel@vger.kernel.org>,
	=?UTF-8?B?VGFtw6FzaSBKw6Fub3M=?= <janusz@uhulinux.hu>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1321621796.3277.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2011-11-18 14:09, Eric Dumazet wrote:
> Le vendredi 18 novembre 2011 =C3=A0 13:48 +0100, Sven-Haegar Koch a =C3=
=A9crit :
>   =20
>> Added netdev list to CC:, there you should have a higher chance of a
>> usefull answer.
>>
>> On Fri, 18 Nov 2011, Pozs=C3=A1r Bal=C3=A1zs wrote:
>>
>>     =20
>>> Hi all,
>>>
>>> I have been struggling with this not easily reproducible issue sinc=
e a while.
>>> I am using linux kernel v3.1.0, and sometimes routing to a few IP a=
ddresses
>>> does not work. What seems to happen is that instead of sending the =
packet to
>>> the gateway, the kernel treats the destination address as local, an=
d tries to
>>> gets its MAC address via ARP.
>>>
>>> For example, now my current IP address is 172.16.1.104/24, the gate=
way is
>>> 172.16.1.254:
>>>
>>> |# ifconfig eth0 eth0      Link encap:Ethernet  HWaddr 00:1B:63:97:=
=46C:DC
>>>            inet addr:172.16.1.104  Bcast:172.16.1.255  Mask:255.255=
=2E255.0
>>>            UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>>>            RX packets:230772 errors:0 dropped:0 overruns:0 frame:0
>>>            TX packets:171013 errors:0 dropped:0 overruns:0 carrier:=
0
>>>            collisions:0 txqueuelen:1000
>>>            RX bytes:191879370 (182.9 Mb)  TX bytes:47173253 (44.9 M=
b)
>>>            Interrupt:17
>>>
>>> # route -n
>>> Kernel IP routing table
>>> Destination     Gateway         Genmask         Flags Metric Ref   =
 Use Iface
>>> 0.0.0.0         172.16.1.254    0.0.0.0         UG    0      0     =
   0 eth0
>>> 172.16.1.0      0.0.0.0         255.255.255.0   U     1      0     =
   0 eth0
>>> |
>>>
>>> I can ping a few addresses, but not 172.16.0.59:
>>>
>>> |# ping -c1 172.16.1.254
>>> PING 172.16.1.254 (172.16.1.254) 56(84) bytes of data.
>>> 64 bytes from 172.16.1.254: icmp_seq=3D1 ttl=3D64 time=3D0.383 ms
>>>
>>> --- 172.16.1.254 ping statistics ---
>>> 1 packets transmitted, 1 received, 0% packet loss, time 0ms
>>> rtt min/avg/max/mdev =3D 0.383/0.383/0.383/0.000 ms
>>> root@pozsybook:~# ping -c1 172.16.0.1
>>> PING 172.16.0.1 (172.16.0.1) 56(84) bytes of data.
>>> 64 bytes from 172.16.0.1: icmp_seq=3D1 ttl=3D63 time=3D5.54 ms
>>>
>>> --- 172.16.0.1 ping statistics ---
>>> 1 packets transmitted, 1 received, 0% packet loss, time 0ms
>>> rtt min/avg/max/mdev =3D 5.545/5.545/5.545/0.000 ms
>>> root@pozsybook:~# ping -c1 172.16.0.2
>>> PING 172.16.0.2 (172.16.0.2) 56(84) bytes of data.
>>> 64 bytes from 172.16.0.2: icmp_seq=3D1 ttl=3D62 time=3D7.92 ms
>>>
>>> --- 172.16.0.2 ping statistics ---
>>> 1 packets transmitted, 1 received, 0% packet loss, time 0ms
>>> rtt min/avg/max/mdev =3D 7.925/7.925/7.925/0.000 ms
>>> root@pozsybook:~# ping -c1 172.16.0.59
>>> PING 172.16.0.59 (172.16.0.59) 56(84) bytes of data.
>>>  From 172.16.1.104 icmp_seq=3D1 Destination Host Unreachable
>>>
>>> --- 172.16.0.59 ping statistics ---
>>> 1 packets transmitted, 0 received, +1 errors, 100% packet loss, tim=
e 0ms
>>> |
>>>
>>> When trying to ping 172.16.0.59, I can see in tcpdump that an ARP r=
eq was
>>> sent:
>>>
>>> |# tcpdump -n -i eth0|grep ARP
>>> tcpdump: verbose output suppressed, use -v or -vv for full protocol=
 decode
>>> listening on eth0, link-type EN10MB (Ethernet), capture size 96 byt=
es
>>> 15:25:16.671217 ARP, Request who-has 172.16.0.59 tell 172.16.1.104,=
 length 28
>>> |
>>>
>>> and /proc/net/arp has an incomplete entry for 172.16.0.59:
>>>
>>> |# grep 172.16.0.59 /proc/net/arp
>>>
>>> 172.16.0.59      0x1         0x0         00:00:00:00:00:00     *   =
     eth0
>>> |
>>>
>>> Please note, that 172.16.0.59 /is/ accessible from this LAN from ot=
her
>>> computers.
>>>
>>>
>>> Does anyone have any idea of what's going on? Thanks,
>>>
>>>
>>> Balazs Pozsar
>>>
>>> ps: I think it is related to this one: https://lkml.org/lkml/2011/1=
1/16/292
>>>
>>> --
>>>       =20
> Could you send us result of :
>
> ip route get 172.16.0.59
> ip route list cache match 172.16.0.59
>   =20

I did not tell you in my first mail, that some times different hosts ar=
e=20
reachable and unreachable. I will try to not confuse you :)
As of now, 172.16.0.59 is OK, and 172.16.0.37 is NOT OK.
Also, 172.16.0.64 is OK now, and 172.16.0.42 is NOT OK now.

The two commands you have requested give the following output for these=
=20
IP addresses:

These are OK:

# ip route get 172.16.0.64
172.16.0.64 via 172.16.1.254 dev eth0  src 172.16.1.22
     cache
# ip route get 172.16.0.59
172.16.0.59 via 172.16.1.254 dev eth0  src 172.16.1.22
     cache

These are NOT OK:

# ip route get 172.16.0.37
172.16.0.37 dev eth0  src 172.16.1.22
     cache <redirected>  ipid 0x97a4
# ip route get 172.16.0.42
172.16.0.42 dev eth0  src 172.16.1.22
     cache <redirected>  ipid 0x0d21

These are OK:

# ip route list cache match 172.16.0.59
172.16.0.59 via 172.16.1.254 dev eth0  src 172.16.1.22
     cache
# ip route list cache match 172.16.0.64
172.16.0.64 via 172.16.1.254 dev eth0  src 172.16.1.22
     cache

These are NOT OK:

# ip route list cache match 172.16.0.37
172.16.0.37 dev eth0  src 172.16.1.22
     cache <redirected>  ipid 0x97a4
172.16.0.37 from 172.16.1.22 dev eth0
     cache <redirected>  ipid 0x97a4
172.16.0.37 from 172.16.1.22 dev eth0
     cache <redirected>  ipid 0x97a4
# ip route list cache match 172.16.0.42
172.16.0.42 dev eth0  src 172.16.1.22
     cache <redirected>  ipid 0x0d21
172.16.0.42 from 172.16.1.22 dev eth0
     cache <redirected>  ipid 0x0d21


How can I fix this?

Thanks!
