From: Yong Zhang <yong.zhang0@gmail.com>
Subject: Re: Kernel rwlock design, Multicore and IGMP
Date: Fri, 12 Nov 2010 21:00:17 +0800
Message-ID: <20101112130017.GA9752@zhy>
References: <AANLkTikvT=x9eBovn2-m6HLqk7wyXSAR3sc9jCQ0C6mL@mail.gmail.com>
 <1289489007.17691.1310.camel@edumazet-laptop>
 <AANLkTik93QUQxSDmwd4Qj-gXQiWWPzd68JPAYAHBAsHR@mail.gmail.com>
 <20101112071323.GB5660@cr0.nay.redhat.com>
 <1289546874.17691.1774.camel@edumazet-laptop>
 <20101112081945.GA5949@cr0.nay.redhat.com>
 <AANLkTik-KDvc2fgH91vBHGT6vqxbZrv=9DoQknujPWy2@mail.gmail.com>
 <20101112091818.GB5949@cr0.nay.redhat.com>
Reply-To: Yong Zhang <yong.zhang0@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Cypher Wu <cypher.w@gmail.com>, linux-kernel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20101112091818.GB5949@cr0.nay.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 12, 2010 at 05:18:18PM +0800, Am=C3=A9rico Wang wrote:
> On Fri, Nov 12, 2010 at 05:09:45PM +0800, Yong Zhang wrote:
> >On Fri, Nov 12, 2010 at 4:19 PM, Am=C3=A9rico Wang <xiyou.wangcong@g=
mail.com> wrote:
> >> On Fri, Nov 12, 2010 at 08:27:54AM +0100, Eric Dumazet wrote:
> >>>Le vendredi 12 novembre 2010 =C3=A0 15:13 +0800, Am=C3=A9rico Wang=
 a =C3=A9crit :
> >>>> On Fri, Nov 12, 2010 at 11:32:59AM +0800, Cypher Wu wrote:
> >>>> >On Thu, Nov 11, 2010 at 11:23 PM, Eric Dumazet <eric.dumazet@gm=
ail.com> wrote:
> >>>> >> Le jeudi 11 novembre 2010 =C3=A0 21:49 +0800, Cypher Wu a =C3=
=A9crit :
> >>>> >>
> >>>> >> Hi
> >>>> >>
> >>>> >> CC netdev, since you ask questions about network stuff _and_ =
rwlock
> >>>> >>
> >>>> >>
> >>>> >>> I'm using TILEPro and its rwlock in kernel is a liitle diffe=
rent than
> >>>> >>> other platforms. It have a priority for write lock that when=
 tried it
> >>>> >>> will block the following read lock even if read lock is hold=
 by
> >>>> >>> others. Its code can be read in Linux Kernel 2.6.36 in
> >>>> >>> arch/tile/lib/spinlock_32.c.
> >>>> >>
> >>>> >> This seems a bug to me.
> >>>> >>
> >>>> >> read_lock() can be nested. We used such a schem in the past i=
n iptables
> >>>> >> (it can re-enter itself),
> >>>> >> and we used instead a spinlock(), but with many discussions w=
ith lkml
> >>>> >> and Linus himself if I remember well.
> >>>> >>
> >>>> >It seems not a problem that read_lock() can be nested or not si=
nce
> >>>> >rwlock doesn't have 'owner', it's just that should we give
> >>>> >write_lock() a priority than read_lock() since if there have a =
lot
> >>>> >read_lock()s then they'll starve write_lock().
> >>>> >We should work out a well defined behavior so all the
> >>>> >platform-dependent raw_rwlock has to design under that principl=
e.
> >>>>
> >>>
> >>>AFAIK, Lockdep allows read_lock() to be nested.
> >>>
> >>>> It is a known weakness of rwlock, it is designed like that. :)
> >>>>
> >>>
> >>>Agreed.
> >>>
> >>
> >> Just for record, both Tile and X86 implement rwlock with a write-b=
ias,
> >> this somewhat reduces the write-starvation problem.
> >
> >Are you sure(on x86)?
> >
> >It seems that we never realize writer-bias rwlock.
> >
>=20
> Try
>=20
> % grep RW_LOCK_BIAS -nr arch/x86
>=20
> *And* read the code to see how it works. :)

If read_lock()/write_lock() fails, the subtracted value(1 for
read_lock() and RW_LOCK_BIAS for write_lock()) is added back.
So reader and writer will contend on the same lock fairly.

And RW_LOCK_BIAS based rwlock is a variant of sighed-test
rwlock, so it works in the same way to highest-bit-set mode
rwlock.

Seem you're cheated by it's name(RW_LOCK_BIAS). :)
Or am I missing something?

Thanks,
Yong

>=20
> Note, on Tile, it uses a little different algorithm.
