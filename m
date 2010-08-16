From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [LOCKDEP BUG][2.6.36-rc1] xt_info_wrlock?
Date: Mon, 16 Aug 2010 21:16:17 +0200
Message-ID: <1281986177.1926.1858.camel@laptop>
References: <1281978469.3268.55.camel@gandalf.stny.rr.com>
	 <1281979893.2524.54.camel@edumazet-laptop>
	 <1281981301.3268.110.camel@gandalf.stny.rr.com>
	 <1281982566.3268.137.camel@gandalf.stny.rr.com>
	 <1281983814.1926.1763.camel@laptop>
	 <1281984528.2487.25.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Steven Rostedt <rostedt@goodmis.org>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, Ingo Molnar <mingo@elte.hu>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1281984528.2487.25.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2010-08-16 at 20:48 +0200, Eric Dumazet wrote:
> Le lundi 16 ao=C3=BBt 2010 =C3=A0 20:36 +0200, Peter Zijlstra a =C3=A9=
crit :
> > On Mon, 2010-08-16 at 14:16 -0400, Steven Rostedt wrote:
> > > @@ -729,8 +729,10 @@  static void get_counters(const struct
> > > xt_table_info *t,
> > >         local_bh_enable();
> > >         /* Processing counters from other cpus, we can let bottom=
 half
> > > enabled,
> > >          * (preemption is disabled)
> > > +        * We must turn off lockdep to avoid a false positive.
> > >          */
> > > =20
> > > +       lockdep_off();
> > >         for_each_possible_cpu(cpu) {
> > >=20
> > nack!
>=20
>=20
> Interesting.
>=20
> Care to elaborate ?

Adding lockdep_off() is just plain wrong, if you cannot describe the
locking there's a fair chance its wrong anyway.

As it stands there's only a single lockdep_off(), and that lives in NTF=
S
it looks like it could be annotated differently, but then, who cares
about NTFS anyway ;-)
