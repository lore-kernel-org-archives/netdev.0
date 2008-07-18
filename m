From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [bug, netconsole, SLUB] BUG skbuff_head_cache: Poison
	overwritten
Date: Fri, 18 Jul 2008 11:09:51 +0200
Message-ID: <20080718090951.GP6875@elte.hu>
References: <20080717214222.GA29449@elte.hu> <20080718054626.GA3338@2ka.mipt.ru> <84144f020807180202l6c703234ic3a2b57e73a1d89a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Vegard Nossum <vegard.nossum@gmail.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:47644 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753369AbYGRJKa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jul 2008 05:10:30 -0400
Content-Disposition: inline
In-Reply-To: <84144f020807180202l6c703234ic3a2b57e73a1d89a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Pekka Enberg <penberg@cs.helsinki.fi> wrote:

> On Fri, Jul 18, 2008 at 8:46 AM, Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> > Does SLUB have a debug check at freeing time? If so, how does it work
> > and why didn't it caught use after free there?
> 
> You can't detect use after free before the object is actually free'd 
> ;-)

yeah, we want to check use-after free at the next allocation point - 
i.e. as late as possible to gather all corruptions that happened 
meanwhile.

We could in theory have a SLUB debug mode where a SCHED_IDLE kernel 
thread would periodically check all free objects (of that CPU) in the 
background to ensure their integrity. That would catch corruptions 
sooner, with a possibly still meaningful context to print out. [right 
after the IRQ or process that corrupts them finishes running]

It could also be hooked into ftrace to print out the last few hundred 
kernel function calls executed prior any corruption. ftrace/slub-debug 
plugin perhaps?

	Ingo
