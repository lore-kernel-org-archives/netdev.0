From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [LOCKDEP BUG][2.6.36-rc1] xt_info_wrlock?
Date: Mon, 16 Aug 2010 22:17:30 +0200
Message-ID: <1281989850.2487.64.camel@edumazet-laptop>
References: <1281978469.3268.55.camel@gandalf.stny.rr.com>
	 <1281979893.2524.54.camel@edumazet-laptop>
	 <1281981301.3268.110.camel@gandalf.stny.rr.com>
	 <1281982566.3268.137.camel@gandalf.stny.rr.com>
	 <1281983814.1926.1763.camel@laptop>
	 <1281984528.2487.25.camel@edumazet-laptop>
	 <1281986177.1926.1858.camel@laptop>
	 <1281987352.2487.40.camel@edumazet-laptop>
	 <1281988895.1926.1945.camel@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Steven Rostedt <rostedt@goodmis.org>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, Ingo Molnar <mingo@elte.hu>
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1281988895.1926.1945.camel@laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 16 ao=C3=BBt 2010 =C3=A0 22:01 +0200, Peter Zijlstra a =C3=A9c=
rit :
> On Mon, 2010-08-16 at 21:35 +0200, Eric Dumazet wrote:
> > Le lundi 16 ao=C3=BBt 2010 =C3=A0 21:16 +0200, Peter Zijlstra a =C3=
=A9crit :
> >=20
> > > Adding lockdep_off() is just plain wrong, if you cannot describe =
the
> > > locking there's a fair chance its wrong anyway.
> > >=20
> >=20
> > I see.
> >=20
> > I described the fine locking after Steven comment, adding a long
> > Changelog.
> >=20
> > http://patchwork.ozlabs.org/patch/61827/
> >=20
> > If someone thinks this locking is buggy, please speak now ;)
>=20
> Urgh,.. I think it might be correct, but wtf! Wasn't this originally =
RCU
> code, why not go back to using RCU now that we have
> synchronize_rcu_expedited()?
>=20
> As to the original issue, why not keep that bh stuff disabled for
> CONFIG_PROVE_LOCKING instead, that will at least let you keep lock
> coverage, adding lockdep_off() will hide any cycles that would involv=
e
> this lock (even though its currently a leaf lock, you never know what
> creative things the future brings).
>=20
> This fancy open coded lock looks like utter fail for -rt though.. ple=
ase
> use RCU if at all possible.
>=20
>=20

Please read history of why RCU failed in this context.

I believe I did most of RCU conversions in kernel, you dont need to
shout on me.

And its a bit late in 2.6.36 to even think about it.

I am happy that you volunteer for next RCU conversion, thanks Peter !

In the mean time, we just are going to disable BH again, I'll post a
patch.
