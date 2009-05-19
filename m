From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 0/7] IPv4/IPv6 unregistration deadlock fixes
Date: Tue, 19 May 2009 01:07:09 -0700
Message-ID: <m1octpplci.fsf@fess.ebiederm.org>
References: <m13ab8s8cr.fsf@fess.ebiederm.org>
	<20090518.221637.98842683.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	shemminger@vyatta.com, greearb@candelatech.com, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:49746 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752339AbZESIHO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 04:07:14 -0400
In-Reply-To: <20090518.221637.98842683.davem@davemloft.net> (David Miller's message of "Mon\, 18 May 2009 22\:16\:37 -0700 \(PDT\)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Wed, 13 May 2009 19:53:40 -0700
>
>> A while ago it was noticed that unregistering network devices could cause
>> deadlocks if virtual files that take the rtnl_lock were accessed at the
>> wrong time.
>> 
>> After looking at the different possibilities the only way to solve it
>> cleanly without some kind of busy loop appears to be reducing the scope
>> of the rtnl lock.
>> 
>> I have not tackled the hard fix yet but I have tested our current work
>> around and it does not succeed in restarting the system call and
>> instead leaks -ERESTARNOSYS to userspace, because we do not have a
>> signal pending.
>> 
>> Further the current work around misses several interesting places
>> in the network stack where the deadlock can occur.
>> 
>> I have addressed the problems by making a common helper function
>> and patching all of the places I could find that had this problem.
>
> I've added these changes to net-next-2.6, thanks.
>
> I really can't justify sticking this into net-2.6, especially
> this late in the series, sorry.

No problem.  The problem is ancient.  I just figured it was time to
start solving it.

Eric

