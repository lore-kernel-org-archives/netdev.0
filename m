From: Anand Raj Manickam <anandrm@gmail.com>
Subject: Re: Realtek r8168C / r8169 driver VLAN TAG stripping
Date: Fri, 28 Jan 2011 17:46:26 +0530
Message-ID: <AANLkTimhLUo8mtzvvpejyG4Unzb5-36LLu7bmYCPWAh_@mail.gmail.com>
References: <AANLkTimqkJ3DGBX5iREEcx6sgAM+2CZHNWMU+noNSitp@mail.gmail.com>
	<20110116192017.GA3569@electric-eye.fr.zoreil.com>
	<AANLkTi=uNKMj_gs_bKRQ1tQa0TMwdnyrtVcR5JPNpmJv@mail.gmail.com>
	<AANLkTikoXfgHrJyMbe6A_HmvXT_QRo55w76st5Wo0hSv@mail.gmail.com>
	<20110118012146.GA3704@electric-eye.fr.zoreil.com>
	<AANLkTimA1C=trH+WGpBdPU=vBf-cN+xB4Br3+vJb-Qum@mail.gmail.com>
	<20110127150744.GA7925@electric-eye.fr.zoreil.com>
	<AANLkTi=OwsMO8x9AOy=MmohU4SSQcv+o=TvwNs0NNsQR@mail.gmail.com>
	<20110127165031.GA7966@electric-eye.fr.zoreil.com>
	<AANLkTin17BgJDdTbSMork8XEw4PVz_KrVBZvHdQwTRNH@mail.gmail.com>
	<20110128120624.GA8100@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Hayes <hayeswang@realtek.com>,
	Ivan Vecera <ivecera@redhat.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:64287 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754752Ab1A1MQ2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jan 2011 07:16:28 -0500
Received: by bwz15 with SMTP id 15so3139161bwz.19
        for <netdev@vger.kernel.org>; Fri, 28 Jan 2011 04:16:26 -0800 (PST)
In-Reply-To: <20110128120624.GA8100@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 28, 2011 at 5:36 PM, Francois Romieu <romieu@fr.zoreil.com>=
 wrote:
> Added Ivan to the Cc:. He has got a 8168c with XID 1c4000c0 and may t=
ell if
> hardware VLAN works for him or not.

Keeping my fingers crossed for Ivan's results :)


> Anand Raj Manickam <anandrm@gmail.com> :
>> On Thu, Jan 27, 2011 at 10:20 PM, Francois Romieu <romieu@fr.zoreil.=
com> wrote:
>> > Anand Raj Manickam <anandrm@gmail.com> :
>> >> On Thu, Jan 27, 2011 at 8:37 PM, Francois Romieu <romieu@fr.zorei=
l.com> wrote:
>> >> > Anand Raj Manickam <anandrm@gmail.com> :
>> > [...]
>> >> > - ip addr show
>> >>
>> >> 3: eth0: <BROADCAST,MULTICAST,UP,10000> mtu 1500 qdisc pfifo_fast=
 qlen 1000
>> >> =A0 =A0 link/ether 00:17:54:00:f6:62 brd ff:ff:ff:ff:ff:ff
>> >> =A0 =A0 inet 172.16.1.1/16 brd 172.16.255.255 scope global eth0
>> >> =A0 =A0 inet6 fe80::217:54ff:fe00:f662/64 scope link
>> >> =A0 =A0 =A0 =A0valid_lft forever preferred_lft forever
>> >>
>> >> 8: eth0.50@eth0: <BROADCAST,MULTICAST,UP,10000> mtu 1500 qdisc no=
queue
>> >> =A0 =A0 link/ether 00:17:54:00:f6:62 brd ff:ff:ff:ff:ff:ff
>> >> =A0 =A0 inet 172.16.10.10/24 brd 172.16.10.255 scope global eth0.=
50
>> >> =A0 =A0 inet6 fe80::217:54ff:fe00:f662/64 scope link
>> >> =A0 =A0 =A0 =A0valid_lft forever preferred_lft forever
>> >
>> > Could you try again after issuing :
>> >
>> > ip addr del 172.16.1.1/16 brd 172.16.255.255 dev eth0
>>
>>
>> I did try this NO luck ;-(
>>
>> > then send the unabbreviated "ip addr show" and "ip route show all"=
 if
>> > things do not perform better.
>> >
>>
>> =A0ip addr show
>> 1: lo: <LOOPBACK,UP,10000> mtu 16436 qdisc noqueue
>> =A0 =A0 link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
>> =A0 =A0 inet 127.0.0.1/8 scope host lo
>> =A0 =A0 inet6 ::1/128 scope host
>> =A0 =A0 =A0 =A0valid_lft forever preferred_lft forever
>> 2: sit0: <NOARP> mtu 1480 qdisc noop
>> =A0 =A0 link/sit 0.0.0.0 brd 0.0.0.0
>> 3: eth0: <BROADCAST,MULTICAST,UP,10000> mtu 1500 qdisc pfifo_fast ql=
en 1000
>> =A0 =A0 link/ether 00:17:54:00:f6:62 brd ff:ff:ff:ff:ff:ff
>> =A0 =A0 inet6 fe80::217:54ff:fe00:f662/64 scope link
>> =A0 =A0 =A0 =A0valid_lft forever preferred_lft forever
>> 4: eth1: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fa=
st qlen 1000
>> =A0 =A0 link/ether 00:17:54:00:f6:63 brd ff:ff:ff:ff:ff:ff
>> 5: eth2: <BROADCAST,MULTICAST,UP,10000> mtu 1500 qdisc pfifo_fast ql=
en 1000
>> =A0 =A0 link/ether 00:30:67:09:2c:b9 brd ff:ff:ff:ff:ff:ff
>> =A0 =A0 inet 10.1.1.2/24 brd 10.1.1.255 scope global eth2
>> =A0 =A0 inet6 fe80::230:67ff:fe09:2cb9/64 scope link
>> =A0 =A0 =A0 =A0valid_lft forever preferred_lft forever
>> 6: eth3: <BROADCAST,MULTICAST> mtu 1500 qdisc noop qlen 1000
>> =A0 =A0 link/ether 00:17:54:00:65:6b brd ff:ff:ff:ff:ff:ff
>> 7: eth4: <BROADCAST,MULTICAST,UP,10000> mtu 1500 qdisc pfifo_fast ql=
en 1000
>> =A0 =A0 link/ether 00:17:54:00:65:6a brd ff:ff:ff:ff:ff:ff
>> =A0 =A0 inet 192.168.138.155/24 brd 192.168.138.255 scope global eth=
4
>> =A0 =A0 inet6 fe80::217:54ff:fe00:656a/64 scope link
>> =A0 =A0 =A0 =A0valid_lft forever preferred_lft forever
>> 8: eth0.50@eth0: <BROADCAST,MULTICAST,UP,10000> mtu 1500 qdisc noque=
ue
>> =A0 =A0 link/ether 00:17:54:00:f6:62 brd ff:ff:ff:ff:ff:ff
>> =A0 =A0 inet 172.16.10.10/24 brd 172.16.10.255 scope global eth0.50
>> =A0 =A0 inet6 fe80::217:54ff:fe00:f662/64 scope link
>> =A0 =A0 =A0 =A0valid_lft forever preferred_lft forever
>
> (mostly sequential hardware mac adresses)
>
> Which Arkino product is it ? Quad (+1) port switch / hub ? AK1140 ?
>
> Forget the "ip route show all" for now.
>
> [...]
>> >> The same config works on forcedeth
>> >
>> > What do you call "same config" ?
>>
>> The Same setup below works on forcedeth driver
>
> So you can remove any single 8168 adapter from eth[0134], replace it =
with
> an external (non-LOM) forcedeth, keep the three remaining 8168s and i=
t
> works correctly ?
>
> If your setup includes a card that contains several 8168 chipsets beh=
ind
> some kind of bridge, it is not exactly the same setup as a single (LO=
M ?)
> forcedeth network adapter.

It is Onboard chipset , so cannot be replaced :-(

>
> [...]
>> >
>> > I am mildly convinced that your config is simple enough to isolate=
 a
>> > driver level vlan problem.
>>
>> The reason why i m sure its on the Driver / Chipset is this ..
> [printk removed]
>
> Ok. This is an evidence.
>
> Reading my rev1.0 8168c datasheet from may 2007, when there is no tx
> offload, no checksumming, the tx descriptor layout should be the same
> as the perennial 8169 tx descriptor layout.
>
> Either (1) the VLAN registers and descriptor layout is different for =
this
> chipset or (2) something prevents the register / descriptor write (re=
ad ?)
> to be completely effective or (3) there is something beyond the 8168 =
or
> (4) there is a 8168 hardware bug.
>
> 1 : Hayes may answer. You can give Realtek's own driver a try btw.
> 2 : Seen before. It could be a software or a (non-8168) hardware one.
> =A0 =A0I have no idea if your hardware setup includes a single card w=
ith
> =A0 =A0four ports or four independent cards with their own 8168 or wo=
rse.
> 3 : See the hardware setup part of (2).
> 4 : I don't hope so. Hayes may answer as well.


>
> --
> Ueimor
>
