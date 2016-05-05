From: Brian Haley <brian.haley@hpe.com>
Subject: Re: [PATCH nf-next 0/9] netfilter: remove per-netns conntrack tables,
 part 1
Date: Thu, 5 May 2016 18:55:07 -0400
Message-ID: <572BCF4B.2040504@hpe.com>
References: <1461863628-23350-1-git-send-email-fw@strlen.de>
 <572BACA3.6070303@hpe.com> <20160505205418.GA21687@breakpoint.cc>
 <572BC7A5.1060503@hpe.com> <20160505223632.GB21687@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20160505223632.GB21687@breakpoint.cc>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/05/2016 06:36 PM, Florian Westphal wrote:
> Brian Haley <brian.haley@hpe.com> wrote:
>>>> I've seen cases where certain users are attacked, where the CT table is
>>>> filled such that we start seeing "nf_conntrack: table full, dropping packet"
>>>> messages (as expected).  But other users continue to function normally,
>>>> unaffected.  Is this still the case - each netns has some limit it can't
>>>> exceed?
>>>
>>> The limit is global, the accounting per namespace.
>>
>> So this is a change from existing.
>
> No, see __nf_conntrack_alloc():
>
>          if (nf_conntrack_max &&
>              unlikely(atomic_read(&net->ct.count) > nf_conntrack_max)) {
> 		...
>
> ct.count is whatever number of entries the namespace has allocated,
> so max number of possible conntracks is always infinite if number
> of net namespaces is unlimited (barring memory constraints, of course).

Ah yes, nf_conntrack_max is a global, thanks for setting me straight.  So I 
guess the tuning might just include increasing the bucket count in order to try 
and keep the number of items in each one small since there will be more entries 
in this single table now.

Thanks,

-Brian
