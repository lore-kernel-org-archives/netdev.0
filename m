From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: >Re: [RFC] should VM_BUG_ON(cond) really evaluate cond
Date: Sun, 30 Oct 2011 18:59:53 +0100
Message-ID: <1319997593.13597.76.camel@edumazet-laptop>
References: <1319772566.6759.27.camel@deadeye>
	 <1319777025.23112.67.camel@edumazet-laptop>
	 <CA+55aFzHf563auNYdNeJnsbbry1OUfkepkiVHt7Fy-bG64Fruw@mail.gmail.com>
	 <1319803781.23112.113.camel@edumazet-laptop>
	 <CA+55aFxzgc5pC1p6J8YADNDwmAjUYNRKLvir6OQMueWqUXOaEQ@mail.gmail.com>
	 <CA+55aFxy6VSBbikFrfXwUPOafihR+MOdi+yKSp_6qz7_Vax_YA@mail.gmail.com>
	 <1319813252.23112.122.camel@edumazet-laptop>
	 <CA+55aFxvcvUopBc-Q6Fp87asTuBohev8Xdm67jcKfy4Z4_BZRg@mail.gmail.com>
	 <CA+55aFz=sxRjw6u-ww0P=9hhvWaZP=+QJZ68W+B9WtvQqj9Ogg@mail.gmail.com>
	 <1319964754.13597.26.camel@edumazet-laptop>
	 <20111030095918.GA19676@one.firstfloor.org>
	 <1319987765.13597.60.camel@edumazet-laptop>
	 <CA+55aFyGEhBMv31QXN7q9PJc36TVtHLOvdFYB1+6NTo+nKSkbQ@mail.gmail.com>
	 <1319996494.13597.69.camel@edumazet-laptop>
	 <CA+55aFz-mp8k7qdF3LaOjgX19TbzrCirGuCmGwqVMq9SwQ8yvw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andi Kleen <andi@firstfloor.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFz-mp8k7qdF3LaOjgX19TbzrCirGuCmGwqVMq9SwQ8yvw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le dimanche 30 octobre 2011 =C3=A0 10:48 -0700, Linus Torvalds a =C3=A9=
crit :
> On Sun, Oct 30, 2011 at 10:41 AM, Eric Dumazet <eric.dumazet@gmail.co=
m> wrote:
> >
> > Changing atomic_read(const atomic_t *v) prototype to
> > atomic_read(atomic_t *v) is not an option.
>=20
> Why not?
>=20
>     #define atomic_read(v)     ACCESS_AT_MOST_ONCE((v)->counter)
>=20
> seems to be the cleanest thing.
>=20

As I said, because v can be a const pointer provided by the caller.

Try it yourself and you'll discover hundred of call sites doing

=2E... some_function(const struct *xxx, ...)
{
	if (atomic_read(&xxx->refcnt) <=3D 0)
		do_something();
	else
		do_otherthing();
}

> And if you don't think this is "an option", I really can't see why yo=
u
> care about the extra instructions in the code stream either.
>=20

Not an option if we have to change all callers that expected to be able
to use a const atomic_t pointer.

OK, I now have to leave the net.
