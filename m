From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: __refrigerator() && saved task->state
Date: Wed, 13 Nov 2013 20:14:49 +0100
Message-ID: <20131113191449.GF16796@laptop.programming.kicks-ass.net>
References: <1384264396-14550-1-git-send-email-geert@linux-m68k.org>
 <20131112141314.GQ5056@laptop.programming.kicks-ass.net>
 <AE90C24D6B3A694183C094C60CF0A2F6026B7405@saturn3.aculab.com>
 <20131112145243.GU5056@laptop.programming.kicks-ass.net>
 <20131112162136.GA29065@redhat.com>
 <20131112165643.GA31278@redhat.com>
 <20131113032053.GA19394@mtj.dyndns.org>
 <20131113170724.GA17739@redhat.com>
 <20131113191143.GA24005@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tejun Heo <tj@kernel.org>, David Rientjes <rientjes@google.com>,
	David Laight <David.Laight@ACULAB.COM>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Ingo Molnar <mingo@kernel.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Oleg Nesterov <oleg@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:38248 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754062Ab3KMTO6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Nov 2013 14:14:58 -0500
Content-Disposition: inline
In-Reply-To: <20131113191143.GA24005@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 13, 2013 at 08:11:43PM +0100, Oleg Nesterov wrote:
> At first glance it would be better to simply kill this logic? If
> it was called with ->state != 0, the caller is going to schedule()
> and it probably executes the wait_event-like code, in this case
> it would me more safe to pretend the task got a spurious wakeup?

Note that in general the kernel cannot deal with spurious wakeups :/

Most proper locks and wait primitives can, but there's enough open-coded
crap out there that can not.

I tried..
