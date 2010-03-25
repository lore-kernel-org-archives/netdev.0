From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH] NETLABEL: Fix an RCU warning
Date: Thu, 25 Mar 2010 10:10:44 -0400
Message-ID: <201003251010.45128.paul.moore@hp.com>
References: <1269516484.3626.21.camel@edumazet-laptop> <6522.1269517044@redhat.com> <1269523940.3626.37.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Howells <dhowells@redhat.com>, netdev@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:35042 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754146Ab0CYOKt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Mar 2010 10:10:49 -0400
In-Reply-To: <1269523940.3626.37.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 25 March 2010 09:32:20 am Eric Dumazet wrote:
> Le jeudi 25 mars 2010 =C3=A0 11:37 +0000, David Howells a =C3=A9crit =
:
> > Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > > Sorry this is not the right fix.
> > >=20
> > > Fix is to change the dereference check to take into account the l=
ock
> > > owned here.
> >=20
> > Then the comments on netlbl_unlhsh_hash(), netlbl_unlhsh_search_ifa=
ce(),
> > netlbl_unlhsh_search_iface_def() and netlbl_unlhsh_add_iface() are =
all
> > wrong,
> >=20
> > for all of them say:
> > 	* The caller is responsible for calling the rcu_read_[un]lock()
> > 	* functions.
> >=20
> > Furthermore, netlabel_unlhsh_add() and netlabel_unlhsh_remove() _do=
_ wrap
> > the calls to those functions in rcu_read_lock'd sections.
>=20
> Current code is probably fine.
> Comments are not up to date (as many other comments BTW)
>=20
> Only the dereference check is bad, as it assumes the rcu_read lock is
> held.
>=20
> Its not the case, we own a spinlock.
>=20
> You suggest adding a surrounding rcu lock, but this surrounding lock
> adds overhead on normal kernels, to correct checker warnings only.

The rcu_dereference call, and the outdated comments for that matter, ar=
e=20
likely artifacts from an early patch.  When the code was originally bei=
ng=20
developed I had assumed that you _always_ needed to hold the RCU read l=
ock=20
when doing RCU operations, regardless of if you were already holding th=
e=20
associated spinlock.  Thankfully, Paul McKenney was able to review the =
code=20
and helped me to understand RCU a bit better, unfortunately, it looks l=
ike I=20
still missed a few spots :/

Give me a day or two to go through the comments again and do some sanit=
y=20
checks and I'll send out a patch.  However, if you've already got somet=
hing=20
that is tested and ready to go don't let me stand in your way.

--=20
paul moore
linux @ hp
