From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH][iproute2] tc/q_htb.c: Fix the MPU value output in 'tc
 -d class show dev <device_name> ' command
Date: Mon, 21 Dec 2015 21:45:45 -0800
Message-ID: <20151221214545.7ed9f4a7@xeon-e3>
References: <5917221449918579@web5j.yandex.ru>
	<20151216161558.265296c7@redhat.com>
	<20151216160400.GJ6555@orbit.nwl.cc>
	<1313271450456765@web7g.yandex.ru>
	<20151218165518.GE19288@orbyte.nwl.cc>
	<1335891450475140@web23o.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Phil Sutter <phil@nwl.cc>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Dmitrii Shcherbakov <fw.dmitrii@yandex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:33098 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752916AbbLVFph convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2015 00:45:37 -0500
Received: by mail-pf0-f180.google.com with SMTP id n128so83983268pfn.0
        for <netdev@vger.kernel.org>; Mon, 21 Dec 2015 21:45:37 -0800 (PST)
In-Reply-To: <1335891450475140@web23o.yandex.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 19 Dec 2015 00:45:40 +0300
Dmitrii Shcherbakov <fw.dmitrii@yandex.com> wrote:

> Phil,
>=20
> 18.12.2015, 19:55, "Phil Sutter" <phil@nwl.cc>:
> > On Fri, Dec 18, 2015 at 07:39:25PM +0300, Dmitrii Shcherbakov wrote=
:
> >> =C2=A0> Dmitrii, did iproute2 without your change even print the o=
verhead as set
> >> =C2=A0> by you before? Looking at the code, I'd assume not.
> >>
> >> =C2=A0Tried building iproute2 (as of tag 4.2) and using the upstre=
am linux kernel (also tag 4.2 - 64291f7db5bd8150a74ad2036f1037e6a0428df=
2):
> >
> > This is without your patch, right?
>=20
> Yes (ec4ef6aebd5a52ab1acf1f5be1749320b3188659).=20
>=20
> >
> >> =C2=A0~/src/iproute2/tc$ sudo ./tc class add dev eth0 parent 1: cl=
assid 1:1 htb rate 100kbps ceil 100kbps mpu 256 overhead 64
> >
> > Setting an mpu of 256 is suitable to get 0 as output value, as the =
code
> > before your patch ANDs it with 0xff.
>=20
> True, but then I think I would get the 'old' (encoded) overhead outpu=
t of '1b' then and the first 8 bits which are treated as mpu would be 0=
 anyway. And its 0 for both mpu and overhead ("mpu 0b overhead 0b") whi=
ch is strange. I am going to have to take a look at the kernel state wi=
th gdb.
>=20
> What I would expect instead (notice 'overhead 1b'):
>=20
> [root@localhost ~]# tc -d class show dev eth0
> [root@localhost ~]# tc qdisc add dev eth0 root handle 1: htb default =
12
> [root@localhost ~]# tc class add dev eth0 parent 1: classid 1:1 htb r=
ate 100kbps ceil 100kbps mpu 256 overhead 64
> [root@localhost ~]# tc -d class show dev eth0
> class htb 1:1 root prio 0 quantum 10000 rate 800000bit overhead 64 ce=
il 800000bit burst 1600b/1 mpu 0b overhead 1b cburst 1600b/1 mpu 0b ove=
rhead 1b level 0 =20
>=20
> >
> >> =C2=A0So it looks like the overhead is being set correctly, but th=
e mpu is not, even though the respective kernel module is loaded judgin=
g by what I see.
> >
> > To really know what is being set, you would have to look at the ker=
nel
> > variables not what iproute prints. This is nitpicking mostly, but
> > relevant in this case as your patches to fix iproute's output show.
> >
> > Cheers, Phil
>=20
> I am going to try and take a look at it. I have not delved into the k=
ernel's network subsystem so it may take some time.
>=20
> Thanks,
> Dima

I am going to hold off on this, if it hasn't been urgent for years, the=
re is no
requirement to do it right away. If you come to a conclusion let me kno=
w.

It might be possible to troll back through Internet to get more data on=
 this...
