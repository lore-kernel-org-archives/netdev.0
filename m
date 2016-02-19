From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH v3 3/8] net: sched: add cls_u32 offload hooks for
 netdevs
Date: Fri, 19 Feb 2016 07:52:33 -0500
Message-ID: <56C71011.7060105@mojatatu.com>
References: <20160217051418.17139.41052.stgit@john-Precision-Tower-5810>
 <20160217051709.17139.88337.stgit@john-Precision-Tower-5810>
 <56C4528E.5090505@mojatatu.com> <56C48295.9030806@gmail.com>
 <56C4FD2B.9000009@gmail.com> <56C5B5A0.7010305@mojatatu.com>
 <56C5E212.50505@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: John Fastabend <john.fastabend@gmail.com>, jiri@resnulli.us,
	amir@vadai.me, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f175.google.com ([209.85.223.175]:35617 "EHLO
	mail-io0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757470AbcBSMwf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2016 07:52:35 -0500
Received: by mail-io0-f175.google.com with SMTP id g203so107945446iof.2
        for <netdev@vger.kernel.org>; Fri, 19 Feb 2016 04:52:35 -0800 (PST)
In-Reply-To: <56C5E212.50505@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-18 10:24 AM, John Fastabend wrote:
> On 16-02-18 04:14 AM, Jamal Hadi Salim wrote:
>> On 16-02-17 06:07 PM, John Fastabend wrote:
>>> [...]
>>>
>>

>> IMO, it would be better at this early stage to enforce the correct
>> behavior for future generations.
>> To follow the netlink semantics which a lot of people are already
>> trained to think in.
>>
>> Current netlink behavior is supposed to be:
>>
>> 1) NEW ==> "Create".
>> Ambigous - could mean a)"create if it doesnt exist" or b) "fail if it
>> exists otherwise create"
>> Unfortunately different parts of the kernel often assume some
>> default from either #a or #b.
>>
>
> But this is already handled by the core cls_api.c code. We never
> get to u32_change if the flags are not correct.
>
> Look at the block right above the op call into the classifiers
> change() code in cls_api.c. Starting at line 287.
>
>

Indeed that would cover s/ware filters but not h/ware. That will
depend on what hardware can do. Really,
all you need is to propagate those flags. Your
driver ndo can ignore them. I know i will need them.

Alternatively: If we say all filters are going to be stored in
s/ware as well i.e the tri-state we talked about then the cls_api
checks will work as well. But when you are talking millions
of filters (such as i deal with) - that may become impractical
(and then you are going to have all kind of clever things to find
whether an EXCLUSIVE will work or not etc).

cheers,
jamal
