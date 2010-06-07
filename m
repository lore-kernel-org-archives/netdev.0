From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Virtual device and ARP table
Date: Mon, 07 Jun 2010 14:22:00 +0200
Message-ID: <1275913320.2545.53.camel@edumazet-laptop>
References: <4C0CC810.7030501@unibas.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Christophe Jelger <Christophe.Jelger@unibas.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4C0CC810.7030501@unibas.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 07 juin 2010 =C3=A0 12:21 +0200, Christophe Jelger a =C3=A9cri=
t :
> Hello,
>=20
> I am currently "resurrecting" a Linux module (called LUNAR) which I=20
> co-developed in 2007 and I'm having a weird kernel crash. This code=20
> basically used to work fine up to 2.6.18 which was the latest version=
=20
> before we stopped our development. I quickly ported it to 2.6.{31,32}=
:=20
> it compiles fine and loads fine, but it crashes/hangs the kernel when=
=20
> it's really being used.
>=20
> The module is a virtual device used for MANET routing: with the curre=
nt=20
> version, it basically "captures" DNS requests sent to the virtual=20
> interface --> this triggers the sending of a fake DNS reply (see belo=
w)=20
> and the creation of an ARP table entry for the destination (the MANET=
=20
> route is built at the same time). Packets can then be sent to the=20
> destination.
>=20
> The problem I'm having is that the kernel quickly hangs after I creat=
e a=20
> new ARP entry (actually only if it's being used). If the entry I crea=
te=20
> is set to NUD_PERMANENT, then everything works fine! I use=20
> __neigh_lookup_errno to lookup/create the entry and neigh_lookup to=20
> set/update the MAC address. Note that the ARP entry is created withou=
t=20
> problem, but typically even just doing a userspace "arp -a" command c=
an=20
> crash the kernel (it also hangs the userspace command!). Doing "arp -=
na"=20
> usually does NOT crash the kernel!
>=20
> I guess the problem comes from a combination of ARP + DNS=20
> lookups/replies. Note that my kernel module has its own internal fake=
=20
> DNS server which captures lookups and sends replies directly back to =
the=20
> stack. What is amazing: if the ARP entry I create is set to=20
> NUD_PERMANENT, then I don't get any crash (however I cannot develop m=
y=20
> module with permanent ARP entries).
>=20
> I'm wondering if there were any major changes to the neighbor and arp=
=20
> code (between 2.6.18 and 2.6.31) that are somehow causing this proble=
m ?...
>=20
> Any hint is very welcome.
>=20
> thanks in advance,
> Christophe
>=20
> PS: I can easily reproduce the problem, and was trying to debug with=20
> qemu and gdb server but so fra no success to clearly identify the=20
> problem. Last point: it seems the kernel does not really "crash" but=20
> rather ends up in some unstable state and maybe in a loop.
> --

Hi Christophe

You should ask these kind of questions on netdev instead of lkml.

And of course, post your patch, or send us a crystal ball ;)

Yes, many things changed between 2.6.18 and 2.6.34
