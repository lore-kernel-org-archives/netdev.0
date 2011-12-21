From: Michael Wang <wangyun@linux.vnet.ibm.com>
Subject: Re: [PATCH] Avoid extra calculation in ip_route_input_common
Date: Wed, 21 Dec 2011 14:00:31 +0800
Message-ID: <4EF175FF.70003@linux.vnet.ibm.com>
References: <4EF16AA3.2070303@linux.vnet.ibm.com> <1324445033.20505.2.camel@joe2Laptop> <4EF170F5.5040900@linux.vnet.ibm.com> <1324446632.21340.4.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp06.au.ibm.com ([202.81.31.148]:59068 "EHLO
	e23smtp06.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750698Ab1LUGAt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 01:00:49 -0500
Received: from /spool/local
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <wangyun@linux.vnet.ibm.com>;
	Wed, 21 Dec 2011 05:58:10 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pBL5udHv2883832
	for <netdev@vger.kernel.org>; Wed, 21 Dec 2011 16:56:40 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pBL60X3o032380
	for <netdev@vger.kernel.org>; Wed, 21 Dec 2011 17:00:33 +1100
In-Reply-To: <1324446632.21340.4.camel@joe2Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/21/2011 01:50 PM, Joe Perches wrote:

> On Wed, 2011-12-21 at 13:39 +0800, Michael Wang wrote:
>> On 12/21/2011 01:23 PM, Joe Perches wrote:
>>> On Wed, 2011-12-21 at 13:12 +0800, Michael Wang wrote:
>>>> From: Michael Wang <wangyun@linux.vnet.ibm.com>
>>>>
>>>> If previous condition doesn't meet, the later check will be cancelled.
>>>> So we don't need to do all the calculation.
> []
>>> commit c0b8c32b1c96afc9b32b717927330025cc1c501e
>>> Author: Stephen Hemminger <shemminger@vyatta.com>
>>> Date:   Thu Apr 10 04:00:28 2008 -0700
>>>
>>>     IPV4: use xor rather than multiple ands for route compare
>>>     
>>>     The comparison in ip_route_input is a hot path, by recoding the C
>>>     "and" as bit operations, fewer conditional branches get generated
>>>     so the code should be faster. Maybe someday Gcc will be smart
>>>     enough to do this?
>> This is what confused me, why "fewer conditional branches get generated"
>> will make code faster?
>> In this example, I think the best condition when daddr is different, we
>> only need to go to one branch do compare then quit, won't this be faster?
> 
> 	if (a && b)
> 		...
> pseudo-codes to:
> 	if (!a)
> 		goto fail;
> 	if (!b)
> 		goto fail;
> 	...
> fail:
> 
> Each of those conditional branches has a cost.
> Combining tests of variables in the same cache lines
> has relatively little cost compared to the conditional
> branches.
> 

That make sense :)

> That's the theory anyway.
> 
> If you have tests that demonstrate otherwise, please
> provide them.
> 

I think the previous patch should have done such test, otherwise they
won't do this change.

Thanks for your reply, that clear my confusion.

Regards,
Michael Wang

> cheers, Joe
> 
