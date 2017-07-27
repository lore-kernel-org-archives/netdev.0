From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: Re: nf_nat_pptp 4.12.3 kernel lockup/reboot
Date: Thu, 27 Jul 2017 09:29:29 +0300
Message-ID: <d5222f4a33e7098cc250ecaf22bd9508@nuclearcat.com>
References: <69c0c47e920e763bce702521baae9caa@nuclearcat.com>
 <20170724161944.GB23964@breakpoint.cc>
 <20170724162039.GC23964@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nuclearcat.com ([144.76.183.226]:52400 "EHLO nuclearcat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750965AbdG0G3b (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Jul 2017 02:29:31 -0400
In-Reply-To: <20170724162039.GC23964@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017-07-24 19:20, Florian Westphal wrote:
> Florian Westphal <fw@strlen.de> wrote:
>> Denys Fedoryshchenko <nuclearcat@nuclearcat.com> wrote:
>> > Hi,
>> >
>> > I am trying to upgrade kernel 4.11.8 to 4.12.3 (it is a nat/router, handling
>> > approx 2gbps of pppoe users traffic) and noticed that after while server
>> > rebooting(i have set reboot on panic and etc).
>> > I can't run serial console, and in pstore / netconsole there is nothing.
>> > Best i got is some very short message about softlockup in ipmi, but as
>> > storage very limited there - it is near useless.
>> >
>> > By preliminary testing (can't do it much, as it's production) - it seems
>> > following lines causing issue, they worked in 4.11.8 and no more in 4.12.3.
>> 
>> Wild guess here, does this help?
>> 
>> diff --git a/net/netfilter/nf_conntrack_helper.c 
>> b/net/netfilter/nf_conntrack_helper.c
>> --- a/net/netfilter/nf_conntrack_helper.c
>> +++ b/net/netfilter/nf_conntrack_helper.c
>> @@ -266,6 +266,8 @@ int __nf_ct_try_assign_helper(struct nf_conn *ct, 
>> struct nf_conn *tmpl,
>>                 help = nf_ct_helper_ext_add(ct, helper, flags);
>>                 if (help == NULL)
>>                         return -ENOMEM;
>> +              	if (!nf_ct_ext_add(ct, NF_CT_EXT_NAT, flags));
> 
> sigh, stupid typo, should be no ';' at the end above.

Tested-by: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>

Tested and no more hangs for 2 days, definitely improvement.
Any chance it will go to stable 4.12.x and new kernel?

Thank you very much!
