From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [Patch net-next 1/2] net_sched: fix errno in tcindex_set_parms()
Date: Thu, 25 Sep 2014 17:27:34 -0700
Message-ID: <5424B2F6.4060201@intel.com>
References: <1411671965-18887-1-git-send-email-xiyou.wangcong@gmail.com> <5424842A.60802@intel.com> <54249DD9.5060403@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:17304 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752312AbaIZA1v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Sep 2014 20:27:51 -0400
In-Reply-To: <54249DD9.5060403@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/25/2014 03:57 PM, John Fastabend wrote:
> On 09/25/2014 02:07 PM, John Fastabend wrote:
>> On 09/25/2014 12:06 PM, Cong Wang wrote:
>>> When kmemdup() fails, we should return -ENOMEM.
>>>
>>> Cc: John Fastabend <john.fastabend@gmail.com>
>>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>>> ---
>>
>> Acked-by: John Fastabend <john.r.fastabend@intel.com>
>>
>> Thanks Cong.
>>
> 
> Related to this we should probably push error messages
> from the dump routines correctly. If you see u32_dump()
> returns a -EINVAL even though it was due to a memory
> allocation failure. This is not necessarily due to my
> patches though I think the error returning from dump
> has always been a simple -1 value.
> 
> I'll take a look at it, unless you beat me to it, after
> I finish up the percpu stats which I'm doing now.
> 
> .John
> 

Also just in case you hit them, there is an suspicious
rcu usage from qdisc_watchdog and another from task_csl_state()
call in cls_cgroup.

The qdisc_watchdog is due to the annotation on the qdisc
and I'm not entirely convinced the cls_cgroup hasn't been
there all along.

I'm looking into them but most likely wont figure it out
tonight as I have to take off for a bit.

Thanks,
John
