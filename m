From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: mmotm 2010-04-28 - RCU whinges
Date: Mon, 3 May 2010 08:43:57 -0700
Message-ID: <20100503154357.GF2597@linux.vnet.ibm.com>
References: <201004290021.o3T0L04Y028017@imap1.linux-foundation.org>
 <5702.1272822394@localhost>
 <1272865137.2173.179.camel@edumazet-laptop>
 <5933.1272897014@localhost>
 <1272898726.2226.47.camel@edumazet-laptop>
 <5112.1272900590@localhost>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Valdis.Kletnieks@vt.edu
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5112.1272900590@localhost>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 03, 2010 at 11:29:50AM -0400, Valdis.Kletnieks@vt.edu wrote=
:
> On Mon, 03 May 2010 16:58:46 +0200, Eric Dumazet said:
> > Le lundi 03 mai 2010 =E0 10:30 -0400, Valdis.Kletnieks@vt.edu a =E9=
crit :
>=20
> > > [    9.129872] net/netfilter/nf_log.c:55 invoked rcu_dereference_=
check() without protection!
>=20
> > Thanks for the report !
> >=20
> > [PATCH] net: nf_log RCU fixes
> >=20
> > nf_log_register() and nf_log_unregister() use a mutex to have exclu=
sive
> > access to nf_logers[]. Use appropriate rcu_dereference_protected()
> > lockdep annotation.
>=20
> Confirming that one fixed.  Now it lives a whole 36 seconds before wh=
inging:
>=20
> [   35.328729] =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D
> [   35.328803] [ INFO: suspicious rcu_dereference_check() usage. ]
> [   35.328837] ---------------------------------------------------
> [   35.328872] net/ipv6/addrconf.c:2977 invoked rcu_dereference_check=
() without protection!
> [   35.328926]=20
> [   35.328927] other info that might help us debug this:
> [   35.328928]=20
> [   35.329016]=20
> [   35.329016] rcu_scheduler_active =3D 1, debug_locks =3D 0
> [   35.329089] 2 locks held by ifconfig/2680:
> [   35.329120]  #0:  (&p->lock){+.+.+.}, at: [<ffffffff810f5db8>] seq=
_read+0x3a/0x42d
> [   35.329217]  #1:  (rcu_read_lock_bh){.+....}, at: [<ffffffff814eec=
68>] rcu_read_lock_bh+0x0/0x35
> [   35.329322]=20
> [   35.329323] stack backtrace:
> [   35.329380] Pid: 2680, comm: ifconfig Tainted: G        W   2.6.34=
-rc5-mmotm0428 #3
> [   35.329439] Call Trace:
> [   35.329471]  [<ffffffff81064832>] lockdep_rcu_dereference+0xaa/0xb=
2
> [   35.329514]  [<ffffffff814ef3ae>] if6_get_next+0x34/0x6d
> [   35.329554]  [<ffffffff814ef3f8>] if6_seq_next+0x11/0x18
> [   35.329595]  [<ffffffff810f6083>] seq_read+0x305/0x42d
> [   35.329635]  [<ffffffff810f5d7e>] ? seq_read+0x0/0x42d
> [   35.329676]  [<ffffffff81129e8c>] proc_reg_read+0x8d/0xac
> [   35.329717]  [<ffffffff810db7e0>] vfs_read+0xe0/0x140
> [   35.329758]  [<ffffffff810db8f6>] sys_read+0x45/0x69
> [   35.329799]  [<ffffffff810025eb>] system_call_fastpath+0x16/0x1b
>=20
> Maybe I need to go and stick the "RCU whinge multiple times" patch on=
 this
> kernel and get it over with. :)

Highly recommended.  ;-)

And thanks to you for your testing efforts and to Eric for the fixes!!!

							Thanx, Paul
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
