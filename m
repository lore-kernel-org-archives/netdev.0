From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCHv5 2/2] memory barrier: adding smp_mb__after_lock
Date: Wed, 8 Jul 2009 01:51:49 +0200
Message-ID: <20090707235149.GA10268@redhat.com>
References: <20090707101816.GA6619@jolsa.lab.eng.brq.redhat.com> <20090707134601.GB6619@jolsa.lab.eng.brq.redhat.com> <20090707140135.GA5506@Krystal> <20090707143416.GB11704@redhat.com> <20090707150406.GC7124@Krystal> <20090707154440.GA15605@redhat.com> <1246981815.9777.12.camel@twins> <20090707194533.GB13858@Krystal> <4A53CFDC.6080005@gmail.com> <20090707232811.GC19217@Krystal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Jiri Olsa <jolsa@redhat.com>, Ingo Molnar <mingo@elte.hu>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	fbl@redhat.com, nhorman@redhat.com, davem@redhat.com,
	htejun@gmail.com, jarkao2@gmail.com, davidel@xmailserver.org
To: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:33898 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756198AbZGGXzD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jul 2009 19:55:03 -0400
Content-Disposition: inline
In-Reply-To: <20090707232811.GC19217@Krystal>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/07, Mathieu Desnoyers wrote:
>
> * Eric Dumazet (eric.dumazet@gmail.com) wrote:
> >
> > What would be __read_lock() ? I cant see how it could *not* use lock prefix
> > actually and or being cheaper...
> >
>
> (I'll use read_lock_noacquire() instead of __read_lock() because
> __read_lock() is already used for low-level primitives and will produce
> name clashes. But I recognise that noacquire is just an ugly name.)
>
> Here, a __read_lock_noacquire _must_ be followed by a
> smp__mb_after_lock(), and a __read_unlock_norelease() _must_ be
> preceded by a smp__mb_before_unlock().

Your point was, smp_mb__after_lock() adds more complexity to the
barriers/locking rules.

Do you really think __read_lock_noacquire() makes this all more
simple/understandable? And again, we need __read_lock_irq_noaquire/etc.

Personally, I disagree. In fact, I do not understand when/why
_noacquire can be used, but this is another story.

Let's look from the different angle. The first patch from Jiri fixes
the bug. Yes, it is not clear if this is possible to trigger this
bug in practice, but still nobody disagrees the bug does exist.
The second patch fixes the added pessimization.

So, if you do not agree with these patches, perhaps you can send
fixes on top of these changes?



Sadly, I already removed the previous emails so I can't add my
acked-by to Jiri's patches. I didn't do this before because I
thought I am in no position to ack these changes. But looking
at this discussion, I'd like to vote for both these patches
anyway ;)

Oleg.

