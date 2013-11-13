From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: __refrigerator() && saved task->state
Date: Wed, 13 Nov 2013 20:40:11 +0100
Message-ID: <20131113194011.GA25590@redhat.com>
References: <1384264396-14550-1-git-send-email-geert@linux-m68k.org> <20131112141314.GQ5056@laptop.programming.kicks-ass.net> <AE90C24D6B3A694183C094C60CF0A2F6026B7405@saturn3.aculab.com> <20131112145243.GU5056@laptop.programming.kicks-ass.net> <20131112162136.GA29065@redhat.com> <20131112165643.GA31278@redhat.com> <20131113032053.GA19394@mtj.dyndns.org> <20131113170724.GA17739@redhat.com> <20131113191143.GA24005@redhat.com> <20131113191449.GF16796@laptop.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tejun Heo <tj@kernel.org>, David Rientjes <rientjes@google.com>,
	David Laight <David.Laight@ACULAB.COM>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Ingo Molnar <mingo@kernel.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14166 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752504Ab3KMTjQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Nov 2013 14:39:16 -0500
Content-Disposition: inline
In-Reply-To: <20131113191449.GF16796@laptop.programming.kicks-ass.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/13, Peter Zijlstra wrote:
>
> On Wed, Nov 13, 2013 at 08:11:43PM +0100, Oleg Nesterov wrote:
> > At first glance it would be better to simply kill this logic? If
> > it was called with ->state != 0, the caller is going to schedule()
> > and it probably executes the wait_event-like code, in this case
> > it would me more safe to pretend the task got a spurious wakeup?
>
> Note that in general the kernel cannot deal with spurious wakeups :/
>
> Most proper locks and wait primitives can, but there's enough open-coded
> crap out there that can not.

Oh yes, I understand.

My point is, "restore the old state" in this case looks worse simply
because you miss any wakeup in between which was going to clear that
state. And afaics only kthreads can call __refrigerator() in !RUNNING.

But let me repeat, I am almost sure I missed something else.

Oleg.
