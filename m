From: Dave Chinner <david@fromorbit.com>
Subject: Re: [BUG, NET] deadlock tearing down a bridged interface
Date: Sat, 19 Jul 2008 11:17:09 +1000
Message-ID: <20080719011709.GA5947@disturbed>
References: <20080718073724.GA5802@disturbed> <4880BA7A.3020909@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ipmail01.adl6.internode.on.net ([203.16.214.146]:35286 "EHLO
	ipmail01.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750756AbYGSBRP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2008 21:17:15 -0400
Content-Disposition: inline
In-Reply-To: <4880BA7A.3020909@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 18, 2008 at 08:44:58AM -0700, Ben Greear wrote:
> Dave Chinner wrote:
>> Folks,
>>
>> I just deadlocked networking on a 2.6.24 kernel. Basically I
>> was trying to restart the bridge interface I use for UML sessions
>> because it wasn't passing packets. This happens occasionally
>> when I leave a UML session too long in gdb, so I bounced the
>> bridge to get it working again.
>>   
> We have been chasing a refcount bug in 2.6.25 that only happens when
> IPv6 module is loaded.

Which causes what problem? The deadlock I reported or the bridge occasionally
hanging? Is that a problem in 2.6.24?

The deadlock is the one I'm concerned about - it appears that
netdev_run_todo() can only wait on a single interface at a time,
so if we are tearing down two interfaces concurrently where one
has a reference on the other a deadlock is just waiting to happen...

> If you are not actually using ipv6, try removing it's
> module from your /lib/modules/* directory and see if that fixes your  
> problem.

I'll try it, but a) it's not 2.6.25 and b) I don't tend to triage problems
on my main workstation so I'm not likely to try to reproduce this
deadlock unless absolutely necessary.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
