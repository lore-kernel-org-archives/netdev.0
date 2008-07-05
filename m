From: Ingo Molnar <mingo@elte.hu>
Subject: Re: Oops/Warning report of the week of July 4th 2008
Date: Sat, 5 Jul 2008 08:39:18 +0200
Message-ID: <20080705063917.GA11599@elte.hu>
References: <486EA0D6.2040504@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dave Jones <davej@redhat.com>
To: Arjan van de Ven <arjan@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:50668 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750881AbYGEGjl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Jul 2008 02:39:41 -0400
Content-Disposition: inline
In-Reply-To: <486EA0D6.2040504@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Arjan van de Ven <arjan@linux.intel.com> wrote:

> Rank 8: tick_broadcast_oneshot_control (softlockup)
> 	Reported 91 times (634 total reports)
>
> 	Some interaction between tickless and systems with an AMD CPU 
> 	and an ATI chipset (eg only seen on systems that both have an 
> 	AMD cpu and an ATI chipset) Current suspicion is some kind of 
> 	time-warp problem that causes the softlockup code to trigger 
> 	incorrectly
>
>       This softlockup was last seen in version 2.6.25.9,
> 	and first seen in 2.6.24-rc4. More info:
>
> 	http://www.kerneloops.org/searchweek.php?search=tick_broadcast_oneshot_control

ok, so it's a false positive due to bad timer readout, not a real 
lockup. That probably also explains how it was able to show up in such 
numbers - the system kept functioning just fine so every system that 
produced this warning was able to report it to kerneloops.org.

i'll think about extending the softlockup code with time warp detection 
and reporting - that would be a useful facility in itself as right now 
there's nothing that warns about time warps in monotonic system time.

	Ingo
