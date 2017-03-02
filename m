From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [Patch net v3] ipv6: check for ip6_null_entry in
 __ip6_del_rt_siblings()
Date: Wed, 1 Mar 2017 21:06:55 -0800
Message-ID: <ab3b2b76-ad2a-8c0a-41f4-f77529b62e28@cumulusnetworks.com>
References: <1488240463-12000-1-git-send-email-xiyou.wangcong@gmail.com>
 <6d332a15-d86c-0b02-61e5-38d208f2caf7@cumulusnetworks.com>
 <20170301231648.2bpr7doxcipj5gi4@android-1601923ecb7aeff9.dhcp.thefacebook.com>
 <5ab5897d-bafe-d297-91da-07bc32ce6d6e@cumulusnetworks.com>
 <20170302004215.3ohf6smlrxodd3mn@kafai-mba.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org,
        andreyknvl@google.com, Eric Dumazet <eric.dumazet@gmail.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:33218 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751155AbdCBFG6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Mar 2017 00:06:58 -0500
Received: by mail-pf0-f171.google.com with SMTP id w189so18124678pfb.0
        for <netdev@vger.kernel.org>; Wed, 01 Mar 2017 21:06:58 -0800 (PST)
In-Reply-To: <20170302004215.3ohf6smlrxodd3mn@kafai-mba.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/1/17 4:42 PM, Martin KaFai Lau wrote:
> On Wed, Mar 01, 2017 at 04:07:38PM -0800, David Ahern wrote:
>> On 3/1/17 3:16 PM, Martin KaFai Lau wrote:
>>> [ An unrelated topic.  I wonder ip -6 r del xyz::/0 would delete
>>>   the gateway route...]
>>
>> a very related question ...
>>
>> ip -6 r del x::/0 comes down to the kernel as delete '::/0' (plen is 0,
>> so cfg->fc_dst is 0). It ends up on the null_entry from fib6_locate b/c
>> of the 0 prefix length, so it is another variant of 'ip -6 ro del ::/0'
> Agree on the plen == 0 part.
> 
> I actually meant if 'ip -6 r del xyz::/0' would delete any _default_
> _gateway_ also.  By looking at ip6_route_del() alone, it seems it only

Per rtm_to_fib6_config, plen of 0 means fc_dst is 0. Meaning xyz::/0 == ::/0
