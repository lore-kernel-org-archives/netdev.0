From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: serious netpoll bug w/NAPI
Date: Wed, 16 Feb 2005 17:07:01 -0500
Message-ID: <16915.50181.990040.174776@segfault.boston.redhat.com>
References: <20050208201634.03074349.davem@davemloft.net>
	<20050209183219.GA2366@waste.org>
	<20050209164658.409f8950.davem@davemloft.net>
	<20050210011104.GF2366@waste.org>
	<16914.31886.665975.522710@segfault.boston.redhat.com>
	<20050216050722.GC3358@waste.org>
Reply-To: jmoyer@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
To: Matt Mackall <mpm@selenic.com>
In-Reply-To: <20050216050722.GC3358@waste.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

==> Regarding Re: serious netpoll bug w/NAPI; Matt Mackall <mpm@selenic.com> adds:

mpm> On Tue, Feb 15, 2005 at 05:49:50PM -0500, Jeff Moyer wrote:
>> ==> Regarding Re: serious netpoll bug w/NAPI; Matt Mackall <mpm@selenic.com> adds:
>> 
[snip]
>> 
>> Okay, I've only taken a quick glance at this, but I don't quite understand
>> why it's safe to take out the check for the per-cpu queue.  Realize that an
>> interrupt may have been serviced on another processor, and a NAPI poll may
>> have been scheduled there.

mpm> Because dev->np->poll_lock now serializes all access to ->poll (when
mpm> netpoll is enabled on said device).

>> Also, could you use the -p flag to diff when you generate your next patch?
>> It makes it *much* easier to review.

mpm> Hmm, somehow my QUILT_DIFF_OPTS got lost, thanks.

mpm> I've just now recovered my SMP+NAPI box, so I can take a stab at
mpm> actually testing this shortly.

I put together a patch against our kernel tree which implements essentially
the same logic as your patch, and it works great:  I was able to reproduce
the bug without the patch, and the patched kernel is running just fine.
Let me know when you have another version of your patch, and I will happily
test it in my environment.

Thanks,

Jeff
