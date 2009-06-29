From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] net: fix race in the receive/select
Date: Mon, 29 Jun 2009 11:12:33 +0200
Message-ID: <87eit3l7y6.fsf@basil.nowhere.org>
References: <20090625122545.GA3625@jolsa.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	fbl@redhat.com, nhorman@redhat.com, davem@redhat.com,
	oleg@redhat.com, eric.dumazet@gmail.com
To: Jiri Olsa <jolsa@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:42505 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751263AbZF2JMb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jun 2009 05:12:31 -0400
In-Reply-To: <20090625122545.GA3625@jolsa.lab.eng.brq.redhat.com> (Jiri Olsa's message of "Thu, 25 Jun 2009 14:25:45 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Olsa <jolsa@redhat.com> writes:

> Adding memory barrier to the __pollwait function paired with 
> receive callbacks.  The smp_mb__after_lock define is added, 
> since {read|write|spin}_lock() on x86 are full memory barriers.

I was wondering did you see that race actually happening in practice?
If yes on which system?

At least on x86 I can't see how it happens. mb() is only a compile
time barrier and the compiler doesn't optimize over indirect callbacks
like __pollwait() anyways.

It might be still needed on some weaker ordered architectures, but did you
actually see it there?

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
