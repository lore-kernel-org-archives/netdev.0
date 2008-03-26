From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [git patches] net driver updates for .26
Date: Wed, 26 Mar 2008 00:07:21 -0400
Message-ID: <47E9CBF9.3040700@garzik.org>
References: <20080318075902.GA18010@havoc.gtf.org> <20080322.183522.124237568.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Chris Snook <csnook@redhat.com>,
	Jay Cliburn <jacliburn@bellsouth.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:34881 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750776AbYCZEHY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2008 00:07:24 -0400
In-Reply-To: <20080322.183522.124237568.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Jeff Garzik <jeff@garzik.org>
> Date: Tue, 18 Mar 2008 03:59:02 -0400
> 
>> Just sent this upstream to davem for 2.6.26...  snipped the patch I
>> usually post along with a git push, due to mailing list restrictions.
>>
>> Please pull from 'upstream-net26' branch of
>> master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-net26
> 
> This fails an allmodconfig build:
> 
> drivers/net/8390.c: In function '__inittest':
> drivers/net/8390.c:60: error: 'ns8390_init_module' undeclared (first use in this function)
> drivers/net/8390.c:60: error: (Each undeclared identifier is reported only once
> drivers/net/8390.c:60: error: for each function it appears in.)
> 
> The fix was easy so I took care of it, this time...

hrm, indeed.  sorry about that.  Something clearly screwed up in my 
process, because part of that process is an x86-64 allmodconfig before 
pushing.


> There was also a merge conflict in drivers/s390/net/qeth_main.c
> (against a net-2.6.26 change, which is why you really should work
> against that for 2.6.26 bound changes not against Linus's head as you
> did here), which is easy to resolve by putting the conflicting change
> to qeth_main.c into the inetdev notifier in qeth_l3_main.c, which
> I took care of as well.
> 
> This time....

I mentioned this one on IRC ahead of time, when I asked if it was OK, as 
an exception, to base off Linus's HEAD.  This was because I had started 
my for-2.6.26 queue a while before you did.

And just to state the obvious, unless you and I agree on an exception 
(which I thought we had done this time), all changes from me will be 
based on top of your repo(s) rather than Linus's.


> There are also some new build warnings such as:
> 
> drivers/net/atlx/atl1.c:506: warning: 'atl1_phy_enter_power_saving' defined but not used

<checks>  doesn't appear in allmodconfig, so it looks like 
atl1_phy_enter_power_saving() just needs some CONFIG_PM wrappers

(hi Jay, Chris)


> Which I fixed up as well, but that atl1_phy_enter_power_saving()
> function is just a jumble of commented out code, yuck!  Please
> review some of this stuff :-/

I did not see anything wrong with a maintainer leaving in some 
commented-out placeholder code.

Some of this stuff should get filled in once Chris and Jay add atl2 
support to the existing atl1 stuff you see here.

That was a big impetus for this set of atl1 changes -- move things 
around and massage things so that it is trivial to drop in atl2 support.

	Jeff


