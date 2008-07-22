From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 1/6] ipv6: use timer pending
Date: Tue, 22 Jul 2008 12:10:02 -0700
Message-ID: <4886308A.3050604@candelatech.com>
References: <20080721192834.221648982@vyatta.com>	<20080721192919.971385103@vyatta.com>	<488518BF.1090207@candelatech.com> <20080722120453.114615dc@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:35960 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751283AbYGVTKJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2008 15:10:09 -0400
In-Reply-To: <20080722120453.114615dc@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Mon, 21 Jul 2008 16:16:15 -0700
> Ben Greear <greearb@candelatech.com> wrote:
> 
>> Stephen Hemminger wrote:
>>> This fixes the bridge reference count problem and cleanups ipv6 FIB timer management.
>>> Don't use expires field, because it is not a proper way to test,
>>> instead use timer_pending().
>> I patched this into my 2.6.25, and it does not seem to help
>> my refcount problem.  I did not apply any of your other
>> patches as it seemed they were mostly cleanups.
>>
>> This is not to say that this patch is wrong...but
>> it seems we'll have to keep looking for other problems
>> as well.
> 
> I agree this patch is not a direct fix for the the problem. What happened
> was that I was retesting on latest 2.6 net kernel and adding tracing
> and checking.  In the process, the problem went away. Either
> a Heisenbug or some other part of the configuration changed.

Patrick sent me a debugging patch and we're poking at the problem.

Currently, it seems we are leaking in6_dev refcounts...possibly
due to a timer leak, but it's tricky code (for me, at least).  I'm
trying to add more debugging now, as I have a test case that
easily reproduces the problem.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

