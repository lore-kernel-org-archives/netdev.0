From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] net: Add network namespace clone & unshare support.
Date: Thu, 27 Sep 2007 11:14:33 -0600
Message-ID: <m1k5qcjaiu.fsf@ebiederm.dsl.xmission.com>
References: <m1tzphrnq5.fsf@ebiederm.dsl.xmission.com>
	<46FB6F1E.8070105@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
To: Cedric Le Goater <clg@fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:47301 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758798AbXI0RPU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2007 13:15:20 -0400
In-Reply-To: <46FB6F1E.8070105@fr.ibm.com> (Cedric Le Goater's message of
	"Thu, 27 Sep 2007 10:51:42 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cedric Le Goater <clg@fr.ibm.com> writes:

>> diff --git a/include/linux/sched.h b/include/linux/sched.h
>> index a01ac6d..e10a0a8 100644
>> --- a/include/linux/sched.h
>> +++ b/include/linux/sched.h
>> @@ -27,6 +27,7 @@
>>  #define CLONE_NEWUTS		0x04000000	/* New utsname group? */
>>  #define CLONE_NEWIPC		0x08000000	/* New ipcs */
>> #define CLONE_NEWUSER 0x10000000 /* New user namespace */
>> +#define CLONE_NEWNET		0x20000000	/* New network namespace */
>
> This new flag is going to conflict with the pid namespace flag 
> CLONE_NEWPID in -mm. It might be worth changing it to:
>
> #define CLONE_NEWNET		0x40000000

Interesting, it would have been nice if someone had caught this
detail earlier.  Oh well.

Thanks for pointing this out, it's on my todo list to look into,
and ensure we resolve.

I'm confused because my notes have 0x80000000 for the pid namespace,
and 0x40000000 for the time namespace.

> The changes in nxproxy.c and fork.c will also conflict but I don't 
> think we can do much about it for now.

They should also be fairly easy conflicts to resolve.

I guess we are likely to hit this conflict in the next -mm or the
merge window, which ever comes first.

Eric
