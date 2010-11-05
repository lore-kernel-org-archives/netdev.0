From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] atomic: add atomic_inc_not_zero_hint()
Date: Fri, 05 Nov 2010 19:20:24 +0100
Message-ID: <1288981224.2882.1105.camel@edumazet-laptop>
References: <1288975980.2882.877.camel@edumazet-laptop>
	 <20101105102038.53e36f9e.akpm@linux-foundation.org>
	 <1288980046.2882.1054.camel@edumazet-laptop>
	 <20101105110828.52f061b3.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Christoph Lameter <cl@linux-foundation.org>,
	Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Nick Piggin <npiggin@kernel.dk>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:56411 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753134Ab0KESU3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Nov 2010 14:20:29 -0400
In-Reply-To: <20101105110828.52f061b3.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 05 novembre 2010 =C3=A0 11:08 -0700, Andrew Morton a =C3=A9=
crit :
> On Fri, 05 Nov 2010 19:00:46 +0100
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>=20
> > Le vendredi 05 novembre 2010 __ 10:20 -0700, Andrew Morton a __crit=
 :
> >=20
> > > It totally makes sense to add include/linu/atomic.h for common th=
ings.=20
> > > Perhaps there's already code in arch/*/include/asm/atomic.h which
> > > should be hoisted up there.  But that can't reliably be done unti=
l a
> > > million files have had their #includes switched :(
> > >=20
> >=20
> > Maybe including <linux/atomic.h> only from the end of various
> >=20
> > arch/*/include/asm/atomic.h  ?
>=20
> heh, I guess that would work.  It breaks the standard way of doing
> these things (I think?) so let's not go there unless we have a need?
>=20
> > In this case, I remove the include <asm/atomic.h> from linux/atomic=
=2Eh
>=20
> Oh.  Why?  I thought it was better the previous, standard way: thou
> shalt henceforth include liunx/atomic.h, not asm/atomic.h.  And the
> presence of linux/atomic.h will in fact trigger the checkpatch warnin=
g
> telling people to use that when they try to use asm/atomic.h.

Hmm, if we want to move the common stuff from
arch/*/include/asm/atomic.h to this new file (include/linux/atomic.h),
then we would have to change hundred of=20

#include <asm/atomic.h>=20

to

#include <linux/atomic.h>=20

This seems a big task to me ?

Or just make a whole tree replace ?



