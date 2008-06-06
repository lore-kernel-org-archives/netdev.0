From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [fixed] [patch] Re: [bug] stuck localhost TCP connections,
	v2.6.26-rc3+
Date: Fri, 6 Jun 2008 19:33:39 +0200
Message-ID: <20080606173339.GA30894@elte.hu>
References: <Pine.LNX.4.64.0806032245490.3474@wrl-59.cs.helsinki.fi> <Pine.LNX.4.64.0806040052270.3474@wrl-59.cs.helsinki.fi> <20080603.150344.145518113.davem@davemloft.net> <Pine.LNX.4.64.0806040208350.7315@wrl-59.cs.helsinki.fi> <20080605142244.GA19216@elte.hu> <Pine.LNX.4.64.0806052059380.31672@wrl-59.cs.helsinki.fi> <Pine.LNX.4.64.0806052355420.2522@wrl-59.cs.helsinki.fi> <1212708571.19522.10.camel@tng> <Pine.LNX.4.64.0806061248410.16829@wrl-59.cs.helsinki.fi> <1212772293.23706.22.camel@tng>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	David Miller <davem@davemloft.net>, peterz@infradead.org,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>, rjw@sisk.pl,
	Andrew Morton <akpm@linux-foundation.org>, johnpol@2ka.mipt.ru
To: Patrick McManus <mcmanus@ducksong.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:34420 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752588AbYFFReT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jun 2008 13:34:19 -0400
Content-Disposition: inline
In-Reply-To: <1212772293.23706.22.camel@tng>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Patrick McManus <mcmanus@ducksong.com> wrote:

> When I apply the locking patch you (Ilpo) wrote, I cannot reproduce 
> the error at all in the first 90 minutes of testing. I'll let the test 
> run and update the list.
> 
> I'm holding out hope that Ingo's report did not have the locking patch 
> on the distcc server end - because it certainly makes a difference for 
> me.

Hm, the distcc server had the full 3-patch-revert from Ilpo, was that 
supposed to fix the problem too, indirectly?

The box is running that 3-patch revert right now as well:

 phoenix:~> uptime
  19:20:28 up  9:58,  2 users,  load average: 7.75, 13.88, 30.95
 phoenix:~> uname -a
 Linux phoenix 2.6.26-rc4 #2352 SMP Fri Jun 6 09:18:07 CEST 2008 x86_64 x86_64 x86_64 GNU/Linux

... and i never saw a single hang today in the 10 hours of uptime this 
box has. (and it built a good 500 kernel today) Nor any hang yesterday, 
and that was a good 500 kernels too.

You can see it that the box built more than two thousand kernels in the 
past few days alone, so it's a rather busy little bee. The other 
testboxes built even more kernels - a quad box built and booted 2500 
kernels:

 #define UTS_VERSION "#2524 SMP PREEMPT Fri Jun 6 19:22:21 CEST 2008"

and i never saw a hang on that box either. 

a third box has:

 titan:~> uname -a
 Linux titan 2.6.26-rc5-00002-g737697d-dirty #2557 SMP PREEMPT Fri Jun 6 
 19:24:00 CEST 2008 x86_64 x86_64 x86_64 GNU/Linux

(this is the one that showed the hang for the first time)

The total count of kernel bootups i did this week for -tip QA was 
somewhere between five and ten thousand random build+bootups - and the 
only time i got a hang was when i removed the 3-patch-revert 
intentionally, on one of the boxes.

Maybe that 3-patch-revert just makes this locking bug a bit less likely 
to trigger, by accident? Out tip test-setup is specialized to find 
arch/x86 and scheduler bugs, not primarily to find networking bugs. (but 
at this test volume, and given that it makes use of distcc, it will 
trigger them too.)

i have a rather accurate timeline of when the hang first occured, do we 
know the timeline of the introduction of the locking bug by any chance? 
Which commit introduced it? (Ilpo's commit log does not say it)

Your test results are compelling nevertheless so i'll do a retest in any 
case, with all boxes either running an older kernel or a kernel with the 
locking fix.

	Ingo
