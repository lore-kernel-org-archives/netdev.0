From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH v2 1/1] net: sched: Introduce connmark action
Date: Sun, 18 Jan 2015 16:22:28 -0500
Message-ID: <54BC2414.2010100@mojatatu.com>
References: <1421611245-18492-1-git-send-email-jhs@emojatatu.com> <CAHA+R7Muz_d47NX01tKO7v7V7m=5mKf+BPP1jo9dEH==8R6bgw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, nbd@openwrt.org,
	pablo@netfilter.org, Florian Westphal <fw@strlen.de>,
	=?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:34547 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750992AbbARVWc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2015 16:22:32 -0500
Received: by mail-ie0-f182.google.com with SMTP id x19so28044479ier.13
        for <netdev@vger.kernel.org>; Sun, 18 Jan 2015 13:22:32 -0800 (PST)
In-Reply-To: <CAHA+R7Muz_d47NX01tKO7v7V7m=5mKf+BPP1jo9dEH==8R6bgw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/18/15 16:00, Cong Wang wrote:
> On Sun, Jan 18, 2015 at 12:00 PM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>> +
>> +MODULE_AUTHOR("Felix Fietkau <nbd@openwrt.org>");
>> +MODULE_DESCRIPTION("Connection tracking mark restoring");
>> +MODULE_LICENSE("GPL");
>
>
> Please move these to the bottom.
>

Done.

>> +
>> +static int __init connmark_init_module(void)
>> +{
>> +       int ret;
>> +
>> +       ret = tcf_hashinfo_init(&connmark_hash_info, CONNMARK_TAB_MASK);
>> +       if (ret)
>> +               return ret;
>> +
>
> Is this against latest net-next? We don't need to init the hashinfo anymore,
> tcf_register_action() already does that.
>

The code itself has been living outside the tree - so i am just doing
only necessary transforms. The above was needed because the action
was maintaining its own hash.
I will convert to the new mode.

>> +       return tcf_register_action(&act_connmark_ops, CONNMARK_TAB_MASK);
>> +}
>> +
>> +static void __exit connmark_cleanup_module(void)
>> +{
>> +       tcf_unregister_action(&act_connmark_ops);
>> +}
>> +
>
> Even if we really needed, you forgot to call tcf_hashinfo_destroy()?
>

Didnt follow - why do you need tcf_hashinfo_destroy()?

Will send v3 shortly

cheers,
jamal

> Thanks.
>
