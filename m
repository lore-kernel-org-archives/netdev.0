From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: 2.6.29-rc8: Reported regressions from 2.6.28
Date: Mon, 16 Mar 2009 12:57:18 -0700 (PDT)
Message-ID: <alpine.LFD.2.00.0903161250080.3082@localhost.localdomain>
References: <MiincthRUSI.A.eKC.F4BvJB@chimera>  <b6a2187b0903141958u9dae0fdk1f44b387108b99e4@mail.gmail.com>  <b6a2187b0903142006u546fad9eme66f9ea7b464b81f@mail.gmail.com>  <1237140665.24621.2.camel@johannes.local>  <alpine.LFD.2.00.0903151136310.3131@localhost.localdomain>
  <1237143683.24621.7.camel@johannes.local>  <20090315202603.GA9077@elte.hu> <b6a2187b0903160624gb9d207dv301506e589d93ed4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ingo Molnar <mingo@elte.hu>,
	Johannes Berg <johannes@sipsolutions.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Adrian Bunk <bunk@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>
To: Jeff Chua <jeff.chua.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:49288 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754174AbZCPUGV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2009 16:06:21 -0400
In-Reply-To: <b6a2187b0903160624gb9d207dv301506e589d93ed4@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Mon, 16 Mar 2009, Jeff Chua wrote:
> 
> Take the attached bisect log and replay it

Taking a bisect log is repeatable, but pointless.

If you made any mistakes in bisecting (marking a kernel that was good as 
being bad, or the other way around), the log will always replay to the 
same thing, but it will still be wrong.

In other words, "git bisect" is only as reliable as the data you feed it, 
and if the behavior isn't 100% repeatable and unambiguous (or if you 
simply made a mistake), you need to double-check things.

So after bisecting a commit, if there is any question what-so-ever whether 
the commit makes sense as a result, you need to double-check it. The best 
way to double-check it is to go back to a known-bad state (preferably the 
tip of the branch) and revert the presumed-bad commit, and verify that it 
really fixes the behavior.

But if that is impossible (for example, because the commit no longer 
reverts cleanly), at least make 100% sure that the state at the commit is 
bad, and then go to (all) parents of that commit and make 100% sure that 
the state at those points is _good_. 

IOW, if you've pinpointed 71c11fb57b924c160297ccd9e1761db598d00ac2 as 
being bad, then you should go back and double-check that its parent 
(in this case 4607816f608b42a5379aca97ceed08378804c99f) is good.

Because if it's parent is also bad, then that just means that you made 
some mistake in "git bisect".

The thing about bisecting is that it is _extremely_ efficient. It takes 
essentially the minimal number of answers to get to the end result. But 
that very efficiency also means that getting even just _one_ of those 
answers wrong will take you _way_ off base. There's no room for error, 
because bisect will take each bit and use it to maximally split the error 
space.

In this case, it really sounds like maybe you marked the parent good, even 
though you should have marked it bad.

			Linus
