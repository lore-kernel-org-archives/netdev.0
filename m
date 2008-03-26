From: Chris Snook <csnook@redhat.com>
Subject: Re: [git patches] net driver updates for .26
Date: Wed, 26 Mar 2008 12:24:00 -0400
Message-ID: <47EA78A0.1040801@redhat.com>
References: <20080318075902.GA18010@havoc.gtf.org> <20080322.183522.124237568.davem@davemloft.net> <47E9CBF9.3040700@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Jay Cliburn <jacliburn@bellsouth.net>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:54570 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756552AbYCZQ0W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2008 12:26:22 -0400
In-Reply-To: <47E9CBF9.3040700@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Garzik wrote:
> David Miller wrote:
>> From: Jeff Garzik <jeff@garzik.org>
>> Date: Tue, 18 Mar 2008 03:59:02 -0400
>>
>>> Just sent this upstream to davem for 2.6.26...  snipped the patch I
>>> usually post along with a git push, due to mailing list restrictions.
>>>
>>> Please pull from 'upstream-net26' branch of
>>> master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git 
>>> upstream-net26
>>
>> This fails an allmodconfig build:
>>
>> drivers/net/8390.c: In function '__inittest':
>> drivers/net/8390.c:60: error: 'ns8390_init_module' undeclared (first 
>> use in this function)
>> drivers/net/8390.c:60: error: (Each undeclared identifier is reported 
>> only once
>> drivers/net/8390.c:60: error: for each function it appears in.)
>>
>> The fix was easy so I took care of it, this time...
> 
> hrm, indeed.  sorry about that.  Something clearly screwed up in my 
> process, because part of that process is an x86-64 allmodconfig before 
> pushing.
> 
> 
>> There was also a merge conflict in drivers/s390/net/qeth_main.c
>> (against a net-2.6.26 change, which is why you really should work
>> against that for 2.6.26 bound changes not against Linus's head as you
>> did here), which is easy to resolve by putting the conflicting change
>> to qeth_main.c into the inetdev notifier in qeth_l3_main.c, which
>> I took care of as well.
>>
>> This time....
> 
> I mentioned this one on IRC ahead of time, when I asked if it was OK, as 
> an exception, to base off Linus's HEAD.  This was because I had started 
> my for-2.6.26 queue a while before you did.
> 
> And just to state the obvious, unless you and I agree on an exception 
> (which I thought we had done this time), all changes from me will be 
> based on top of your repo(s) rather than Linus's.
> 
> 
>> There are also some new build warnings such as:
>>
>> drivers/net/atlx/atl1.c:506: warning: 'atl1_phy_enter_power_saving' 
>> defined but not used
> 
> <checks>  doesn't appear in allmodconfig, so it looks like 
> atl1_phy_enter_power_saving() just needs some CONFIG_PM wrappers
> 
> (hi Jay, Chris)
> 
> 
>> Which I fixed up as well, but that atl1_phy_enter_power_saving()
>> function is just a jumble of commented out code, yuck!  Please
>> review some of this stuff :-/
> 
> I did not see anything wrong with a maintainer leaving in some 
> commented-out placeholder code.
> 
> Some of this stuff should get filled in once Chris and Jay add atl2 
> support to the existing atl1 stuff you see here.
> 
> That was a big impetus for this set of atl1 changes -- move things 
> around and massage things so that it is trivial to drop in atl2 support.
> 
>     Jeff
> 
> 

I'm working on that integration now.  There are a lot of slight 
differences between atl1 and atl2 that are due mostly to atl1 having 
been in-tree for a while and getting cleaned up.  Confirming that it's 
safe to make the corresponding changes to the atl2 code has taken longer 
than I'd like, but after that's done and we have initial support merged, 
there will be a rather thorough review.  It seemed better to do that 
once on the merged code than duplicate the effort on the two codebases.

I'll be posting the initial atl2 patch Real Soon Now.

-- Chris
