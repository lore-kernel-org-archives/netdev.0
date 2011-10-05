From: Andi Kleen <andi@firstfloor.org>
Subject: Re: big picture UDP/IP performance question re 2.6.18  -> 2.6.32
Date: Wed, 05 Oct 2011 08:12:44 -0700
Message-ID: <m2mxdf4glv.fsf@firstfloor.org>
References: <6.2.5.6.2.20111003112108.03a83a28@binnacle.cx>
	<alpine.DEB.2.00.1110041358500.12199@router.home>
	<1317820942.6766.26.camel@twins>
	<alpine.DEB.2.00.1110050915160.30467@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, starlight@binnacle.cx,
	Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Willy Tarreau <w@1wt.eu>, Ingo Molnar <mingo@elte.hu>
To: Christoph Lameter <cl@gentwo.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.1110050915160.30467@router.home> (Christoph
	Lameter's message of "Wed, 5 Oct 2011 09:26:24 -0500 (CDT)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christoph Lameter <cl@gentwo.org> writes:

> On Wed, 5 Oct 2011, Peter Zijlstra wrote:
>
>> Clearly none of the tests being ran on a regular basis, by for instance
>> the Intel regression team, covers your needs. Start by fixing that.
>
> The most commonly run, the aged old tests contained in the AIM9 suite,
> have consistently shown these regressions over long years and they have
> been brought up repeatedly in numerous discussions. This is pervasive
> thoughout the OS hotpaths. Just look at how the page fault latencies
> change over time. Take a modern machine and then run successively older
> kernel versions on it. You will see performance getting better and
> latencies becoming smaller.

One of the reason the Intel tests fix problems is that Alex and Tim
and others look into them and track down regressions. If you see
a new problem during your testing you should do the same.
This actually helps.

It doesn't need to be a full analysis/patch, even just posting some detailed
information on a new regression is useful.

For example one tool I found useful is to just enable the function
graph tracer and look at the latencies of functions in that path
during the test. 

If something changes dramatically it's relatively easy to point to.

So for example if you see context switch changing it should not 
be that difficult to do such a trace and at least point to the guilty
functions and post a mail.

>> Also, for latency, we've got ftrace and a latencytracer, provide traces
>> that illustrate your fail.
>
> We would need a backport of both to a kernel version that works with
> reasonable latencies so that we can figure out what caused these
> regressions for this particular case. Disabling network and kernel
> features usually gives you better performance but there are a lot of
> things in the hot paths these days that can not be disabled.

Please do function traces and point fingers at slow things in hotpath.
The more the merrier. Post a list of a shame!

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only
