From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH 1/4] inet: Add skb_copy_datagram_iter
Date: Mon, 10 Nov 2014 09:09:55 +0000
Message-ID: <20141110090955.GH7996@ZenIV.linux.org.uk>
References: <20141109211908.GF7996@ZenIV.linux.org.uk>
 <20141110.002020.1062493586889118565.davem@davemloft.net>
 <20141110065817.GG7996@ZenIV.linux.org.uk>
 <20141110.023000.1275181784917275552.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, bcrl@kvack.org, mst@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141110.023000.1275181784917275552.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 10, 2014 at 02:30:00AM -0500, David Miller wrote:
> From: Al Viro <viro@ZenIV.linux.org.uk>
> Date: Mon, 10 Nov 2014 06:58:17 +0000
> 
> > On Mon, Nov 10, 2014 at 12:20:20AM -0500, David Miller wrote:
> >> From: Al Viro <viro@ZenIV.linux.org.uk>
> >> Date: Sun, 9 Nov 2014 21:19:08 +0000
> >> 
> >> > 1) does sparc64 access_ok() need to differ for 32bit and 64bit tasks?
> >> 
> >> sparc64 will just fault no matter what kind of task it is.
> >> 
> >> It is impossible for a user task to generate a reference to
> >> a kernel virtual address, as kernel and user accesses each
> >> go via a separate address space identifier.
> > 
> > Sure, but why do we have access_ok() there at all?  I.e. why not just have
> > it constant 1?
> 
> Since access_ok() is in fact constant 1 on sparc64, where we use it,
> does it really matter?

*blink*

My apologies - I've got confused by the maze of twisty includes, all alike.
Right you are; in biarch case it *doesn't* depend on 32bit vs. 64bit.
STACK_TOP-using one is sparc32 variant where we obviously don't have
biarch at all.

Anyway, the series switching to {compat_,}rw_copy_check_uvector() and
getting rid of duplicate checks is in vfs.git#iov_iter-net.  Warning:
it's almost completely untested.  It survives boot, ssh into it and
runltp -f syscalls (no regressions), but that's about it.  BTW, what's
the usual regression suite used for net/* stuff?

3 commits in there, on top of net-next#master; head should be at 555126.
There's a bunch of fairly obvious followups becoming possible after that,
but let's keep those separate...
