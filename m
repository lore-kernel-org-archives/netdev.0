From: Jiri Olsa <jolsa@redhat.com>
Subject: Re: [PATCH] net: fix race in the receive/select
Date: Mon, 29 Jun 2009 11:24:07 +0200
Message-ID: <20090629092407.GA3845@jolsa.lab.eng.brq.redhat.com>
References: <20090625122545.GA3625@jolsa.lab.eng.brq.redhat.com> <87eit3l7y6.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	fbl@redhat.com, nhorman@redhat.com, davem@redhat.com,
	oleg@redhat.com, eric.dumazet@gmail.com
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:45076 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752016AbZF2JYU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jun 2009 05:24:20 -0400
Content-Disposition: inline
In-Reply-To: <87eit3l7y6.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 29, 2009 at 11:12:33AM +0200, Andi Kleen wrote:
> Jiri Olsa <jolsa@redhat.com> writes:
> 
> > Adding memory barrier to the __pollwait function paired with 
> > receive callbacks.  The smp_mb__after_lock define is added, 
> > since {read|write|spin}_lock() on x86 are full memory barriers.
> 
> I was wondering did you see that race actually happening in practice?
> If yes on which system?
> 
> At least on x86 I can't see how it happens. mb() is only a compile
> time barrier and the compiler doesn't optimize over indirect callbacks
> like __pollwait() anyways.
> 
> It might be still needed on some weaker ordered architectures, but did you
> actually see it there?
> 
> -Andi

yes, we have a customer that has been able to reproduce this problem on 
x86_64 CPU model Xeon E5345*2, but they didn't reproduce on XEON MV, for example.

they were able to capture a backtrace when the race happened:
https://bugzilla.redhat.com/show_bug.cgi?id=494404#c1

jirka

> 
> -- 
> ak@linux.intel.com -- Speaking for myself only.
