From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [Patch net 2/2] net_sched: always call ->destroy when ->init()
 fails
Date: Wed, 29 Oct 2014 20:09:02 -0700
Message-ID: <5451ABCE.90504@gmail.com>
References: <1414194959-28006-1-git-send-email-xiyou.wangcong@gmail.com> <1414194959-28006-2-git-send-email-xiyou.wangcong@gmail.com> <20141029.142934.1722309776700951536.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	john.r.fastabend@intel.com, edumazet@google.com, kaber@trash.net,
	vtlam@google.com
To: xiyou.wangcong@gmail.com, wang.bo116@zte.com.cn
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:52202 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752169AbaJ3DJU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2014 23:09:20 -0400
Received: by mail-ob0-f174.google.com with SMTP id uz6so3500331obc.33
        for <netdev@vger.kernel.org>; Wed, 29 Oct 2014 20:09:19 -0700 (PDT)
In-Reply-To: <20141029.142934.1722309776700951536.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/29/2014 11:29 AM, David Miller wrote:
> From: Cong Wang <xiyou.wangcong@gmail.com>
> Date: Fri, 24 Oct 2014 16:55:59 -0700
>
>> In qdisc_create(), when ->init() exists and it fails, we should
>> call ->destroy() to clean up the potentially partially initialized
>> qdisc's. This will also make the ->init() implementation easier.
>>
>> qdisc_create_dflt() already does that. Most callers of qdisc_create_dflt()
>> simply use noop_qdisc when it fails.
>>
>> And, most of the ->destroy() implementations are already able to clean up
>> partially initialization, we don't need to worry.
>>
>> The following ->init()'s need to catch up:
>> fq_codel_init(), hhf_init(), multiq_init(),  sfq_init(), mq_init(),
>> mqprio_init().
>>
>> Reported-by: Wang Bo <wang.bo116@zte.com.cn>
>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>
> As discussed, I really want to see ->init() clean up it's own crap.
>
> There are certain kinds of initializations that cannot be tested for,
> such as setting up a workqueue etc.
>
> Therefore, the mere idea that we can call ->destroy() to handle this
> is a pure non-starter as far as I am concerned.
>
> Thanks.
> --

Cong/Wang, anyone working on this? Otherwise I'll take a stab
at it tomorrow.

Thanks!
John

-- 
John Fastabend         Intel Corporation
