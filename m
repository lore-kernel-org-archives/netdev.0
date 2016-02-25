From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v2 1/5] introduce IFE action
Date: Thu, 25 Feb 2016 14:07:53 -0800
Message-ID: <56CF7B39.8090704@gmail.com>
References: <1456231760-2513-1-git-send-email-jhs@emojatatu.com> <1456231760-2513-2-git-send-email-jhs@emojatatu.com> <56CDEA6D.1000908@iogearbox.net> <56CEF1A8.3020505@mojatatu.com> <56CF7640.2060202@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
	alexei.starovoitov@gmail.com, dj@verizon.com
To: Daniel Borkmann <daniel@iogearbox.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:35558 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751244AbcBYWIG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 17:08:06 -0500
Received: by mail-pf0-f181.google.com with SMTP id c10so41125809pfc.2
        for <netdev@vger.kernel.org>; Thu, 25 Feb 2016 14:08:05 -0800 (PST)
In-Reply-To: <56CF7640.2060202@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-25 01:46 PM, Daniel Borkmann wrote:
> On 02/25/2016 01:20 PM, Jamal Hadi Salim wrote:
>> On 16-02-24 12:37 PM, Daniel Borkmann wrote:
>>> On 02/23/2016 01:49 PM, Jamal Hadi Salim wrote:
>>>> From: Jamal Hadi Salim <jhs@mojatatu.com>
>>> [...]
>>>> +static const struct nla_policy ife_policy[TCA_IFE_MAX + 1] = {
>>>> +    [TCA_IFE_PARMS] = {.len = sizeof(struct tc_ife)},
>>>> +    [TCA_IFE_DMAC] = {.type = NLA_BINARY,.len = ETH_ALEN},
>>>> +    [TCA_IFE_SMAC] = {.type = NLA_BINARY,.len = ETH_ALEN},
>>>
>>> This is buggy btw ...
>>
>> I am sure i cutnpasted that from somewhere. Thanks for catching
>> it; I will remove NLA_BINARY ref.
> 
> Yeah, NLA_BINARY seems to be a bit of a misleading name. We should
> probably audit, if there are more such users already in the tree.
> 

At some point in the past (maybe a year ago?) I went through and
fixed a handful of these but yeah it seems to be a common error.

> [...]
>>> Maybe try to make this lockless in the fast path? Otherwise placing
>>> this on ingress / egress (f.e. clsact) doesn't really scale.
>>
>> Let me think about it. Likely it will be subsequent patches - I just
>> want to get this set out first.
> 
> Yes, I mean one of the key motivation was "[...] to horizontally scale
> packet processing at scope of a chasis or rack [...]". So for people
> who don't have that NIC with embedded Cavium processor, they might
> already hit scalability issues for encode/decode right there.
> 
> Thanks again,
> Daniel
