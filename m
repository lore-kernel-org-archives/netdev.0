From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: Re: WARNING: at net/ipv4/tcp_input.c:2927 tcp_ack+0xd55/0x1991()
Date: Tue, 31 Mar 2009 20:49:59 +0200
Message-ID: <20090331184959.GA2725@gentoox2.trippelsdorf.de>
References: <20090327211202.GA10014@gentoox2.trippelsdorf.de> <Pine.LNX.4.64.0903280031080.5904@wrl-59.cs.helsinki.fi> <20090328045056.GA2394@gentoox2.trippelsdorf.de> <Pine.LNX.4.64.0903280930440.6696@wrl-59.cs.helsinki.fi> <20090328095514.GA2599@gentoox2.trippelsdorf.de> <Pine.LNX.4.64.0903301155150.30150@wrl-59.cs.helsinki.fi> <20090330164035.GA2652@gentoox2.trippelsdorf.de> <Pine.LNX.4.64.0903302137100.29272@wrl-59.cs.helsinki.fi> <20090331071018.GA2641@gentoox2.trippelsdorf.de> <Pine.LNX.4.64.0903311205070.30150@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1764002AbZCaSwv@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0903311205070.30150@wrl-59.cs.helsinki.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 31, 2009 at 12:16:51PM +0300, Ilpo J=E4rvinen wrote:
> On Tue, 31 Mar 2009, Markus Trippelsdorf wrote:
>=20
> > On Mon, Mar 30, 2009 at 09:52:55PM +0300, Ilpo J=E4rvinen wrote:
> > > On Mon, 30 Mar 2009, Markus Trippelsdorf wrote:
> > >=20
> > > > On Mon, Mar 30, 2009 at 07:01:22PM +0300, Ilpo J=E4rvinen wrote=
:
> > > > > On Sat, 28 Mar 2009, Markus Trippelsdorf wrote:
> > > > > > On Sat, Mar 28, 2009 at 10:29:58AM +0200, Ilpo J=E4rvinen w=
rote:
> > > > >=20
> > > > > ...And, let me guess, you're in X and therefore unable to cat=
ch a final=20
> > > > > oops if any would be printed? It would be nice to get around =
that as well,=20
> > > > > either use serial/netconsole or hang in text mode while waiti=
ng for the=20
> > > > > crash (should be too hard if you are able to setup the worklo=
ad first=20
> > > > > and then switch away from X and if reproducing takes about an=
 hour)...
> > > >=20
> > > > OK, I will try this later.
> > >=20
> > > Lets hope that gives some clue where it ends up going boom (if it=
 is=20
> > > caused by TCP we certainly should see something more sensible in =
console=20
> > > than just a hang)... ...I once again read through tcp commits but=
 just=20
> > > cannot find anything that could cause fackets_out miscount, not t=
o speak=20
> > > of crash prone changes so we'll just have to wait and see...
> >=20
> > The machine hanged again this night and I took two pictures:
> > http://www.mypicx.com/uploadimg/1055813374_03302009_2.jpg
> > http://www.mypicx.com/uploadimg/1543678904_03302009_1.jpg
> >
> > But this time there was no tcp related warning in the logs.
>=20
> Right. If that oops would be hit often enough one can easily mix the=20
> warning with that hang though there is no relation (the fact that fin=
al=20
> oops always goes unnoticed in X amplifies the effect).
>=20
> > I then pulled the lateset git changes, rebuild, rebooted and setup =
the
> > workload again. The machine was still up and running in the morning=
=20
> > (~4 hours uptime). So it may well be that the issue was fixed with
> > the latest changes.
>=20
> Lets hope so, in any case if you still see hangs please get the final=
 oops.
>=20
> > If it ever occurs again I will notify you.

It happend again. In this case it took ~10 minutes from the warning to
the final crash. I'm pretty sure there must be some kind of relation
between the two. How else could one explain that the machine crashes ju=
st
minutes after _each_ instance of that WARNING?

(Unfortunately I was in X again, because I thought this problem was
solved)

------------[ cut here ]------------
WARNING: at net/ipv4/tcp_input.c:2927 tcp_ack+0xd5b/0x19a6()
Hardware name: To Be Filled By O.E.M.
Pid: 0, comm: swapper Not tainted 2.6.29-06608-g15f7176 #2
Call Trace:
 <IRQ>  [<ffffffff8022b9ee>] warn_slowpath+0xaa/0xd1
 [<ffffffff80233f7b>] ? lock_timer_base+0x27/0x4d
 [<ffffffff80234065>] ? mod_timer+0xc4/0xd6
 [<ffffffff804c5b41>] ? _spin_unlock_bh+0xf/0x11
 [<ffffffff80233f7b>] ? lock_timer_base+0x27/0x4d
 [<ffffffff80234065>] ? mod_timer+0xc4/0xd6
 [<ffffffff8048e76b>] tcp_ack+0xd5b/0x19a6
 [<ffffffff8048f67e>] ? tcp_validate_incoming+0x4c/0x2bd
 [<ffffffff8048ff14>] tcp_rcv_established+0x625/0x87d
 [<ffffffff804af95a>] ? nf_nat_fn+0x13a/0x150
 [<ffffffff80496484>] tcp_v4_do_rcv+0x31/0x1b7
 [<ffffffff80464417>] ? sk_filter+0x72/0x7f
 [<ffffffff80496a3b>] tcp_v4_rcv+0x431/0x630
 [<ffffffff8046a914>] ? nf_hook_slow+0x65/0xc6
 [<ffffffff8047d82a>] ip_local_deliver_finish+0xbc/0x146
 [<ffffffff8047d926>] ip_local_deliver+0x72/0x79
 [<ffffffff8047d4bf>] ip_rcv_finish+0x293/0x2bf
 [<ffffffff8047d736>] ip_rcv+0x24b/0x283
 [<ffffffff804589c1>] netif_receive_skb+0x22c/0x24a
 [<ffffffff803d940d>] skge_poll+0x4bd/0x624
 [<ffffffff8045733c>] net_rx_action+0x71/0x13a
 [<ffffffff802304e1>] __do_softirq+0x79/0x138
 [<ffffffff8021c13c>] ? ack_apic_level+0x48/0xe4
 [<ffffffff8020be3c>] call_softirq+0x1c/0x28
 [<ffffffff8020d670>] do_softirq+0x34/0x76
 [<ffffffff80230201>] irq_exit+0x3f/0x7c
 [<ffffffff8020cf4d>] do_IRQ+0xa9/0xc0
 [<ffffffff8020b713>] ret_from_intr+0x0/0xa
 <EOI>  [<ffffffff8021129f>] ? default_idle+0x2d/0x42
 [<ffffffff8020a199>] ? enter_idle+0x20/0x22
 [<ffffffff8020a1ed>] ? cpu_idle+0x52/0x95
---[ end trace 4787b4dcb14517b0 ]---

--=20
Markus
