From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [2.6.33-rc5] kernel BUG at include/net/netns/generic.h:41!
Date: Fri, 29 Jan 2010 16:22:29 +0100
Message-ID: <1264778549.3184.28.camel@edumazet-laptop>
References: <20100129094822.GA8294@nb-core2.darkstar.lan>
	 <b6fcc0a1001290217l4edb0a0btbafa0c26b6f14ad5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Luca Tettamanti <kronos.it@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756109Ab0A2PWg@vger.kernel.org>
In-Reply-To: <b6fcc0a1001290217l4edb0a0btbafa0c26b6f14ad5@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 29 janvier 2010 =C3=A0 12:17 +0200, Alexey Dobriyan a =C3=A9=
crit :
> On Fri, Jan 29, 2010 at 11:48 AM, Luca Tettamanti <kronos.it@gmail.co=
m> wrote:
> > with recent kernels I'm seeing this BUG - triggered by racoon - at =
boot:
> >
> > NET: Registered protocol family 15
> > ------------[ cut here ]------------
> > kernel BUG at /home/kronos/src/linux-2.6.git/include/net/netns/gene=
ric.h:43!
> > invalid opcode: 0000 [#1] PREEMPT SMP
> > last sysfs file: /sys/kernel/uevent_seqnum
> > CPU 1
> > Pid: 1941, comm: racoon Not tainted 2.6.33-rc5-00271-gbe8cde8-dirty=
 #238 F3Sa      /F3Sa
> > RIP: 0010:[<ffffffffa03035be>]  [<ffffffffa03035be>] pfkey_create+0=
x36/0x18b [af_key]
>=20
> Does it triggers after succesfull boot if you do
>=20
>     rmmod af_key; modprobe af_key
>=20
> a couple of times?
>=20
> Post .config, just in case.

I am looking at ipsec_pfkey_init()

We call sock_register(&pfkey_family_ops) before pfkey_net_id being
initialized (by the call to register_pernet_subsys(&pfkey_net_ops);

As soon as sock_register(&pfkey_family_ops) is done, another thread can
open a socket and call pfkey_create()  -> crash

We should change order of initializations somehow
