From: David Miller <davem@davemloft.net>
Subject: Re: [patch 13/26] Xen-paravirt_ops: Consistently wrap paravirt ops
	callsites to make them patchable
Date: Thu, 12 Apr 2007 16:16:23 -0700 (PDT)
Message-ID: <20070412.161623.71575524.davem@davemloft.net>
References: <45FF770C.7050301@goop.org>
	<Pine.LNX.4.64.0703200805450.6730@woody.linux-foundation.org>
	<17920.30274.608018.34484@cargo.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: xen-devel@lists.xensource.com, virtualization@lists.osdl.org,
   netdev@vger.kernel.org, linux-kernel@vger.kernel.org, chrisw@sous-sol.org,
   ak@muc.de, ebiederm@xmission.com, anthony@codemonkey.ws, mingo@elte.hu,
   torvalds@linux-foundation.org, akpm@linux-foundation.org
To: paulus@samba.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <17920.30274.608018.34484@cargo.ozlabs.ibm.com>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Paul Mackerras <paulus@samba.org>
Date: Wed, 21 Mar 2007 11:03:14 +1100

> Linus Torvalds writes:
> =

> > We should just do this natively. There's been several tests over the ye=
ars =

> > saying that it's much more efficient to do sti/cli as a simple store, a=
nd =

> > handling the "oops, we got an interrupt while interrupts were disabled"=
 as =

> > a special case.
> > =

> > I have this dim memory that ARM has done it that way for a long time =

> > because it's so expensive to do a "real" cli/sti.
> > =

> > And I think -rt does it for other reasons. It's just more flexible.
> =

> 64-bit powerpc does this now as well.

I was curious about this so I had a look.

There appears to be three pieces of state used to manage this
on powerpc, PACASOFTIRQEN(r13), PACAHARDIRQEN(r13) and the
SOFTE() in the stackframe.

Plus there is all of this complicated logic on trap entry and
exit to manage these three values properly.

local_irq_restore() doesn't look like a simple piece of code
either.  Logically it should be simple, update the software
binary state, and if enabling see if any interrupts came in
while we were disable so we can run them.

Given all of that, is it really cheaper than just flipping the
bit in the cpu control register? :-/
