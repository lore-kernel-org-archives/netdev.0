From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] fasync: RCU locking
Date: Wed, 14 Apr 2010 17:34:24 +0200
Message-ID: <1271259264.16881.1703.camel@edumazet-laptop>
References: <1271230961.16881.630.camel@edumazet-laptop>
	 <4BC57E7D.9060706@cn.fujitsu.com>
	 <1271257027.16881.1663.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
To: Lai Jiangshan <laijs@cn.fujitsu.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1271257027.16881.1663.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 14 avril 2010 =C3=A0 16:57 +0200, Eric Dumazet a =C3=A9crit=
 :
> Le mercredi 14 avril 2010 =C3=A0 16:36 +0800, Lai Jiangshan a =C3=A9c=
rit :
>=20
> > Since rcu_read_lock() protects fasync_struct *fa for us, we can acc=
ess
> > to @fa safely even fasync_remove_entry() is just called.
> >=20
> > But this patch does not ensure 'fa->fa_file is not freed' nor
> > 'fa->fa_fd is not released', so kill_fasync_rcu() may do wrong thin=
g
> > if there is no other code ensure it.
>=20
> You are 100% right, I forgot my old attempt to RCUified struct files
> failed...
>=20
> Maybe its time to finally move f_owner out of struct file, and use RC=
U
> to free it.
>=20
> In the mean time, adding a lock in fasync_struct is more than enough.
>=20
> Thanks !
>=20
> [PATCH net-next-2.6 v2] fasync: fine grained locking
>=20
> kill_fasync() uses a central rwlock, candidate for RCU conversion, to
> avoid cache line ping pongs on SMP.
>=20
> fasync_remove_entry() and fasync_add_entry() can disable IRQS on a sh=
ort
> section instead during whole list scan.
>=20
> Use a spinlock per fasync_struct to synchronize fasync_{remove|
> add}_entry() and kill_fasync_rcu()
>=20
> We can remove __kill_fasync() direct use in net, and rename it to
> kill_fasync_rcu().
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

Please wait for a v3 version, as net/socket.c sock_fasync() should be
updated too...
