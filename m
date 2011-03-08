From: Weiping Pan <panweiping3@gmail.com>
Subject: Re: bonding can't change to another slave if you ifdown the active
 slave
Date: Tue, 08 Mar 2011 14:52:52 +0800
Message-ID: <4D75D244.9070409@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:46968 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751314Ab1CHG4t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2011 01:56:49 -0500
Received: by vws12 with SMTP id 12so4440245vws.19
        for <netdev@vger.kernel.org>; Mon, 07 Mar 2011 22:56:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 03/08/2011 05:15 AM, Nicolas de Peslo=FCan wrote:
> Le 07/03/2011 04:13, Weiping Pan a =E9crit :
>> On 03/05/2011 09:49 PM, Nicolas de Peslo=FCan wrote:
>>> Le 05/03/2011 03:53, Andy Gospodarek a =E9crit :
>>>> On Fri, Mar 04, 2011 at 10:15:17AM +0800, Weiping Pan wrote:
>>>>> Hi,
>>>>>
>>>>> I'm doing some Linux bonding driver test, and I find a problem in
>>>>> balance-rr mode.
>>>>> That's it can't change to another slave if you ifdown the active=20
>>>>> slave.
>>>>> Any comments are warmly welcomed!
>>>>>
>>>>> regards
>>>>> Weiping Pan
>>>>>
>>>>> My host is Fedora 14, and I install VirtualBox (4.0.2), and enabl=
e 4
>>>>> nics for the guest system.
>>>>
>>>> Does this mean you are passing 4 NICs from your host to your guest
>>>> (maybe via direct pci-device assignment to the guest) or are you
>>>> creating 4 virtual devices on the host that are in a bridge group=20
>>>> on the
>>>> host?
>>>
>>> VirtualBox does not allow assignment of pci-device to the guest. Th=
e
>>> network interfaces on the guest are pure virtual one, with several
>>> modes available. In order to help you trouble shooting this problem=
,
>>> we need to know the mode form each of the virtual interfaces. Possi=
ble
>>> modes are NAT, bridged, internal-network, and host-only-network.
>>>
>>> Please provide the output of the following command:
>>>
>>> VBoxManage showvminfo <your-vm-uuid> | grep ^NIC
>>>
>>> To display your vm uuid, use the following command:
>>>
>>> VBoxManage list vms
>> [root@localhost ~]# VBoxManage showvminfo
>> 67b83c47-0ee2-46bc-b0ff-e0eb43edc1c2 |grep ^NIC
>> NIC 1: MAC: 0800270481A8, Attachment: Bridged Interface 'eth0', Cabl=
e
>> connected: on, Trace: off (file: none), Type: 82540EM, Reported spee=
d: 0
>> Mbps, Boot priority: 0
>> NIC 2: MAC: 08002778F641, Attachment: Bridged Interface 'eth0', Cabl=
e
>> connected: on, Trace: off (file: none), Type: 82540EM, Reported spee=
d: 0
>> Mbps, Boot priority: 0
>> NIC 3: MAC: 080027C408BA, Attachment: Bridged Interface 'eth0', Cabl=
e
>> connected: on, Trace: off (file: none), Type: 82540EM, Reported spee=
d: 0
>> Mbps, Boot priority: 0
>> NIC 4: MAC: 080027DB339A, Attachment: Bridged Interface 'eth0', Cabl=
e
>> connected: on, Trace: off (file: none), Type: 82540EM, Reported spee=
d: 0
>> Mbps, Boot priority: 0
>> NIC 5: disabled
>> NIC 6: disabled
>> NIC 7: disabled
>> NIC 8: disabled
>>
>> And when guest starts, i find that:
>> NIC 1: eth7
>> NIC 2: eth6
>> NIC 3: eth9
>> NIC 4: eth8
>
> Would you mind testing with "Host-only Interface 'vboxnet0'", instead=
=20
> of "Bridged Interface 'eth0'"?
>
> All the bonding tests I do use this setup and the link failure=20
> detection work well.
>
>     Nicolas.
ok, I use "Host-only mode" and get



an conclusion, that if the first enslaved nic is pulled out, bonding=20
can't handle well.

=46irst test.
I first enslave eth6, then pull it out, bonding doesn't work.
on host,
[root@localhost ~]# VBoxManage -v
4.0.2r69518

[root@localhost ~]# VBoxManage showvminfo=20
67b83c47-0ee2-46bc-b0ff-e0eb43edc1c2|grep ^NIC
NIC 1:           MAC: 0800270481A8, Attachment: Host-only Interface=20
'vboxnet0', Cable connected: on, Trace: off (file: none), Type: 82540EM=
,=20
Reported speed: 0 Mbps, Boot priority: 0
NIC 2:           MAC: 08002778F641, Attachment: Host-only Interface=20
'vboxnet0', Cable connected: on, Trace: off (file: none), Type: 82540EM=
,=20
Reported speed: 0 Mbps, Boot priority: 0
NIC 3:           MAC: 080027C408BA, Attachment: Host-only Interface=20
'vboxnet0', Cable connected: on, Trace: off (file: none), Type: 82540EM=
,=20
Reported speed: 0 Mbps, Boot priority: 0
NIC 4:           MAC: 080027DB339A, Attachment: Host-only Interface=20
'vboxnet0', Cable connected: on, Trace: off (file: none), Type: 82540EM=
,=20
Reported speed: 0 Mbps, Boot priority: 0
NIC 5:           disabled
NIC 6:           disabled
NIC 7:           disabled
NIC 8:           disabled

[root@localhost ~]# ifconfig vboxnet0
vboxnet0  Link encap:Ethernet  HWaddr 0A:00:27:00:00:00
           inet addr:192.168.56.1  Bcast:192.168.56.255  Mask:255.255.2=
55.0
           inet6 addr: fe80::800:27ff:fe00:0/64 Scope:Link
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
           TX packets:268 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:0 (0.0 b)  TX bytes:52456 (51.2 KiB)

restart guest,
[root@localhost ~]# uname -a
Linux localhost.localdomain 2.6.35.11-83.fc14.i686 #1 SMP Mon Feb 7=20
07:04:18 UTC 2011 i686 i686 i386 GNU/Linux

[root@localhost ~]# ifconfig
eth6      Link encap:Ethernet  HWaddr 08:00:27:78:F6:41
           inet addr:192.168.56.101  Bcast:192.168.56.255 =20
Mask:255.255.255.0
           inet6 addr: fe80::a00:27ff:fe78:f641/64 Scope:Link
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:14 errors:0 dropped:0 overruns:0 frame:0
           TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:6772 (6.6 KiB)  TX bytes:1152 (1.1 KiB)

eth7      Link encap:Ethernet  HWaddr 08:00:27:04:81:A8
           inet addr:192.168.56.102  Bcast:192.168.56.255 =20
Mask:255.255.255.0
           inet6 addr: fe80::a00:27ff:fe04:81a8/64 Scope:Link
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:14 errors:0 dropped:0 overruns:0 frame:0
           TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:6772 (6.6 KiB)  TX bytes:1152 (1.1 KiB)

eth8      Link encap:Ethernet  HWaddr 08:00:27:DB:33:9A
           inet addr:192.168.56.104  Bcast:192.168.56.255 =20
Mask:255.255.255.0
           inet6 addr: fe80::a00:27ff:fedb:339a/64 Scope:Link
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:63 errors:0 dropped:0 overruns:0 frame:0
           TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:19456 (19.0 KiB)  TX bytes:1152 (1.1 KiB)

eth9      Link encap:Ethernet  HWaddr 08:00:27:C4:08:BA
           inet addr:192.168.56.103  Bcast:192.168.56.255 =20
Mask:255.255.255.0
           inet6 addr: fe80::a00:27ff:fec4:8ba/64 Scope:Link
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:63 errors:0 dropped:0 overruns:0 frame:0
           TX packets:8 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:19456 (19.0 KiB)  TX bytes:1152 (1.1 KiB)

lo        Link encap:Local Loopback
           inet addr:127.0.0.1  Mask:255.0.0.0
           inet6 addr: ::1/128 Scope:Host
           UP LOOPBACK RUNNING  MTU:16436  Metric:1
           RX packets:16 errors:0 dropped:0 overruns:0 frame:0
           TX packets:16 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:0
           RX bytes:880 (880.0 b)  TX bytes:880 (880.0 b)

so
NIC 1:           eth7
NIC 2:           eth6
NIC 3:           eth9
NIC 4:           eth8

on guest,
[root@localhost ~]# for i in eth{6..9}; do ifconfig $i down; done
[root@localhost ~]# modprobe bonding mode=3D0 miimon=3D100
[root@localhost ~]# ifconfig bond0 192.168.56.2 netmask 255.255.255.0 u=
p
[root@localhost ~]# ifenslave bond0 eth6
[root@localhost ~]# ifenslave bond0 eth7
[root@localhost ~]# ping 192.168.56.1 -c 5
PING 192.168.56.1 (192.168.56.1) 56(84) bytes of data.
64 bytes from 192.168.56.1: icmp_req=3D1 ttl=3D64 time=3D1.83 ms
64 bytes from 192.168.56.1: icmp_req=3D2 ttl=3D64 time=3D0.149 ms
64 bytes from 192.168.56.1: icmp_req=3D3 ttl=3D64 time=3D0.204 ms
64 bytes from 192.168.56.1: icmp_req=3D4 ttl=3D64 time=3D0.294 ms
64 bytes from 192.168.56.1: icmp_req=3D5 ttl=3D64 time=3D0.412 ms

--- 192.168.56.1 ping statistics ---
5 packets transmitted, 5 received, 0% packet loss, time 4003ms
rtt min/avg/max/mdev =3D 0.149/0.578/1.832/0.633 ms
[root@localhost ~]# arp
Address                  HWtype  HWaddress           Flags=20
Mask            Iface
192.168.56.1             ether   0a:00:27:00:00:00  =20
C                     bond0

on host,
[root@localhost ~]# arp
Address                  HWtype  HWaddress           Flags=20
Mask            Iface
192.168.56.2             ether   08:00:27:78:f6:41  =20
C                     vboxnet0
corerouter.nay.redhat.c  ether   00:1d:45:20:d5:ff  =20
C                     eth0
[root@localhost ~]# VBoxManage controlvm=20
67b83c47-0ee2-46bc-b0ff-e0eb43edc1c2 setlinkstate2 off

[root@localhost ~]# ping 192.168.56.1 -c 5
PING 192.168.56.1 (192.168.56.1) 56(84) bytes of data.
 From 192.168.56.2 icmp_seq=3D2 Destination Host Unreachable
 From 192.168.56.2 icmp_seq=3D3 Destination Host Unreachable
 From 192.168.56.2 icmp_seq=3D4 Destination Host Unreachable
 From 192.168.56.2 icmp_seq=3D5 Destination Host Unreachable

--- 192.168.56.1 ping statistics ---
5 packets transmitted, 0 received, +4 errors, 100% packet loss, time 40=
01ms
pipe 3
[root@localhost ~]# dmesg
[  513.093249] e1000: eth6 NIC Link is Down
[  513.129123] bonding: bond0: link status definitely down for interfac=
e=20
eth6, disabling it
[root@localhost ~]# ip route show
192.168.56.0/24 dev bond0  proto kernel  scope link  src 192.168.56.2
192.168.56.0/24 dev eth7  proto kernel  scope link  src 192.168.56.101 =
=20
metric 1
[root@localhost ~]# ip neigh show
192.168.56.1 dev bond0  FAILED

on host,
[root@localhost ~]# ip route show
192.168.1.0/24 dev eth0  proto kernel  scope link  src 192.168.1.100
192.168.56.0/24 dev vboxnet0  proto kernel  scope link  src 192.168.56.=
1
10.66.64.0/23 dev eth0  proto kernel  scope link  src 10.66.65.228 =20
metric 1
default via 10.66.65.254 dev eth0  proto static
[root@localhost ~]# ip neigh show
192.168.56.2 dev vboxnet0 lladdr 08:00:27:78:f6:41 STALE
10.66.65.254 dev eth0 lladdr 00:1d:45:20:d5:ff REACHABLE


Second test
I first enslave eth6, then pull eth7 out, bonding works well.
on guest,
[root@localhost ~]# modprobe bonding mode=3D0 miimon=3D100
[root@localhost ~]# ifconfig bond0 192.168.56.2 netmask 255.255.255.0 u=
p
[root@localhost ~]# ifenslave bond0 eth6
[root@localhost ~]# ifenslave bond0 eth7
[root@localhost ~]# ping 192.168.56.1 -c 5
PING 192.168.56.1 (192.168.56.1) 56(84) bytes of data.
64 bytes from 192.168.56.1: icmp_req=3D1 ttl=3D64 time=3D0.902 ms
64 bytes from 192.168.56.1: icmp_req=3D2 ttl=3D64 time=3D0.260 ms
64 bytes from 192.168.56.1: icmp_req=3D3 ttl=3D64 time=3D0.237 ms
64 bytes from 192.168.56.1: icmp_req=3D4 ttl=3D64 time=3D0.335 ms
64 bytes from 192.168.56.1: icmp_req=3D5 ttl=3D64 time=3D0.170 ms

--- 192.168.56.1 ping statistics ---
5 packets transmitted, 5 received, 0% packet loss, time 4001ms
rtt min/avg/max/mdev =3D 0.170/0.380/0.902/0.267 ms

[root@localhost ~]# dmesg
[ 1162.524825] bonding: MII link monitoring set to 100 ms
[ 1165.845586] ADDRCONF(NETDEV_UP): bond0: link is not ready
[ 1174.505912] e1000: eth6 NIC Link is Up 1000 Mbps Full Duplex, Flow=20
Control: RX
[ 1174.512372] bonding: bond0: enslaving eth6 as an active interface=20
with an up link.
[ 1174.512897] ADDRCONF(NETDEV_CHANGE): bond0: link becomes ready
[ 1178.857322] ICMPv6 NA: someone advertises our address=20
fe80:0000:0000:0000:0a00:27ff:fe78:f641 on bond0!
[ 1178.858649] e1000: eth7 NIC Link is Up 1000 Mbps Full Duplex, Flow=20
Control: RX
[ 1178.861391] bonding: bond0: enslaving eth7 as an active interface=20
with an up link.
[ 1184.682110] bond0: no IPv6 routers present

on host,
[root@localhost ~]# VBoxManage controlvm=20
67b83c47-0ee2-46bc-b0ff-e0eb43edc1c2 setlinkstate1 off

on guest,
[root@localhost ~]# ping 192.168.56.1 -c 5
PING 192.168.56.1 (192.168.56.1) 56(84) bytes of data.
64 bytes from 192.168.56.1: icmp_req=3D1 ttl=3D64 time=3D0.599 ms
64 bytes from 192.168.56.1: icmp_req=3D2 ttl=3D64 time=3D0.150 ms
64 bytes from 192.168.56.1: icmp_req=3D3 ttl=3D64 time=3D0.224 ms
64 bytes from 192.168.56.1: icmp_req=3D4 ttl=3D64 time=3D0.154 ms
64 bytes from 192.168.56.1: icmp_req=3D5 ttl=3D64 time=3D0.189 ms

--- 192.168.56.1 ping statistics ---
5 packets transmitted, 5 received, 0% packet loss, time 4000ms
rtt min/avg/max/mdev =3D 0.150/0.263/0.599/0.170 ms
[root@localhost ~]# dmesg
[ 1281.421231] e1000: eth7 NIC Link is Down
[ 1281.492178] bonding: bond0: link status definitely down for interfac=
e=20
eth7, disabling it


many thanks
Weiping Pan





