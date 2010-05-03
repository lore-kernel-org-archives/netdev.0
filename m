From: Valdis.Kletnieks@vt.edu
Subject: Re: mmotm 2010-04-28 - RCU whinges
Date: Mon, 03 May 2010 10:30:14 -0400
Message-ID: <5933.1272897014@localhost>
References: <201004290021.o3T0L04Y028017@imap1.linux-foundation.org> <5702.1272822394@localhost>
            <1272865137.2173.179.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1272897014_3992P";
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
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: Your message of "Mon, 03 May 2010 07:38:57 +0200."
             <1272865137.2173.179.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1272897014_3992P
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

On Mon, 03 May 2010 07:38:57 +0200, Eric Dumazet said:
> Le dimanche 02 mai 2010 =E0 13:46 -0400, Valdis.Kletnieks=40vt.edu a =
=E9crit :
> > On Wed, 28 Apr 2010 16:53:32 PDT, akpm=40linux-foundation.org said:
> > > The mm-of-the-moment snapshot 2010-04-28-16-53 has been uploaded to=

> > >=20
> > >    http://userweb.kernel.org/=7Eakpm/mmotm/
> >=20
> > I thought we swatted all these, hit another one...

> Thanks for the report =21
>=20
> We can use rcu_dereference_protected() in those cases.
>=20
> =5BPATCH=5D net: Use rcu_dereference_protected in nf_conntrack_ecache
>=20
> Writers own nf_ct_ecache_mutex.

I *really* thought we swatted a bunch of these - did the fixes not make i=
t
into linux-next or -mm?  Your patch fixed that one, but then:

=5B    9.128899=5D Netfilter messages via NETLINK v0.30.
=5B    9.128919=5D nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
=5B    9.129108=5D CONFIG_NF_CT_ACCT is deprecated and will be removed so=
on. Please use
=5B    9.129110=5D nf_conntrack.acct=3D1 kernel parameter, acct=3D1 nf_co=
nntrack module option or
=5B    9.129113=5D sysctl net.netfilter.nf_conntrack_acct=3D1 to enable i=
t.
=5B    9.129135=5D ctnetlink v0.93: registering with nfnetlink.
=5B    9.129452=5D ip_tables: (C) 2000-2006 Netfilter Core Team
=5B    9.129506=5D=20
=5B    9.129507=5D =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D
=5B    9.129683=5D =5B INFO: suspicious rcu_dereference_check() usage. =
=5D
=5B    9.129777=5D ---------------------------------------------------
=5B    9.129872=5D net/netfilter/nf_log.c:55 invoked rcu_dereference_chec=
k() without protection=21
=5B    9.129969=5D=20
=5B    9.129969=5D other info that might help us debug this:
=5B    9.129970=5D=20
=5B    9.130232=5D=20
=5B    9.130232=5D rcu_scheduler_active =3D 1, debug_locks =3D 0
=5B    9.130407=5D 1 lock held by swapper/1:
=5B    9.130525=5D  =230:  (nf_log_mutex)=7B+.+...=7D, at: =5B<ffffffff81=
481154>=5D nf_log_register+0x57/0x10f
=5B    9.130955=5D=20
=5B    9.130956=5D stack backtrace:
=5B    9.131162=5D Pid: 1, comm: swapper Tainted: G        W   2.6.34-rc5=
-mmotm0428 =232
=5B    9.131259=5D Call Trace:
=5B    9.131370=5D  =5B<ffffffff81064832>=5D lockdep_rcu_dereference+0xaa=
/0xb2
=5B    9.131466=5D  =5B<ffffffff814811db>=5D nf_log_register+0xde/0x10f
=5B    9.131579=5D  =5B<ffffffff81b5ca28>=5D ? log_tg_init+0x0/0x29
=5B    9.131689=5D  =5B<ffffffff81b5ca4d>=5D log_tg_init+0x25/0x29
=5B    9.131800=5D  =5B<ffffffff810001ef>=5D do_one_initcall+0x59/0x14e
=5B    9.131912=5D  =5B<ffffffff81b2e68a>=5D kernel_init+0x144/0x1ce
=5B    9.132033=5D  =5B<ffffffff81003414>=5D kernel_thread_helper+0x4/0x1=
0
=5B    9.132146=5D  =5B<ffffffff81598a40>=5D ? restore_args+0x0/0x30
=5B    9.132257=5D  =5B<ffffffff81b2e546>=5D ? kernel_init+0x0/0x1ce
=5B    9.132370=5D  =5B<ffffffff81003410>=5D ? kernel_thread_helper+0x0/0=
x10
=5B    9.132513=5D TCP bic registered


--==_Exmh_1272897014_3992P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFL3t32cC3lWbTT17ARAnHZAKDsjVB7Wi33joDQ7XLQYLE/VdWHhwCfctm9
Dr+hG66IoB+LNumLreUZys8=
=zFgM
-----END PGP SIGNATURE-----

--==_Exmh_1272897014_3992P--

