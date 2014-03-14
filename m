From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RCU PATCH 06/14] net: sched: fw use RCU
Date: Thu, 13 Mar 2014 22:43:32 -0700
Message-ID: <53229704.1040808@gmail.com>
References: <20140310170008.3011.73599.stgit@nitbit.x32> <20140310170546.3011.82918.stgit@nitbit.x32> <1394473279.3607.46.camel@edumazet-glaptop2.roam.corp.google.com> <53208E3F.5090401@gmail.com> <1394643673.21721.48.camel@edumazet-glaptop2.roam.corp.google.com> <20140313202245.GK21124@linux.vnet.ibm.com> <1394744203.21721.53.camel@edumazet-glaptop2.roam.corp.google.com> <20140313211509.GP21124@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, xiyou.wangcong@gmail.com,
	jhs@mojatatu.com, netdev@vger.kernel.org, davem@davemloft.net
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f46.google.com ([209.85.219.46]:44173 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752170AbaCNFny (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 01:43:54 -0400
Received: by mail-oa0-f46.google.com with SMTP id i7so2136379oag.33
        for <netdev@vger.kernel.org>; Thu, 13 Mar 2014 22:43:53 -0700 (PDT)
In-Reply-To: <20140313211509.GP21124@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/13/2014 02:15 PM, Paul E. McKenney wrote:
> On Thu, Mar 13, 2014 at 01:56:43PM -0700, Eric Dumazet wrote:
>> On Thu, 2014-03-13 at 13:22 -0700, Paul E. McKenney wrote:
>>
>>> Hmmm...  You know, the offset that kfree uses is a byte offset.  I see
>>> no reason why any of the rcu_head structures should be misaligned.  If
>>> HTSIZE is too big by only a factor of four or smaller, would the following
>>> (untested) patch to RCU be appropriate?
>>>
>>> 							Thanx, Paul
>>>
>>> ------------------------------------------------------------------------
>>>
>>> rcu: Increase kfree_rcu() offset range
>>>
>>> The kfree_rcu() function operates by placing an offset into the rcu_head
>>> structure in place of the function pointer that is normally there.
>>> This offset cannot exceed 4095, on the theory that no Linux kernel will
>>> ever have executable code in page zero.  However, the rcu_head structure
>>> contains a pair of function pointers, and should never be misaligned.
>>> This commit therefore divides the offset by the size of a pointer when
>>> being placed into the rcu_head structure, and multiplies it by this
>>> same constant when pulling it out.
>>>
>>> Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
>>
>> SGTM, thanks Paul.
>>
>> Reviewed-by: Eric Dumazet <edumzzet@google.com>
>
> Very good, thank you!
>
> John, could you please give it a try with that rcu_head structure
> moved to the end and let me know how it goes?
>
> 							Thanx, Paul
>

Yep, this resolves the BUILD_BUG_ON I was seeing previously. Thanks!

Tested-by: John Fastabend <john.r.fastabend@intel.com>

-- 
John Fastabend         Intel Corporation
