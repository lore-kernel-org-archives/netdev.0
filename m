From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [net-next PATCH v2 1/5] introduce IFE action
Date: Thu, 25 Feb 2016 22:46:40 +0100
Message-ID: <56CF7640.2060202@iogearbox.net>
References: <1456231760-2513-1-git-send-email-jhs@emojatatu.com> <1456231760-2513-2-git-send-email-jhs@emojatatu.com> <56CDEA6D.1000908@iogearbox.net> <56CEF1A8.3020505@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
	alexei.starovoitov@gmail.com, john.fastabend@gmail.com,
	dj@verizon.com
To: Jamal Hadi Salim <jhs@mojatatu.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:58831 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751007AbcBYVqo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 16:46:44 -0500
In-Reply-To: <56CEF1A8.3020505@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/25/2016 01:20 PM, Jamal Hadi Salim wrote:
> On 16-02-24 12:37 PM, Daniel Borkmann wrote:
>> On 02/23/2016 01:49 PM, Jamal Hadi Salim wrote:
>>> From: Jamal Hadi Salim <jhs@mojatatu.com>
>> [...]
>>> +static const struct nla_policy ife_policy[TCA_IFE_MAX + 1] = {
>>> +    [TCA_IFE_PARMS] = {.len = sizeof(struct tc_ife)},
>>> +    [TCA_IFE_DMAC] = {.type = NLA_BINARY,.len = ETH_ALEN},
>>> +    [TCA_IFE_SMAC] = {.type = NLA_BINARY,.len = ETH_ALEN},
>>
>> This is buggy btw ...
>
> I am sure i cutnpasted that from somewhere. Thanks for catching
> it; I will remove NLA_BINARY ref.

Yeah, NLA_BINARY seems to be a bit of a misleading name. We should
probably audit, if there are more such users already in the tree.

[...]
>> Maybe try to make this lockless in the fast path? Otherwise placing
>> this on ingress / egress (f.e. clsact) doesn't really scale.
>
> Let me think about it. Likely it will be subsequent patches - I just
> want to get this set out first.

Yes, I mean one of the key motivation was "[...] to horizontally scale
packet processing at scope of a chasis or rack [...]". So for people
who don't have that NIC with embedded Cavium processor, they might
already hit scalability issues for encode/decode right there.

Thanks again,
Daniel
