From: "Chris Leech" <christopher.leech@intel.com>
Subject: Re: [PATCH 1/9] ioatdma: Push pending transactions to hardware more frequently
Date: Fri, 2 Mar 2007 22:00:00 -0800
Message-ID: <41b516cb0703022200t50f8ad62wfa04030f11649ff2@mail.gmail.com>
References: <20070303022238.31033.84558.stgit@gitlost.site>
	 <20070303022417.31033.72244.stgit@gitlost.site>
	 <45E8E81F.8070805@garzik.org>
	 <20070302.202706.95898424.davem@davemloft.net>
Reply-To: chris.leech@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.224]:36109 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933386AbXCCGAB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Mar 2007 01:00:01 -0500
Received: by nz-out-0506.google.com with SMTP id s1so1087386nze
        for <netdev@vger.kernel.org>; Fri, 02 Mar 2007 22:00:00 -0800 (PST)
In-Reply-To: <20070302.202706.95898424.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > This sounds like something that will always be wrong -- or in other
> > words, always be right for only the latest CPUs.  Can this be made
> > dynamic, based on some timing factor?
>
> In fact I think this has been tweaked twice in the vanilla tree
> already.

This is actually just the same tweak you remember me posting before
and I never pushed to get it in mainline, but Jeff's right.  The
problem isn't so much in the driver itself, as in how it's used by
I/OAT in the TCP receive code, there are inherent assumptions about
how long a context switch takes compared to how long an offloaded
memcpy takes.

I'm working on using completion interrupts for the device so as not to
end up polling when the CPUs are faster than the code was tuned for,
and doing it in a way that doesn't introduce extra context switches.
I'm hoping to have something ready for 2.6.22, or at least ready for
MM in that time frame.

As for this change in the short term, we did go back and make sure
that it didn't performance worse with the older CPUs supported on
these platforms.  We should have tested more intermediate values
instead of just jumping from 1 t o 20 for that threshold.

- Chris
