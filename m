From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: e1000: more than two seconds to get the flag RUNNING
Date: Fri, 17 Dec 2010 11:43:37 +0100
Message-ID: <4D0B3ED9.3010305@6wind.com>
References: <4D0A3B89.3010600@6wind.com> <DDC57477F5D6F845A0DDCB99D3C4812D0D2E664702@orsmsx510.amr.corp.intel.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	netdev <netdev@vger.kernel.org>
To: "Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:46495 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750869Ab0LQKnn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Dec 2010 05:43:43 -0500
Received: by wyb28 with SMTP id 28so475140wyb.19
        for <netdev@vger.kernel.org>; Fri, 17 Dec 2010 02:43:41 -0800 (PST)
In-Reply-To: <DDC57477F5D6F845A0DDCB99D3C4812D0D2E664702@orsmsx510.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 16.12.2010 17:44, Ronciak, John a =C3=A9crit :
> I'm assuming when you say "get the flag RUNNING" you mean to get link=
=2E  Is that right?  Are you connected to a switch?  It is entirely pos=
sible to wait 2 seconds to get link on a 1000Base-T (RJ45) link.  By sp=
ecification link can take as much as 4 seconds.  Do you have spanning t=
ree enabled on the switch?  That could be delaying link as well.
Yes, I mean 'get the link'. I was connected to a switch, but no spannin=
g tree.

>=20
> To check this connect it back to back to another system.  With this o=
ld of an adapter you may need to connect the two systems with a cross-o=
ver cable.
I get the same issue.


Regards,
Nicolas

>=20
> Cheers,
> John
>=20
>=20
>> -----Original Message-----
>> From: Nicolas Dichtel [mailto:nicolas.dichtel@6wind.com]
>> Sent: Thursday, December 16, 2010 8:17 AM
>> To: Kirsher, Jeffrey T; Brandeburg, Jesse; Allan, Bruce W; Wyborny,
>> Carolyn; Skidmore, Donald C; Rose, Gregory V; Waskiewicz Jr, Peter P=
;
>> Duyck, Alexander H; Ronciak, John
>> Cc: netdev
>> Subject: e1000: more than two seconds to get the flag RUNNING
>>
>> Hi,
>>
>> maybe this problem has already been discussed, but I didn't find the
>> thread.
>> When I put an interface managed by the e1000 driver up, down and up
>> again, I must wait more than 2 seconds to get the flag running again=
=2E
>>
>> Here is the sequence:
>>
>> shelby:~# uname -a
>> Linux shelby 2.6.37-rc5+ #9 SMP Wed Dec 15 13:16:10 EST 2010 i686
>> GNU/Linux shelby:~# lsmod | grep e1000
>> e1000                  76543  0
>> shelby:~# lspci | grep Gigabit
>> 01:09.0 Ethernet controller: Intel Corporation 82540EM Gigabit Ether=
net
>> Controller (rev 02) shelby:~# cat check_link_state.sh #!/bin/bash
>>
>> sleep_time=3D$1
>> ip link set eth0 up
>> ip link set eth0 down
>> ip link set eth0 up
>> while [ $sleep_time -gt 0 ] ; do
>>      date
>>      #ip link show eth0
>>      ifconfig eth0 | grep MULTICAST
>>      sleep 1
>>      echo ""
>>      sleep_time=3D`expr $sleep_time - 1`
>> done
>> shelby:~# ifconfig eth0
>> eth0      Link encap:Ethernet  HWaddr 00:30:1b:b4:dc:88
>>            inet addr:10.16.0.72  Bcast:10.16.0.255  Mask:255.255.255=
=2E0
>>            inet6 addr: fe80::230:1bff:feb4:dc88/64 Scope:Link
>>            UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>>            RX packets:22051 errors:0 dropped:0 overruns:0 frame:0
>>            TX packets:63 errors:0 dropped:0 overruns:0 carrier:0
>>            collisions:0 txqueuelen:1000
>>            RX bytes:2480685 (2.3 MiB)  TX bytes:5242 (5.1 KiB)
>>
>> shelby:~# ./check_link_state.sh 3
>> [83270.080175] ADDRCONF(NETDEV_UP): eth0: link is not ready Thu Dec =
16
>> 12:45:56 EST 2010
>>            UP BROADCAST MULTICAST  MTU:1500  Metric:1
>>
>> Thu Dec 16 12:45:57 EST 2010
>>            UP BROADCAST MULTICAST  MTU:1500  Metric:1 [83271.828371]
>> e1000: eth0 NIC Link is Up 100 Mbps Half Duplex, Flow Control: None
>> [83271.835878] ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
>>
>> Thu Dec 16 12:45:58 EST 2010
>>            UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>>
>> shelby:~#
>>
>> I get the same result with a 2.6.15, so it seems that the problem is
>> here since a long time.
>> Has anyone an input for this problem?
>>
>>
>> Regards,
>> Nicolas

--=20
Nicolas DICHTEL
6WIND
R&D Engineer

Tel: +33 1 39 30 92 10
=46ax: +33 1 39 30 92 11
nicolas.dichtel@6wind.com
www.6wind.com
Join the Multicore Packet Processing Forum: www.multicorepacketprocessi=
ng.com

Ce courriel ainsi que toutes les pi=C3=A8ces jointes, est uniquement de=
stin=C3=A9 =C3=A0 son ou
ses destinataires. Il contient des informations confidentielles qui son=
t la
propri=C3=A9t=C3=A9 de 6WIND. Toute r=C3=A9v=C3=A9lation, distribution =
ou copie des informations
qu'il contient est strictement interdite. Si vous avez re=C3=A7u ce mes=
sage par
erreur, veuillez imm=C3=A9diatement le signaler =C3=A0 l'=C3=A9metteur =
et d=C3=A9truire toutes les
donn=C3=A9es re=C3=A7ues.

This e-mail message, including any attachments, is for the sole use of =
the
intended recipient(s) and contains information that is confidential and
proprietary to 6WIND. All unauthorized review, use, disclosure or distr=
ibution
is prohibited. If you are not the intended recipient, please contact th=
e sender
by reply e-mail and destroy all copies of the original message.

