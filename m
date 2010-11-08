From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: Re: 2.6.37-rc1-git5 -- WARNING: at net/ipv4/devinet.c:137
 in_dev_finish_destroy+0x3d/0x6e()
Date: Mon, 8 Nov 2010 21:55:11 +0100
Message-ID: <20101108205511.GB1585@arch.trippelsdorf.de>
References: <AANLkTinVyf4CpxdzEWUn7zTyOrAMKY3H9Dct-HfopiSD@mail.gmail.com>
 <20101108200600.GG4032@linux.vnet.ibm.com>
 <1289248166.2790.1.camel@edumazet-laptop>
 <20101108204240.GA1585@arch.trippelsdorf.de>
 <1289249191.2790.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: paulmck@linux.vnet.ibm.com, Miles Lane <miles.lane@gmail.com>,
	ilpo.jarvinen@helsinki.fi, LKML <linux-kernel@vger.kernel.org>,
	Len Brown <lenb@kernel.org>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out-105.synserver.de ([212.40.180.105]:1028 "EHLO
	smtp-out-096.synserver.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754683Ab0KHUzP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Nov 2010 15:55:15 -0500
Content-Disposition: inline
In-Reply-To: <1289249191.2790.3.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 08, 2010 at 09:46:31PM +0100, Eric Dumazet wrote:
> Le lundi 08 novembre 2010 =E0 21:42 +0100, Markus Trippelsdorf a =E9c=
rit :
> > On Mon, Nov 08, 2010 at 09:29:26PM +0100, Eric Dumazet wrote:
> > > Le lundi 08 novembre 2010 =E0 12:06 -0800, Paul E. McKenney a =E9=
crit :
> > > > On Mon, Nov 08, 2010 at 02:56:06PM -0500, Miles Lane wrote:
> > > > > WARNING: at net/ipv4/devinet.c:137 in_dev_finish_destroy+0x3d=
/0x6e()
> > > >=20
> > > > Ilpo, thoughts?
> > > >=20
> > >=20
> > > Hmm...=20
> > >=20
> > >     WARN_ON(idev->mc_list);
> > >=20
> > > Might be a problem with refcounts somewhere...
> >=20
> > I have similar warnings in my logs, although its at
> > net/ipv4/devinet.c:136 in my case. Happened altogether three times =
in
> > the last few days and they all look the same:
> >=20
> > Nov  5 17:31:35 arch kernel: WARNING: at net/ipv4/devinet.c:136 in_=
dev_finish_destroy+0x5c/0x90()
> > Nov  5 17:31:35 arch kernel: Hardware name: System Product Name
> > Nov  5 17:31:35 arch kernel: Pid: 0, comm: kworker/0:1 Not tainted =
2.6.37-rc1-00027-gff8b16d-dirty #4
> > Nov  5 17:31:35 arch kernel: Call Trace:
> > Nov  5 17:31:35 arch kernel: <IRQ>  [<ffffffff8105c9f6>] ? warn_slo=
wpath_common+0x76/0xc0
> > Nov  5 17:31:35 arch kernel: [<ffffffff8141889c>] ? in_dev_finish_d=
estroy+0x5c/0x90
> > Nov  5 17:31:35 arch kernel: [<ffffffff813c49e8>] ? dst_destroy+0x6=
8/0x120
> > Nov  5 17:31:35 arch kernel: [<ffffffff813e888f>] ? dst_rcu_free+0x=
1f/0x30
> > Nov  5 17:31:35 arch kernel: [<ffffffff81090e0c>] ? __rcu_process_c=
allbacks+0xfc/0x2f0
> > Nov  5 17:31:35 arch kernel: [<ffffffff8109103f>] ? rcu_process_cal=
lbacks+0x3f/0x70
> > Nov  5 17:31:35 arch kernel: [<ffffffff810621bc>] ? __do_softirq+0x=
9c/0x120
> > Nov  5 17:31:35 arch kernel: [<ffffffff81030fc9>] ? timer_interrupt=
+0x19/0x30
> > Nov  5 17:31:35 arch kernel: [<ffffffff8102ea4c>] ? call_softirq+0x=
1c/0x30
> > Nov  5 17:31:35 arch kernel: [<ffffffff8103080d>] ? do_softirq+0x4d=
/0x80
> > Nov  5 17:31:35 arch kernel: [<ffffffff8106232d>] ? irq_exit+0x8d/0=
x90
> > Nov  5 17:31:35 arch kernel: [<ffffffff810306c7>] ? do_IRQ+0x67/0xe=
0
> > Nov  5 17:31:35 arch kernel: [<ffffffff8144a153>] ? ret_from_intr+0=
x0/0xa
> > Nov  5 17:31:35 arch kernel: <EOI>  [<ffffffff81035ba0>] ? default_=
idle+0x20/0x40
> > Nov  5 17:31:35 arch kernel: [<ffffffff81035c12>] ? c1e_idle+0x52/0=
xf0
> > Nov  5 17:31:35 arch kernel: [<ffffffff8102c12c>] ? cpu_idle+0x4c/0=
xa0
> > Nov  5 17:31:35 arch kernel: ---[ end trace 143683935de8f41f ]---
> > Nov  5 17:31:35 arch kernel: Freeing alive in_device ffff88011ffba6=
00
> >=20
>=20
> Hmm....
>=20
> Is commit 1f1b9c9990205759aae31b7734b0ede41a867f32 present in your
> kernel ? (fib: fib_result_assign() should not change fib refcounts)

Yes, the last warning happend today on the lastest git kernel (from tod=
ay).
>=20
> Could you provide some information ?
>=20
> ifconfig -a

dummy0    Link encap:Ethernet  HWaddr 76:FE:79:D4:80:DF =20
          BROADCAST NOARP  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0=20
          RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)

eth0      Link encap:Ethernet  HWaddr 00:08:54:36:F2:2F =20
          inet addr:192.168.1.2  Bcast:192.168.1.255  Mask:255.255.255.=
0
          UP BROADCAST RUNNING MULTICAST  MTU:1492  Metric:1
          RX packets:1945 errors:0 dropped:0 overruns:0 frame:0
          TX packets:1450 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000=20
          RX bytes:1910343 (1.8 Mb)  TX bytes:177533 (173.3 Kb)
          Interrupt:20 Base address:0x6c00=20

lo        Link encap:Local Loopback =20
          inet addr:127.0.0.1  Mask:255.0.0.0
          UP LOOPBACK RUNNING  MTU:16436  Metric:1
          RX packets:18321 errors:0 dropped:0 overruns:0 frame:0
          TX packets:18321 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0=20
          RX bytes:2200368 (2.0 Mb)  TX bytes:2200368 (2.0 Mb)

> ip ro

192.168.1.0/24 dev eth0  proto kernel  scope link  src 192.168.1.2=20
default via 192.168.1.1 dev eth0

--=20
Markus
