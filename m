From: Mike Anderson <andmike@us.ibm.com>
Subject: Re: [2.6.23 PATCH 14/18] dm: netlink add to core
Date: Thu, 12 Jul 2007 16:41:59 -0700
Message-ID: <20070712234159.GC4768@us.ibm.com>
References: <20070711210159.GF24114@agk.fab.redhat.com> <20070711143423.36722a41.akpm@linux-foundation.org> <m1bqehfyp0.fsf@ebiederm.dsl.xmission.com> <20070712173410.GA2505@us.ibm.com> <m1wsx5e7lk.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Alasdair G Kergon <agk@redhat.com>, dm-devel@redhat.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:41889 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756416AbXGLXmH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jul 2007 19:42:07 -0400
Content-Disposition: inline
In-Reply-To: <m1wsx5e7lk.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman <ebiederm@xmission.com> wrote:
> As for worry about kmallocs do these events happen often?  
The worst case would most likely be in a dm multipath configuration where
you could get a burst of N number events (N being equal to the number of
luns times the number of paths that are having an issue).

> I would
> not expect any of them in the normal course of operation for a system.

Yes, the ones that are part of this patch are unexpected events or
recovery of the unexpected event. 

> Worst case you handle extra kmallocs with a library function.
> It's not like you are using GFP_ATOMIC.

I was using GFP_ATOMIC as I did not want __GFP_IO as in some testing there
was a case where heavy file system IO was going on and an injected error
event caused the swap device into a temporary queued condition while an
event was trying to be sent. I may need to go back and investigate this
case on recent kernels as it has been a while since I did the test case.

-andmike
--
Michael Anderson
andmike@us.ibm.com
