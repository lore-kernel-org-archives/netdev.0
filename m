From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] kthread: NUMA aware kthread_create_on_cpu()
Date: Mon, 29 Nov 2010 10:05:10 +0100
Message-ID: <20101129090510.GA15763@basil.fritz.box>
References: <1290972833.29196.90.camel@edumazet-laptop>
 <20101128224024.GA12300@basil.fritz.box>
 <1290984712.29196.100.camel@edumazet-laptop>
 <20101128230146.GB12300@basil.fritz.box>
 <1290987424.29196.128.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andi Kleen <andi@firstfloor.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, Tejun Heo <tj@kernel.org>,
	Rusty Russell <rusty@rustcorp.com.au>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1290987424.29196.128.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 29, 2010 at 12:37:04AM +0100, Eric Dumazet wrote:
> Le lundi 29 novembre 2010 =E0 00:01 +0100, Andi Kleen a =E9crit :
> > On Sun, Nov 28, 2010 at 11:51:51PM +0100, Eric Dumazet wrote:
> > > > Also this messes up the policy of the caller process. You reall=
y
> > > > need to save/restore it.
> > >=20
> > > Well, caller process duty is to create kthreads in a loop.
> >=20
> > In this case any other allocations it may do
> >  are still on those
> > nodes.
>=20
> As I said, it does only create_kthread() calls, and no "other
> allocations".

Code changes. Your current setup seems fragile (also
the static variable)

> > > > for the stack, so may be a larger patch.
> > >=20
> > > I suggest arches that need slab to allocate kthread stacks do the
> > > appropriate changes, because I am not able to make them myself.
> > >=20
> > > On x86, we use page allocator only, so NUMA mempolicy is used.
> >=20
> > task_struct is always allocated from slab.
>=20
> Hmm, I meant stack (the thing that might be trashed a lot in ksoftirq=
d),
> so it is included in struct thread_info

task_struct is quite hot too. Also your original mail said
task struct i believe.

> And got correct stacks. Are you sure we must use PREFERRED ?

Yes.

-Andi

--=20
ak@linux.intel.com -- Speaking for myself only.
