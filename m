From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH] NETLABEL: Fix an RCU warning
Date: Mon, 29 Mar 2010 16:05:48 -0400
Message-ID: <201003291605.48605.paul.moore@hp.com>
References: <20100325110621.5348.32020.stgit@warthog.procyon.org.uk> <201003291130.10752.paul.moore@hp.com> <20100329155857.GG2569@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Howells <dhowells@redhat.com>, netdev@vger.kernel.org
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0184.atlanta.hp.com ([15.193.32.61]:31070 "EHLO
	g6t0184.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751631Ab0C2UFv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 16:05:51 -0400
In-Reply-To: <20100329155857.GG2569@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 29 March 2010 11:58:57 am Paul E. McKenney wrote:
> On Mon, Mar 29, 2010 at 11:30:10AM -0400, Paul Moore wrote:
> > On Monday 29 March 2010 11:24:53 am Paul E. McKenney wrote:
> > > On Thu, Mar 25, 2010 at 12:28:04PM +0100, Eric Dumazet wrote:
> > > > Le jeudi 25 mars 2010 =E0 11:06 +0000, David Howells a =E9crit =
:
> > > > > Fix an RCU warning in the netlabel code due to missing rcu re=
ad
> > > > > locking around an rcu_dereference() in netlbl_unlhsh_hash() w=
hen
> > > > > called from netlbl_unlhsh_netdev_handler():
> > > > >=20
> > > > > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D
> > > > > [ INFO: suspicious rcu_dereference_check() usage. ]
> > > > > ---------------------------------------------------
> > > > > net/netlabel/netlabel_unlabeled.c:246 invoked
> > > > > rcu_dereference_check() without protection!

=2E..

> > As Eric pointed out in response to the message above, I believe the
> > solution is to simply remove the rcu_dereference() call in the
> > netlbl_unlhsh_hash() function.
>=20
> It would be at the moment, but this will break once Arnd Bergmann get=
s
> his sparse-based checks done.  With these checks, we decorate RCU-pro=
tected
> pointers, and then sparse yells if you access such a pointer without =
the
> proper rcu_dereference() invocation.

Okay, is there a recommended approach towards accessing RCU-protected p=
ointers=20
both under a RCU read lock and under only a spinlock (or similar lock=20
construct)?  I know I could do something based on querying the state of=
 the=20
RCU/etc. locks but that seems like a hack and could interfere with some=
 of the=20
logic used to detect coding problems.

--=20
paul moore
linux @ hp
