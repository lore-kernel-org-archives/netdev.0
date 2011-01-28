From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Realtek r8168C / r8169 driver VLAN TAG stripping
Date: Fri, 28 Jan 2011 13:06:24 +0100
Message-ID: <20110128120624.GA8100@electric-eye.fr.zoreil.com>
References: <AANLkTimqkJ3DGBX5iREEcx6sgAM+2CZHNWMU+noNSitp@mail.gmail.com> <20110116192017.GA3569@electric-eye.fr.zoreil.com> <AANLkTi=uNKMj_gs_bKRQ1tQa0TMwdnyrtVcR5JPNpmJv@mail.gmail.com> <AANLkTikoXfgHrJyMbe6A_HmvXT_QRo55w76st5Wo0hSv@mail.gmail.com> <20110118012146.GA3704@electric-eye.fr.zoreil.com> <AANLkTimA1C=trH+WGpBdPU=vBf-cN+xB4Br3+vJb-Qum@mail.gmail.com> <20110127150744.GA7925@electric-eye.fr.zoreil.com> <AANLkTi=OwsMO8x9AOy=MmohU4SSQcv+o=TvwNs0NNsQR@mail.gmail.com> <20110127165031.GA7966@electric-eye.fr.zoreil.com> <AANLkTin17BgJDdTbSMork8XEw4PVz_KrVBZvHdQwTRNH@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Hayes <hayeswang@realtek.com>,
	Ivan Vecera <ivecera@redhat.com>
To: Anand Raj Manickam <anandrm@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:39578 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754762Ab1A1MI0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jan 2011 07:08:26 -0500
Content-Disposition: inline
In-Reply-To: <AANLkTin17BgJDdTbSMork8XEw4PVz_KrVBZvHdQwTRNH@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added Ivan to the Cc:. He has got a 8168c with XID 1c4000c0 and may tel=
l if
hardware VLAN works for him or not.

Anand Raj Manickam <anandrm@gmail.com> :
> On Thu, Jan 27, 2011 at 10:20 PM, Francois Romieu <romieu@fr.zoreil.c=
om> wrote:
> > Anand Raj Manickam <anandrm@gmail.com> :
> >> On Thu, Jan 27, 2011 at 8:37 PM, Francois Romieu <romieu@fr.zoreil=
=2Ecom> wrote:
> >> > Anand Raj Manickam <anandrm@gmail.com> :
> > [...]
> >> > - ip addr show
> >>
> >> 3: eth0: <BROADCAST,MULTICAST,UP,10000> mtu 1500 qdisc pfifo_fast =
qlen 1000
> >> =C2=A0 =C2=A0 link/ether 00:17:54:00:f6:62 brd ff:ff:ff:ff:ff:ff
> >> =C2=A0 =C2=A0 inet 172.16.1.1/16 brd 172.16.255.255 scope global e=
th0
> >> =C2=A0 =C2=A0 inet6 fe80::217:54ff:fe00:f662/64 scope link
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0valid_lft forever preferred_lft forever
> >>
> >> 8: eth0.50@eth0: <BROADCAST,MULTICAST,UP,10000> mtu 1500 qdisc noq=
ueue
> >> =C2=A0 =C2=A0 link/ether 00:17:54:00:f6:62 brd ff:ff:ff:ff:ff:ff
> >> =C2=A0 =C2=A0 inet 172.16.10.10/24 brd 172.16.10.255 scope global =
eth0.50
> >> =C2=A0 =C2=A0 inet6 fe80::217:54ff:fe00:f662/64 scope link
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0valid_lft forever preferred_lft forever
> >
> > Could you try again after issuing :
> >
> > ip addr del 172.16.1.1/16 brd 172.16.255.255 dev eth0
>=20
>=20
> I did try this NO luck ;-(
>=20
> > then send the unabbreviated "ip addr show" and "ip route show all" =
if
> > things do not perform better.
> >
>=20
>  ip addr show
> 1: lo: <LOOPBACK,UP,10000> mtu 16436 qdisc noqueue
>     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
>     inet 127.0.0.1/8 scope host lo
>     inet6 ::1/128 scope host
>        valid_lft forever preferred_lft forever
> 2: sit0: <NOARP> mtu 1480 qdisc noop
>     link/sit 0.0.0.0 brd 0.0.0.0
> 3: eth0: <BROADCAST,MULTICAST,UP,10000> mtu 1500 qdisc pfifo_fast qle=
n 1000
>     link/ether 00:17:54:00:f6:62 brd ff:ff:ff:ff:ff:ff
>     inet6 fe80::217:54ff:fe00:f662/64 scope link
>        valid_lft forever preferred_lft forever
> 4: eth1: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fas=
t qlen 1000
>     link/ether 00:17:54:00:f6:63 brd ff:ff:ff:ff:ff:ff
> 5: eth2: <BROADCAST,MULTICAST,UP,10000> mtu 1500 qdisc pfifo_fast qle=
n 1000
>     link/ether 00:30:67:09:2c:b9 brd ff:ff:ff:ff:ff:ff
>     inet 10.1.1.2/24 brd 10.1.1.255 scope global eth2
>     inet6 fe80::230:67ff:fe09:2cb9/64 scope link
>        valid_lft forever preferred_lft forever
> 6: eth3: <BROADCAST,MULTICAST> mtu 1500 qdisc noop qlen 1000
>     link/ether 00:17:54:00:65:6b brd ff:ff:ff:ff:ff:ff
> 7: eth4: <BROADCAST,MULTICAST,UP,10000> mtu 1500 qdisc pfifo_fast qle=
n 1000
>     link/ether 00:17:54:00:65:6a brd ff:ff:ff:ff:ff:ff
>     inet 192.168.138.155/24 brd 192.168.138.255 scope global eth4
>     inet6 fe80::217:54ff:fe00:656a/64 scope link
>        valid_lft forever preferred_lft forever
> 8: eth0.50@eth0: <BROADCAST,MULTICAST,UP,10000> mtu 1500 qdisc noqueu=
e
>     link/ether 00:17:54:00:f6:62 brd ff:ff:ff:ff:ff:ff
>     inet 172.16.10.10/24 brd 172.16.10.255 scope global eth0.50
>     inet6 fe80::217:54ff:fe00:f662/64 scope link
>        valid_lft forever preferred_lft forever

(mostly sequential hardware mac adresses)

Which Arkino product is it ? Quad (+1) port switch / hub ? AK1140 ?

=46orget the "ip route show all" for now.

[...]
> >> The same config works on forcedeth
> >
> > What do you call "same config" ?
>=20
> The Same setup below works on forcedeth driver

So you can remove any single 8168 adapter from eth[0134], replace it wi=
th
an external (non-LOM) forcedeth, keep the three remaining 8168s and it
works correctly ?

If your setup includes a card that contains several 8168 chipsets behin=
d
some kind of bridge, it is not exactly the same setup as a single (LOM =
?)
forcedeth network adapter.

[...]
> >
> > I am mildly convinced that your config is simple enough to isolate =
a
> > driver level vlan problem.
>=20
> The reason why i m sure its on the Driver / Chipset is this ..
[printk removed]

Ok. This is an evidence.

Reading my rev1.0 8168c datasheet from may 2007, when there is no tx
offload, no checksumming, the tx descriptor layout should be the same
as the perennial 8169 tx descriptor layout.

Either (1) the VLAN registers and descriptor layout is different for th=
is
chipset or (2) something prevents the register / descriptor write (read=
 ?)
to be completely effective or (3) there is something beyond the 8168 or
(4) there is a 8168 hardware bug.

1 : Hayes may answer. You can give Realtek's own driver a try btw.
2 : Seen before. It could be a software or a (non-8168) hardware one.
    I have no idea if your hardware setup includes a single card with
    four ports or four independent cards with their own 8168 or worse.
3 : See the hardware setup part of (2).
4 : I don't hope so. Hayes may answer as well.

--
Ueimor
