From: Valdis.Kletnieks@vt.edu
Subject: Re: mmotm 2010-04-28 - RCU whinges
Date: Mon, 03 May 2010 11:29:50 -0400
Message-ID: <5112.1272900590@localhost>
References: <201004290021.o3T0L04Y028017@imap1.linux-foundation.org> <5702.1272822394@localhost> <1272865137.2173.179.camel@edumazet-laptop> <5933.1272897014@localhost>
            <1272898726.2226.47.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1272900590_4168P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: Your message of "Mon, 03 May 2010 16:58:46 +0200."
             <1272898726.2226.47.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1272900590_4168P
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

On Mon, 03 May 2010 16:58:46 +0200, Eric Dumazet said:
> Le lundi 03 mai 2010 =E0 10:30 -0400, Valdis.Kletnieks=40vt.edu a =E9cr=
it :

> > =5B    9.129872=5D net/netfilter/nf_log.c:55 invoked rcu_dereference_=
check() without protection=21

> Thanks for the report =21
>=20
> =5BPATCH=5D net: nf_log RCU fixes
>=20
> nf_log_register() and nf_log_unregister() use a mutex to have exclusive=

> access to nf_logers=5B=5D. Use appropriate rcu_dereference_protected()
> lockdep annotation.

Confirming that one fixed.  Now it lives a whole 36 seconds before whingi=
ng:

=5B   35.328729=5D =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D
=5B   35.328803=5D =5B INFO: suspicious rcu_dereference_check() usage. =
=5D
=5B   35.328837=5D ---------------------------------------------------
=5B   35.328872=5D net/ipv6/addrconf.c:2977 invoked rcu_dereference_check=
() without protection=21
=5B   35.328926=5D=20
=5B   35.328927=5D other info that might help us debug this:
=5B   35.328928=5D=20
=5B   35.329016=5D=20
=5B   35.329016=5D rcu_scheduler_active =3D 1, debug_locks =3D 0
=5B   35.329089=5D 2 locks held by ifconfig/2680:
=5B   35.329120=5D  =230:  (&p->lock)=7B+.+.+.=7D, at: =5B<ffffffff810f5d=
b8>=5D seq_read+0x3a/0x42d
=5B   35.329217=5D  =231:  (rcu_read_lock_bh)=7B.+....=7D, at: =5B<ffffff=
ff814eec68>=5D rcu_read_lock_bh+0x0/0x35
=5B   35.329322=5D=20
=5B   35.329323=5D stack backtrace:
=5B   35.329380=5D Pid: 2680, comm: ifconfig Tainted: G        W   2.6.34=
-rc5-mmotm0428 =233
=5B   35.329439=5D Call Trace:
=5B   35.329471=5D  =5B<ffffffff81064832>=5D lockdep_rcu_dereference+0xaa=
/0xb2
=5B   35.329514=5D  =5B<ffffffff814ef3ae>=5D if6_get_next+0x34/0x6d
=5B   35.329554=5D  =5B<ffffffff814ef3f8>=5D if6_seq_next+0x11/0x18
=5B   35.329595=5D  =5B<ffffffff810f6083>=5D seq_read+0x305/0x42d
=5B   35.329635=5D  =5B<ffffffff810f5d7e>=5D ? seq_read+0x0/0x42d
=5B   35.329676=5D  =5B<ffffffff81129e8c>=5D proc_reg_read+0x8d/0xac
=5B   35.329717=5D  =5B<ffffffff810db7e0>=5D vfs_read+0xe0/0x140
=5B   35.329758=5D  =5B<ffffffff810db8f6>=5D sys_read+0x45/0x69
=5B   35.329799=5D  =5B<ffffffff810025eb>=5D system_call_fastpath+0x16/0x=
1b

Maybe I need to go and stick the =22RCU whinge multiple times=22 patch on=
 this
kernel and get it over with. :)


--==_Exmh_1272900590_4168P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFL3uvucC3lWbTT17ARAuZxAKCk9ywIgNhKPIKqFAu0ppWMYSZnqACg63/W
yGUHCD1JYszl3WwoVGHmh6g=
=H+GJ
-----END PGP SIGNATURE-----

--==_Exmh_1272900590_4168P--
