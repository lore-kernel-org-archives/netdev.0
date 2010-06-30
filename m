From: ratheesh k <ratheesh.ksz@gmail.com>
Subject: Re: [Bridge] Bridge blocking network traffic
Date: Wed, 30 Jun 2010 13:20:50 +0530
Message-ID: <AANLkTimPiriAOGpHHrAoEyFGuuyn1g8vFqW6Pimdz9CQ@mail.gmail.com>
References: <m2nbc9320b91004211748o5548f351z646076fab6744cca@mail.gmail.com>
	<20100422130919.70206765@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netfilter mailing list <netfilter@vger.kernel.org>,
	netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:60246 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750909Ab0F3Huv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 03:50:51 -0400
In-Reply-To: <20100422130919.70206765@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>On Fri, Apr 23, 2010 at 1:39 AM, Stephen Hemminger <shemminger@linux-=
foundation.org> wrote:
>>You are supposed to assign IP address to bridge not the member of the=
 bridge

Why is it so ?

I have a linux   machine with interfaces eth0 (192.168.1.100 ) and
eth1 ( 192.168.2.100 )  .   . I can connect  both eth0 an eth1  to a
hardware  HUB . How could i do this in linux machine itself using
brctl ?

Thanks,
Ratheesh



> On Thu, 22 Apr 2010 10:48:09 +1000
> benno joy <bennojoy@gmail.com> wrote:
>
>> Dear Team,
>>
>> I have a strange problem...... This is my problem i have a linux box=
 running
>> Xen kernel (2.2). and i have the a bonding interface called bond0.49=
7(eth0
>> and eth1 and also des Vlan tagging).
>> the bond0.497 is part of the bridge "xenbrv497", the issue is as soo=
n as i
>> make the bond a part of the bridge my network traffic stops to work.
>> I did some prelimanary tests and found the following:
>> 1) if i assighn an ip to the bond and do a ping to the gateway it wo=
rks
>> (provided it is not part of bridge xenbrv497)
>> 2) if i add the bondig interface to the brodge xenbrv497 (brclt addi=
f
>> xenbrv497 bond0.497) the ping tests fails.
>> 3) i did a tcpdump and found that arp requests are going out of the
>> interface and we are getting response also. but soemhow
>> the arp entries are not gettign registered. i did some googling and =
found it
>> may be because of filtering so i disabled it by
>> echo 0 > in /proc/sys/net/bridge/bridge-nf-*.
>> But even this did not help still the arp entries are not getting reg=
istered
>> due to which my network traffic is gettign dropped.
>> This problem can be resolved by a reboot. but i would like to troubl=
eshoot
>> it.
>> Could you please let me know how i can get more debugging message fr=
om the
>> bridge calls so i can figure out what exactly is happening.
>>
>> # uname -a
>> Linux vmclkxstgh04.espdev.aurdev.national.com.au 2.6.18-128.2.1.4.13=
=2Eel5xen
>> #1 SMP Mon Dec 7 14:34:40 EST 2009 i686 i686 i386 GNU/Linux
>>
>> [root@vmclkxstgh04 ~]# brctl show
>> bridge name =A0 =A0 bridge id =A0 =A0 =A0 =A0 =A0 =A0 =A0 STP enable=
d =A0 =A0 interfaces
>> vlan441 =A0 =A0 =A0 =A0 8000.0017a4770470 =A0 =A0 =A0 no =A0 =A0 =A0=
 =A0 =A0 =A0 =A0bond0.441
>> xenbrv205 =A0 =A0 =A0 =A0 =A0 =A0 =A0 8000.0017a477046c =A0 =A0 =A0 =
no =A0 =A0 =A0 =A0 =A0 =A0 =A0bond1.205
>> xenbrv208 =A0 =A0 =A0 =A0 =A0 =A0 =A0 8000.0017a477046c =A0 =A0 =A0 =
no =A0 =A0 =A0 =A0 =A0 =A0 =A0bond1.208
>> xenbrv220 =A0 =A0 =A0 =A0 =A0 =A0 =A0 8000.000000000000 =A0 =A0 =A0 =
no
>> xenbrv221 =A0 =A0 =A0 =A0 =A0 =A0 =A0 8000.000000000000 =A0 =A0 =A0 =
no
>> xenbrv226 =A0 =A0 =A0 =A0 =A0 =A0 =A0 8000.0017a477046c =A0 =A0 =A0 =
no =A0 =A0 =A0 =A0 =A0 =A0 =A0vif40.1
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vif39.1
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vif37.1
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vif26.1
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vif25.1
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vif24.1
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vif13.1
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bond1.226
>> xenbrv227 =A0 =A0 =A0 =A0 =A0 =A0 =A0 8000.0017a4770470 =A0 =A0 =A0 =
no =A0 =A0 =A0 =A0 =A0 =A0 =A0vif40.0
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vif39.0
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vif37.0
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vif26.0
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vif25.0
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vif24.0
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vif13.0
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bond0.227
>> xenbrv420 =A0 =A0 =A0 =A0 =A0 =A0 =A0 8000.0017a4770470 =A0 =A0 =A0 =
no =A0 =A0 =A0 =A0 =A0 =A0 =A0bond0.420
>> xenbrv422 =A0 =A0 =A0 =A0 =A0 =A0 =A0 8000.0017a4770470 =A0 =A0 =A0 =
no =A0 =A0 =A0 =A0 =A0 =A0 =A0vif35.0
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vif7.0
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vif6.0
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vif4.0
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vif3.0
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 vif2.0
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tap2.0
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bond0.422
>> xenbrv425 =A0 =A0 =A0 =A0 =A0 =A0 =A0 8000.0017a4770470 =A0 =A0 =A0 =
no =A0 =A0 =A0 =A0 =A0 =A0 =A0bond0.425
>> xenbrv450 =A0 =A0 =A0 =A0 =A0 =A0 =A0 8000.0017a4770470 =A0 =A0 =A0 =
no =A0 =A0 =A0 =A0 =A0 =A0 =A0bond0.450
>> xenbrv492 =A0 =A0 =A0 =A0 =A0 =A0 =A0 8000.0017a4770470 =A0 =A0 =A0 =
no =A0 =A0 =A0 =A0 =A0 =A0 =A0bond0.492
>> xenbrv493 =A0 =A0 =A0 =A0 =A0 =A0 =A0 8000.0017a4770470 =A0 =A0 =A0 =
no =A0 =A0 =A0 =A0 =A0 =A0 =A0bond0.493
>> xenbrv494 =A0 =A0 =A0 =A0 =A0 =A0 =A0 8000.0017a4770470 =A0 =A0 =A0 =
no =A0 =A0 =A0 =A0 =A0 =A0 =A0bond0.494
>> xenbrv495 =A0 =A0 =A0 =A0 =A0 =A0 =A0 8000.0017a4770470 =A0 =A0 =A0 =
no =A0 =A0 =A0 =A0 =A0 =A0 =A0bond0.495
>> xenbrv496 =A0 =A0 =A0 =A0 =A0 =A0 =A0 8000.0017a4770470 =A0 =A0 =A0 =
no =A0 =A0 =A0 =A0 =A0 =A0 =A0bond0.496
>> xenbrv497 =A0 =A0 =A0 =A0 =A0 =A0 =A0 8000.0017a4770470 =A0 =A0 =A0 =
no =A0 =A0 =A0 =A0 =A0 =A0 =A0bond0.497
>> xenbrv701 =A0 =A0 =A0 =A0 =A0 =A0 =A0 8000.0017a477046c =A0 =A0 =A0 =
no =A0 =A0 =A0 =A0 =A0 =A0 =A0vif44.1
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bond1.701
>>
>> bond0.497 Link encap:Ethernet =A0HWaddr 00:17:A4:77:04:70
>> =A0 =A0 =A0 =A0 =A0 inet addr:10.12.166.231 =A0Bcast:10.12.166.255 =A0=
Mask:255.255.255.224
>> =A0 =A0 =A0 =A0 =A0 UP BROADCAST RUNNING MASTER MULTICAST =A0MTU:150=
0 =A0Metric:1
>> =A0 =A0 =A0 =A0 =A0 RX packets:3807595 errors:0 dropped:0 overruns:0=
 frame:0
>> =A0 =A0 =A0 =A0 =A0 TX packets:3304 errors:0 dropped:0 overruns:0 ca=
rrier:0
>> =A0 =A0 =A0 =A0 =A0 collisions:0 txqueuelen:0
>> =A0 =A0 =A0 =A0 =A0 RX bytes:188847200 (180.0 MiB) =A0TX bytes:13876=
8 (135.5 KiB)
>
> You are supposed to assign IP address to bridge not the member of the=
 bridge.
>
>
> --
> _______________________________________________
> Bridge mailing list
> Bridge@lists.linux-foundation.org
> https://lists.linux-foundation.org/mailman/listinfo/bridge
>
