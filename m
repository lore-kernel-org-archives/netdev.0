From: Rob Townley <rob.townley@gmail.com>
Subject: Re: [olug] Ping Is Broken
Date: Sun, 22 Nov 2009 20:10:16 +0000
Message-ID: <7e84ed60911221210y669695cdxcabeebe6b38f74ec@mail.gmail.com>
References: <7e84ed60910090316ne9224fat81d9c79c58fc713b@mail.gmail.com>
	 <7e84ed60910090934y2a0d422cr158aa8d15e452f97@mail.gmail.com>
	 <7e84ed60910090944q5c66ea0w63ed55a72482bf2f@mail.gmail.com>
	 <006a01ca4a10$a1a4ba60$e4ee2f20$@com>
	 <7e84ed60910111032s2f03b6dew5c756895872e1a0c@mail.gmail.com>
	 <000301ca4b13$60a26e00$21e74a00$@com>
	 <7e84ed60910121115i30ec3512uce46cf0ff3b3954c@mail.gmail.com>
	 <Pine.LNX.4.64.0910121934360.26068@pakmon.pakint.net>
Reply-To: Rob.Townley@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Omaha Linux User Group <olug@olug.org>,
	Brian Haley <brian.haley@hp.com>, netdev@vger.kernel.org,
	jarkao2@gmail.com
To: olug4mgm@paktronix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:35456 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753770AbZKVUKN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Nov 2009 15:10:13 -0500
Received: by bwz27 with SMTP id 27so4534724bwz.21
        for <netdev@vger.kernel.org>; Sun, 22 Nov 2009 12:10:18 -0800 (PST)
In-Reply-To: <Pine.LNX.4.64.0910121934360.26068@pakmon.pakint.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 13, 2009 at 12:50 AM, Matthew G. Marsh
<olug4mgm@paktronix.com> wrote:
>
> </delurk>
>
> On Mon, 12 Oct 2009, Rob Townley wrote:
>
>> On Mon, Oct 12, 2009 at 3:09 AM, Aric Aasgaard <aric@omahax.com> wro=
te:
>>>
>>> The interface isn't on the network your trying to ping.
>>
>> Maybe i don't understand what you are saying, but eth0's ip address =
is
>> 4.3.2.8 and when 4.3.2.8 is passed as the interface, it works. =A0Wh=
en
>> eth0 is passed as the interface name, ping fails. =A0So it isn't a
>> problem with the network or routing rules or routing tables, it is a
>> problem in being able to address a device alias.
>
> Actually - not completely. The main problem is that when you call pin=
g with
> the -I eth0 then you also are invoking your rule 32762 because when t=
he ping
> command goes to use the interface it then runs through the rule set a=
nd as
> 32762 is the lowest rule it is invoked and your ping packet goes out =
through
> eth0 to the default gateway of table nic0:
>
> /sbin/ip route show table nic0
> default via 4.3.2.1 dev eth0
>
> And I suspect that cannot get to the device you want to ping.
>
> On the other hand when you specify -I 4.x.x.x to the ping command the=
n the
> packet goes out from lo0 using that source address and is routed by t=
he
> default rule "from all lookup main" which means it gets routed out th=
e eth1
> interface but with the 4.x address.
>
> Do you see the difference?
>
> What gives this away is the following:
>
> 1: The ping utility is from iputils (Alexey's utility set) and thus b=
ehaves
> according to the policy structure in the kernel which _does_ differen=
tiate
> between IP address assignments and mere network interfaces. Remember =
- the
> IP address DOES NOT belong to an interface and does not even need to =
be
> bound to such in order to function in a Linux kernel.
>
> 2: When you said "All exhibit the issue that ethX can't be used as an
> interface name when the default gateway isn't reached thru ethX."
>
> That told me that you were slightly confusing the way in which -I wor=
ks in
> Alexey's ping utility. It is confusing considering that you must unde=
rstand
> the difference between interface sourcing and ip address sourcing.
>
> In summary -
>
> -I <interface> will use the primary IP address of the named interface=
 AND
> act as though it had been sourced from that interface which triggers =
any
> relevant rules, routes, etal.
>
> -I <IP addr> merely sets the Source address of the packet but then so=
urces
> the packet from lo0 and this would invoke the default routing
>
> Sense?
>
> Let me know. Thanks!!
>
> P.S. I am considering starting work on a second edition as I now am b=
ack
> working in the IT field...
>
> mgm
>
>>> How are you attempting to get from one NIC to the other? Not via th=
e same
>>> switch I hope.
>>
>> Both of these nics in all examples are in the same machine. =A0Some =
have
>> ip_forward =3D 1 and some don't. =A0All exhibit the issue that ethX =
can't
>> be used as an interface name when the default gateway isn't reached
>> thru ethX. =A0Even machines with two nics behind the same switch and
>> therefore have the same default gateway on each interface exhibit a
>> problem referencing the interface by ethX -- however by IP address
>> works just fine. =A0So some are behind the same switch and some use
>> totally different paths to the internet - either way it is broken.
>>
>>>
>>> May I ask what you are trying to do? =A0There might be an easier wa=
y.
>>
>> i have a bunch of machines with 2 or more nics (HP and Dell Server
>> Class) that i will use for many types of projects. =A0The easiest wa=
y is
>> for ping and tracert to be fixed. =A0it is the first tool in network
>> assurance and debugging and it is very broken. =A0i suspect this wou=
ld
>> cause problems for users of VPNs, wireless, and other multi nic
>> scenarios.
>>
>>>
>>> As far a multi NIC BSD systems, yeah I got a few pfsense boxes, it =
is
>>> BSD.
>>> I started using pfsense when I couldn't get multi WAN Linux to work=
=2E
>>
>> i wish i would have known to give up 2-3 years ago - i knew i wasn't
>> that stupid as i have only been using ping for 20 years. =A0i also h=
ad
>> problems with ping on dd-wrt and as this busybox mailing list shows,=
 i
>> am not the only one. =A0 Note, these busybox guys didn't test this t=
oo
>> well because their examples never ping an ip on the other side of a
>> wire, but it is the exact same problem.
>> http://lists.busybox.net/pipermail/busybox/2009-July/069972.html
>>
>>>
>>>
>>>
>>> -----Original Message-----
>>> From: olug-bounces@olug.org [mailto:olug-bounces@olug.org] On Behal=
f Of
>>> Rob
>>> Townley
>>> Sent: Sunday, October 11, 2009 12:32 PM
>>> To: Omaha Linux User Group
>>> Subject: Re: [olug] Ping Is Broken
>>>
>>> On Sat, Oct 10, 2009 at 8:17 PM, Aric Aasgaard <aric@omahax.com> wr=
ote:
>>>>
>>>> Does
>>>> traceroute -i eth0 -I 208.67.222.222
>>>> using ICMP
>>>
>>> eth0 =3D 4.3.2.8, the default gateway is thru eth1.
>>> tracert -i eth0 -I 208.67.222.222 =A0 =A0 =A0 =A0FAILS
>>> tracert -s 4.3.2.8 -I 208.67.222.222 =A0 WORKS
>>> tracert -i eth0 208.67.222.222 =A0 =A0 =A0 =A0 =A0 FAILS
>>> tracert -s 4.3.2.8 208.67.222.222 =A0 =A0 =A0WORKS
>>>
>>> There is a still a great deal of heated argument on the netdev list=
 on
>>> how to make network device naming better. =A0Some want to name
>>> interfaces in the order of MAC address, others in the name of bus
>>> enumeration, some think symbolic links will make things more
>>> complicated, others want it. =A0Please test using the following scr=
ipt.
>>> Anybody have a multinic BSD system up that would care to test this.
>>> OSX?
>>>
>>> #!/bin/bash
>>> #The following is a script to test source routing thru the network
>>> interface alias vs ip address.
>>> #Put in your own IP addresses here.
>>> ip0=3D4.3.2.8
>>> ip1=3D192.168.168.155
>>> for interface in eth0 $ip0 eth1 $ip1; do echo testing $interface; p=
ing
>>> -I $interface 208.67.222.222; done;
>>>
>>>>
>>>> or using UDP
>>>> traceroute -i eth0 208.67.222.222
>>>>
>>>> Work?
>>>>
>>>> -----Original Message-----
>>>> From: olug-bounces@olug.org [mailto:olug-bounces@olug.org] On Beha=
lf Of
>>>
>>> Rob
>>>>
>>>> Townley
>>>> Sent: Friday, October 09, 2009 11:45 AM
>>>> To: netdev@vger.kernel.org
>>>> Cc: CentOS mailing list; Omaha Linux User Group
>>>> Subject: Re: [olug] Ping Is Broken
>>>>
>>>> ping -I is broken
>>>>
>>>> The following deals with bug in ping that made it very difficult t=
o set
>>>> up
>>>
>>> a
>>>>
>>>> system with two gateways.
>>>>
>>>> Demonstration that *ping -I is broken*. When specifying the source
>>>> interface using -I with an *ethX* alias and that interface is not =
the
>>>> default gateway
>>>> interface, then ping fails. When specifying the interface as an ip
>>>
>>> address,
>>>>
>>>> ping works. Search for "Destination Host Unreachable" to find the =
bug.
>>>>
>>>>
>>>> eth*0* =3D 4.3.2.8 and the default gateway is accessed through a d=
ifferent
>>>> interface eth*1*.
>>>> eth*1* =3D 192.168.168.155 is used as the device to get to the def=
ault
>>>> gateway.
>>>> *FAILS *: ping *-I eth0* 208.67.222.222
>>>> *WORKS*: ping *-I 4.3.2.8* 208.67.222.222
>>>> *WORKS*: ping *-I eth1* 208.67.222.222
>>>> *WORKS*: ping *-I 192.168.168.155* 208.67.222.222
>>>>
>>>> The following are actual results which can be reproduced from an
>>>
>>> up-to-date
>>>>
>>>> Fedora 11 or CentOS 5.3 box. Caused a very very long episode of
>>>
>>> frustration
>>>>
>>>> when setting up multi gatewayed systems.
>>>>
>>>>
>>>> * ping using eth0 *:
>>>>
>>>> ping -c 2 -B -I =A0eth0 208.67.222.222
>>>> PING 208.67.222.222 (208.67.222.222) from 4.3.2.8 eth0: 56(84) byt=
es of
>>>> data.
>>>> From 4.3.2.8 icmp_seq=3D1 Destination Host Unreachable
>>>> From 4.3.2.8 icmp_seq=3D2 Destination Host Unreachable
>>>>
>>>> --- 208.67.222.222 ping statistics ---
>>>> 2 packets transmitted, 0 received, +2 errors, 100% packet loss, ti=
me
>>>> 999ms
>>>> , pipe 2
>>>>
>>>> --------------------------------------
>>>> The Following all WORK:
>>>> * ping using 4.3.2.8 *:
>>>>
>>>> ping -c 2 -B -I =A04.3.2.8 208.67.222.222
>>>> PING 208.67.222.222 (208.67.222.222) from 4.3.2.8 : 56(84) bytes o=
f
>>>> data.
>>>> 64 bytes from 208.67.222.222: icmp_seq=3D1 ttl=3D55 time=3D562 ms
>>>> 64 bytes from 208.67.222.222: icmp_seq=3D2 ttl=3D55 time=3D642 ms
>>>>
>>>> --- 208.67.222.222 ping statistics ---
>>>> 2 packets transmitted, 2 received, 0% packet loss, time 999ms
>>>> rtt min/avg/max/mdev =3D 562.546/602.400/642.255/39.862 ms
>>>>
>>>>
>>>> * ping using eth1 *:
>>>>
>>>> ping -c 2 -B -I =A0eth1 208.67.222.222
>>>> PING 208.67.222.222 (208.67.222.222) from 192.168.168.155 eth1: 56=
(84)
>>>> bytes of data.
>>>> 64 bytes from 208.67.222.222: icmp_seq=3D1 ttl=3D54 time=3D270 ms
>>>> 64 bytes from 208.67.222.222: icmp_seq=3D2 ttl=3D54 time=3D629 ms
>>>>
>>>> --- 208.67.222.222 ping statistics ---
>>>> 2 packets transmitted, 2 received, 0% packet loss, time 1000ms
>>>> rtt min/avg/max/mdev =3D 270.128/449.766/629.405/179.639 ms
>>>>
>>>>
>>>> * ping using 192.168.168.155 *:
>>>>
>>>> ping -c 2 -B -I =A0192.168.168.155 208.67.222.222
>>>> PING 208.67.222.222 (208.67.222.222) from 192.168.168.155 : 56(84)
>>>> bytes of data.
>>>> 64 bytes from 208.67.222.222: icmp_seq=3D1 ttl=3D54 time=3D585 ms
>>>> 64 bytes from 208.67.222.222: icmp_seq=3D2 ttl=3D54 time=3D554 ms
>>>>
>>>> --- 208.67.222.222 ping statistics ---
>>>> 2 packets transmitted, 2 received, 0% packet loss, time 999ms
>>>> rtt min/avg/max/mdev =3D 554.098/569.655/585.212/15.557 ms
>>>>
>>>> My source route policy rules:
>>>>
>>>> /sbin/ip rule show
>>>> 0: =A0 =A0 =A0from all lookup 255
>>>> 32762: =A0from 4.3.2.8 lookup nic0
>>>> 32763: =A0from 192.168.168.155 lookup nic1
>>>> 32764: =A0from 192.168.168.155 lookup nic1
>>>> 32765: =A0from 4.3.2.8 lookup nic0
>>>> 32766: =A0from all lookup main
>>>> 32767: =A0from all lookup default
>>>>
>>>>
>>>>
>>>> Print out routing tables using /sbin/ip route show table TABLENAME=
:
>>>> routing table =A0nic0 :
>>>> /sbin/ip route show table nic0
>>>> default via 4.3.2.1 dev eth0
>>>>
>>>> routing table =A0nic1 :
>>>> /sbin/ip route show table nic1
>>>> default via 192.168.168.1 dev eth1
>>>>
>>>> routing table =A0main :
>>>> /sbin/ip route show table main
>>>> 4.3.2.1/27 dev eth0 =A0proto kernel =A0scope link =A0src 4.3.2.8
>>>> 192.168.168.0/24 dev eth1 =A0proto kernel =A0scope link =A0src 192=
=2E168.168.155
>>>> 169.254.0.0/16 dev eth1 =A0scope link
>>>> default via 192.168.168.1 dev eth1
>>>>
>>>> routing table =A0default :
>>>> /sbin/ip route show table default
>>>>
>>>>
>>>>
>>>>
>>>> NOTES: cat /etc/iproute2/rt_tables to get your own table names.
>>>>
>>>> ping Maintainer YOSHIFUJI Hideaki / USAGI/WIDE Project
>>>> =A0http://www.skbuff.net/iputils/
>>>> Mailing List netdev@vger.kernel.org
>>>>
>>>> man ping:
>>>> =A0 -I interface address
>>>> =A0 =A0 =A0 =A0Set source address to specified interface address.
>>>> =A0 =A0 =A0 =A0Argument may be *numeric IP address or name of devi=
ce*.
>>>> =A0 =A0 =A0 =A0When =A0pinging =A0IPv6 =A0link-local =A0address =A0=
this option is
>>>> required.
>>>>
>>>> ping -V returns the latest available on CentOS and Fedora and the
>>>> maintainers website:
>>>> ping utility, iputils-ss020927
>
> --------------------------------------------------
> Matthew G. Marsh
> Special Email Addr for OLUG ;-}
> Phone: (402) 932-7250
> Email: olug4mgm@paktronix.com
> WWW: =A0http://www.paksecured.org
> --------------------------------------------------

Matt,

without iproute2, ping -I ethX works.

leave it to a lawyer to explain away ping failing! (just kidding)  it
probably does take legalese, but write that new book soon.
i never forgot your email.  i attempted to add additional routes based
on your explanation.  It was so long ago that i do not remember the
exact details of the attempts, but there was no success.  i was not
sure if you were thinking it would never work as is or that simply
additional routes needed to be added?  Regardless, here are some
interesting results that i found using the slax live cd without
iproute installed  which demonstrate ping -I ethX works not resulting
in an error.  It is not a true test because all interfaces in this vm
are using the same gateway.  Have you written your new book yet?

Downloaded the slax livecd iso from slax.org which appears to not have
iproute installed at all, but specifying different ethX interfaces
works fine.  There is a iproute module that can be downloaded and
installed, but it isn't.  The same VirtualBox config running Fedora 12
Live, ping fails when specifying anything but the default gateway
ethX.

Installed on a VirtualBox vm with 4 virtual bridged network cards.

Linux slax 2.6.27.27 #1 SMP Wed Jul 22 07:27:34 AKDT 2009 i686
Intel(R) Pentium(R) 4 CPU 3.20GHz GenuineIntel GNU/Linux

Linux version 2.6.27.27 (root@darkstar) (gcc version 4.2.4) #1 SMP Wed
Jul 22 07:27:34 AKDT 2009

for ((i=3D0; i < 4; i++)); do ping -c 1 -I eth${i} 208.67.222.222; done=
;

PING 208.67.222.222 (208.67.222.222) from 192.168.168.219 eth0: 56(84)
bytes of data.
64 bytes from 208.67.222.222: icmp_seq=3D1 ttl=3D49 time=3D1098 ms

--- 208.67.222.222 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev =3D 1098.078/1098.078/1098.078/0.000 ms
PING 208.67.222.222 (208.67.222.222) from 192.168.168.231 eth1: 56(84)
bytes of data.
64 bytes from 208.67.222.222: icmp_seq=3D1 ttl=3D49 time=3D156 ms

--- 208.67.222.222 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev =3D 156.386/156.386/156.386/0.000 ms
PING 208.67.222.222 (208.67.222.222) from 192.168.168.157 eth2: 56(84)
bytes of data.
64 bytes from 208.67.222.222: icmp_seq=3D1 ttl=3D49 time=3D143 ms

--- 208.67.222.222 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev =3D 143.279/143.279/143.279/0.000 ms
PING 208.67.222.222 (208.67.222.222) from 192.168.168.229 eth3: 56(84)
bytes of data.
64 bytes from 208.67.222.222: icmp_seq=3D1 ttl=3D49 time=3D128 ms

--- 208.67.222.222 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev =3D 128.547/128.547/128.547/0.000 ms
