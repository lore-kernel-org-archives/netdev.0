From: Ben Greear <greearb@candelatech.com>
Subject: Re: Race condition in ipv6 code
Date: Fri, 13 Jan 2012 09:04:46 -0800
Message-ID: <4F10642E.2040302@candelatech.com>
References: <CA+HUmGhJ-YvFMRnKzb8RqH6COZ=erp1SajVcb1rq1vi2k9OBGw@mail.gmail.com> <1326349911.2741.1.camel@edumazet-laptop> <m1pqeov4u1.fsf@fess.ebiederm.org> <1326434549.2617.14.camel@edumazet-laptop> <m1ipkgqccb.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Francesco Ruggeri <fruggeri@aristanetworks.com>,
	netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:45074 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752260Ab2AMREu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2012 12:04:50 -0500
In-Reply-To: <m1ipkgqccb.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/12/2012 11:40 PM, Eric W. Biederman wrote:

> So I really think the best solution to avoid the locking craziness is to
> have a wrapper that gets the value from userspace and calls
> schedule_work to get another thread to actually process the change.  I
> don't see any problems with writing a helper function for that.  The
> only downside with using schedule_work is that we return to userspace
> before the change has been fully installed in the kernel.  I don't
> expect that would be a problem but stranger things have happened.

That sounds a bit risky to me.  If something sets a value, and then
queries it, it should always show the proper result for the previous
calls.

If the queries also went through the the same sched-work queue
then maybe it would be OK.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
