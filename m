From: Paul Blakey <paulb@mellanox.com>
Subject: Re: [PATCH net-next] net/sched: cls_flower: Add user specified data
Date: Tue, 17 Jan 2017 13:53:04 +0200
Message-ID: <6be8f641-16ad-88a4-d7c3-474dc3b10e71@mellanox.com>
References: <1483362833-52114-1-git-send-email-paulb@mellanox.com>
 <14675f63-4212-2f72-da4c-cd24b9d10881@mojatatu.com>
 <20170108171251.GF1971@nanopsycho>
 <040c6876-a323-0a35-229f-46bc33b6de11@mellanox.com>
 <587BC894.3080909@gmail.com>
 <11bcf09a-0144-fd7f-369b-771962475c5e@mellanox.com>
 <20170116095129.GB1804@nanopsycho.orion>
 <59ac74c5-5301-a958-74dd-c5fee669a94b@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <paulb@mellanox.com>, John Fastabend <john.fastabend@gmail.com>,
        "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>, Roman Mashak <mrv@mojatatu.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>, Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve1eur01on0051.outbound.protection.outlook.com ([104.47.1.51]:12208
        "EHLO EUR01-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750933AbdAQLxM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 17 Jan 2017 06:53:12 -0500
In-Reply-To: <59ac74c5-5301-a958-74dd-c5fee669a94b@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 17/01/2017 13:23, Jamal Hadi Salim wrote:
> On 17-01-16 04:51 AM, Jiri Pirko wrote:
>> Mon, Jan 16, 2017 at 08:54:18AM CET, paulb@mellanox.com wrote:
>>>
>>>
>
>>
>> I think we should do it in a generic way, for every classifier, right
>> away. Same as Jamal is doing for actions. I think that first we should
>> get Jamal's patch merged and then do the same for classifiers.
>>
>
> Should be "trivial" like my patch.
> Add a new TLV type in TCA_XXX enum in rtnetlink.h
> in  tc_ctl_tfilter look for it and memcpy it
> in tcf_fill_node set it on the new TCA_XXX if the cls struct
> has it present.
>

That's exactly what I did before I realized it won't work per internal 
element (per handle), which is what I want. see my example.

So I'll probably implement it like actions dumping/init works - 
tcf_exts_init, tcf_exts_dump (calling a generic functions on all 
classifiers who want this).
I'll add something like get_cookie, dump_cookie. which get/set the 
TCA_COOKIE.


Thanks,
Paul.

> Look at my patch (1 of 2) which I just reposted.
>
> cheers,
> jamal
