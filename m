From: John Heffner <jheffner@psc.edu>
Subject: Re: TCP connection stops after high load.
Date: Tue, 17 Apr 2007 15:47:58 -0400
Message-ID: <4625246E.2090700@psc.edu>
References: <7e63f56c0704161151p405c4597x5fbac6021b635d84@mail.gmail.com>	<20070416.121558.48807497.davem@davemloft.net>	<7e63f56c0704170058m35d44a8ajfe5d97c4c7a8d87a@mail.gmail.com> <20070417.123941.119226635.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: coroberti@gmail.com, netdev@vger.kernel.org,
	greearb@candelatech.com, moser.michael@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.psc.edu ([128.182.66.106]:65206 "EHLO mailer2.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031145AbXDQTsE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Apr 2007 15:48:04 -0400
In-Reply-To: <20070417.123941.119226635.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: "Robert Iakobashvili" <coroberti@gmail.com>
> Date: Tue, 17 Apr 2007 10:58:04 +0300
> 
>> David,
>>
>> On 4/16/07, David Miller <davem@davemloft.net> wrote:
>>>>> Commit: 53cdcc04c1e85d4e423b2822b66149b6f2e52c2c
>>>>> Author: John Heffner <jheffner@psc.edu> Fri, 16 Mar 2007 15:04:03 -0700
>>>>>
>>>>>      [TCP]: Fix tcp_mem[] initialization.
>>>>>      Change tcp_mem initialization function.  The fraction of total memory
>>>>>      is now a continuous function of memory size, and independent of page
>>>>>      size.
>>>>
>>>> Kernels 2.6.19 and 2.6.20 series are effectively broken right now.
>>>> Don't you wish to patch them?
>>> Can you verify that this patch actually fixes your problem?
>> Yes, it fixes.
> 
> Thanks, I will submit it to -stable branch.

My only reservation in submitting this to -stable is that it will in 
many cases increase the default tcp_mem values, which in turn can 
increase the default tcp_rmem values, and therefore the window scale. 
There will be some set of people with broken firewalls who trigger that 
problem for the first time by upgrading along the stable branch.  While 
it's not our fault, it could cause some complaints...

Thanks,
   -John
