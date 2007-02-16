From: Ben Greear <greearb@candelatech.com>
Subject: Re: [BUG] RTNL and flush_scheduled_work deadlocks
Date: Fri, 16 Feb 2007 08:06:25 -0800
Message-ID: <45D5D681.5060104@candelatech.com>
References: <20070216072928.GA1599@ff.dom.local> <45D55FF0.8090309@candelatech.com> <20070216081051.GC1599@ff.dom.local> <45D569E9.7010407@candelatech.com> <20070216090425.GD1599@ff.dom.local> <20070216121245.GE1599@ff.dom.local>
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
Received: from ns2.lanforge.com ([66.165.47.211]:40025 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1945962AbXBPQGC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Feb 2007 11:06:02 -0500
In-Reply-To: <20070216121245.GE1599@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarek Poplawski wrote:
> On Fri, Feb 16, 2007 at 10:04:25AM +0100, Jarek Poplawski wrote:
>   
>> On Fri, Feb 16, 2007 at 12:23:05AM -0800, Ben Greear wrote:
>>     
> ...
>   
>>> I don't see how asserting it in the rtnl_lock would help anything, 
>>> because at that
>>> point we are about to deadlock anyway...  (and this is probably very 
>>> rare, as mentioned above.)
>>>       
>> But it's happening now. Probably lockdep is not enough
>> and rtnl_lock is probably used in too many places, so I
>> meant some additional checks would be possible.
>>     
>
> And of course it already could be done by DEBUG_MUTEXES or
> DEBUG_SPINLOCK, so I gone too far and it's really bad idea.
>   

Well, I had lockdep and all of the locking debugging I could find 
enabled, but
it did not catch this problem..I had to use sysctl -t and manually dig 
through the backtraces
to find the deadlock....

It may be that lockdep could be enhanced to catch this sort of thing....

Ben

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


