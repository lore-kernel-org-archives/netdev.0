From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 2.6.27-rc8 5/6] e1000e: debug contention on NVM SWFLAG
Date: Fri, 3 Oct 2008 08:16:16 -0700 (PDT)
Message-ID: <alpine.LFD.2.00.0810030812570.3230@nehalem.linux-foundation.org>
References: <20081002233314.12556.49143.stgit@jbrandeb-bw.jf.intel.com> <20081002233340.12556.33137.stgit@jbrandeb-bw.jf.intel.com> <Pine.LNX.4.64.0810031346100.1532@twin.jikos.cz>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	arjan@linux.intel.com, airlied@gmail.com, davem@davemloft.net,
	Jeff Garzik <jeff@garzik.org>
To: Jiri Kosina <jkosina@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:43846 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752294AbYJCPRO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2008 11:17:14 -0400
In-Reply-To: <Pine.LNX.4.64.0810031346100.1532@twin.jikos.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Fri, 3 Oct 2008, Jiri Kosina wrote:
> 
> The debugging message is racy anyway with respect to accessing nvm_owner, 
> right? It should be done after the mutex has been succesfully acquired.

It's done that way on purpose - to see who _could_ be racing.

After the mutex, it could never trigger, because the mutex is the thing 
that guarantees non-racy-ness.

IOW, it's a debugging message just to see that the old bug (the "before 
the fix") really did happen. We can/will remove it, but I think people are 
still looking at the e1000e driver and probably want to see the paths that 
can cause problems.

Of course, it's entirely possible that we should remove it in mainline 
already, and just let the people inside intel/suse/xyzzy who are trying to 
reproduce it have it.

Jesse? Thomas?

			Linus
