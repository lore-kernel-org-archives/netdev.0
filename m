From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH v2 1/5] introduce IFE action
Date: Thu, 25 Feb 2016 07:20:56 -0500
Message-ID: <56CEF1A8.3020505@mojatatu.com>
References: <1456231760-2513-1-git-send-email-jhs@emojatatu.com>
 <1456231760-2513-2-git-send-email-jhs@emojatatu.com>
 <56CDEA6D.1000908@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
	alexei.starovoitov@gmail.com, john.fastabend@gmail.com,
	dj@verizon.com
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:34973 "EHLO
	mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760606AbcBYMU6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 07:20:58 -0500
Received: by mail-io0-f194.google.com with SMTP id z135so5469639iof.2
        for <netdev@vger.kernel.org>; Thu, 25 Feb 2016 04:20:58 -0800 (PST)
In-Reply-To: <56CDEA6D.1000908@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-24 12:37 PM, Daniel Borkmann wrote:
> On 02/23/2016 01:49 PM, Jamal Hadi Salim wrote:
>> From: Jamal Hadi Salim <jhs@mojatatu.com>
> [...]
>> +static const struct nla_policy ife_policy[TCA_IFE_MAX + 1] = {
>> +    [TCA_IFE_PARMS] = {.len = sizeof(struct tc_ife)},
>> +    [TCA_IFE_DMAC] = {.type = NLA_BINARY,.len = ETH_ALEN},
>> +    [TCA_IFE_SMAC] = {.type = NLA_BINARY,.len = ETH_ALEN},
>
> This is buggy btw ...
>

I am sure i cutnpasted that from somewhere. Thanks for catching
it; I will remove NLA_BINARY ref.

>> +    [TCA_IFE_TYPE] = {.type = NLA_U16},
>> +};
>
> [...]
>
>> +    if (parm->flags & IFE_ENCODE) {
>> +        ife_type = *(u16 *) nla_data(tb[TCA_IFE_TYPE]);
>
> ( We have accessors for such things. Please also check coding style
>    and white space things in your series, there's couple of things all
>    over the place. )


Modern git tells you about white spaces - maybe i didnt stare long
enough ;-> I will use the accessor in next update.


> Maybe try to make this lockless in the fast path? Otherwise placing
> this on ingress / egress (f.e. clsact) doesn't really scale.
>


Let me think about it. Likely it will be subsequent patches - I just
want to get this set out first.

Thanks Daniel.

cheers,
jamal
