From: Ben Greear <greearb@candelatech.com>
Subject: Re: [BUG] RTNL and flush_scheduled_work deadlocks
Date: Fri, 16 Feb 2007 00:23:05 -0800
Message-ID: <45D569E9.7010407@candelatech.com>
References: <20070216072928.GA1599@ff.dom.local> <45D55FF0.8090309@candelatech.com> <20070216081051.GC1599@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	Kyle Lucke <klucke@us.ibm.com>,
	Raghavendra Koushik <raghavendra.koushik@neterion.com>,
	Al Viro <viro@ftp.linux.org.uk>
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:51954 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966208AbXBPIXu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Feb 2007 03:23:50 -0500
In-Reply-To: <20070216081051.GC1599@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarek Poplawski wrote:
> On Thu, Feb 15, 2007 at 11:40:32PM -0800, Ben Greear wrote:
> ...
>   
>> Maybe there should be something like an ASSERT_NOT_RTNL() in the 
>> flush_scheduled_work()
>> method?  If it's performance criticial, #ifdef it out if we're not 
>> debugging locks?
>>     
>
> Yes! I thought about the same (at first). But in my
> opinion it was not enough, so I thought about doing
> this in flush_workqueue. But in my next opinion it
> was not enough too. Now I think something like this
> should be done in rtnl_lock (under some debugging #if
> of course). 
>   
The reason these bugs have been hidden is that most of the time, there 
is nothing
on the pending work queue that will try to grab RTNL.  But, the 
flush_work_queue
is still called with RTNL held, so an assert would find this much 
earlier than
waiting for someone to get lucky and actually catch (and debug and report)
a deadlock...

I don't see how asserting it in the rtnl_lock would help anything, 
because at that
point we are about to deadlock anyway...  (and this is probably very 
rare, as mentioned above.)

Thanks,
Ben

> Cheers,
> Jarek P.
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>   


-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


