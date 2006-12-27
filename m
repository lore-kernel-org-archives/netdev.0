From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] igmp: spin_lock_bh in timer (Re: BUG: soft lockup detected on CPU#0!)
Date: Wed, 27 Dec 2006 09:24:00 +0100
Message-ID: <20061227082400.GA2070@ff.dom.local>
References: <45889C53.8000307@candelatech.com> <20061222071308.GA1791@ff.dom.local> <20061222074209.GA2148@ff.dom.local> <458BE61E.9030004@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.go2.pl ([193.17.41.42]:53249 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752165AbWL0IWk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Dec 2006 03:22:40 -0500
To: Ben Greear <greearb@candelatech.com>
Content-Disposition: inline
In-Reply-To: <458BE61E.9030004@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 22, 2006 at 06:05:18AM -0800, Ben Greear wrote:
> Jarek Poplawski wrote:
> >On Fri, Dec 22, 2006 at 08:13:08AM +0100, Jarek Poplawski wrote:
> >>On 20-12-2006 03:13, Ben Greear wrote:
> >>>This is from 2.6.18.2 kernel with my patch set.  The MAC-VLANs are in 
> >>>active use.
> >>> From the backtrace, I am thinking this might be a generic problem, 
> >>>however.
> >>>
> >>>Any ideas about what this could be?  It seems to be reproducible every 
> >>>day or
> >...
> >>If it doesn't help, I hope lockdep will be more
> >>precise when you'll upgrade to 2.6.19 or higher.
> >
> >... or when you enable lockdep in 2.6.18 (I've
> >forgotten it's there alredy!).
> 
> I got lucky..the system was available by ssh still.  I see this in the boot 
> logs..I assume
> this means lockdep is enabled?  Should I have expected to see a lockdep 
> trace in the case of
> his soft-lockup then?
> 
> .....
> Dec 19 04:33:48 localhost kernel: Lock dependency validator: Copyright (c) 
> 2006 Red Hat, Inc., Ingo MolnarDec 19 04:33:48 localhost kernel: ... 
> MAX_LOCKDEP_SUBCLASSES:    8

Yes, you got it enabled in the config.

If there is no message later about validator
turning off and no warnings which could point
at lockdep then it is working.

But then, IMHO, there is rather small probability
this bug is really from lockup. Another possibility
is hardware irqs (timer in particular) are turned
off by something (maybe those hacks?) for extremely
long time (~10 sec.). 
 
Regards,
Jarek P.
