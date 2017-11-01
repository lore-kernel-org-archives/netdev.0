From: "Nambiar, Amritha" <amritha.nambiar@intel.com>
Subject: Re: [iproute2 PATCH] tc/mqprio: Offload mode and shaper options in
 mqprio
Date: Wed, 1 Nov 2017 00:40:16 -0700
Message-ID: <9102a18d-399c-c00d-501a-448cbabd2d10@intel.com>
References: <150906256227.24207.1663946225760686391.stgit@anamdev.jf.intel.com>
 <20171031182046.23eda44c@shemminger-XPS-13-9360>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, alexander.h.duyck@intel.com,
        jiri@resnulli.us, jhs@mojatatu.com, alexander.duyck@gmail.com,
        xiyou.wangcong@gmail.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:22548 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750808AbdKAHkn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 1 Nov 2017 03:40:43 -0400
In-Reply-To: <20171031182046.23eda44c@shemminger-XPS-13-9360>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/31/2017 10:20 AM, Stephen Hemminger wrote:
> On Thu, 26 Oct 2017 17:02:42 -0700
> Amritha Nambiar <amritha.nambiar@intel.com> wrote:
> 
>> This patch was previously submitted as RFC. Submitting this as
>> non-RFC now that the tc/mqprio changes are accepted in net-next.
>>
>> Adds new mqprio options for 'mode' and 'shaper'. The mode
>> option can take values for offload modes such as 'dcb' (default),
>> 'channel' with the 'hw' option set to 1. The new 'channel' mode
>> supports offloading TCs and other queue configurations. The
>> 'shaper' option is to support HW shapers ('dcb' default) and
>> takes the value 'bw_rlimit' for bandwidth rate limiting. The
>> parameters to the bw_rlimit shaper are minimum and maximum
>> bandwidth rates. New HW shapers in future can be supported
>> through the shaper attribute.
>>
>> # tc qdisc add dev eth0 root mqprio num_tc 2  map 0 0 0 0 1 1 1 1\
>>   queues 4@0 4@4 hw 1 mode channel shaper bw_rlimit\
>>   min_rate 1Gbit 2Gbit max_rate 4Gbit 5Gbit
>>
>> # tc qdisc show dev eth0
>>
>> qdisc mqprio 804a: root  tc 2 map 0 0 0 0 1 1 1 1 0 0 0 0 0 0 0 0
>>              queues:(0:3) (4:7)
>>              mode:channel
>>              shaper:bw_rlimit   min_rate:1Gbit 2Gbit   max_rate:4Gbit 5Gbit
>>
>> Signed-off-by: Amritha Nambiar <amritha.nambiar@intel.com>
> 
> 
> Please build test your patch with compiler checks enabled....
> 
>     CC       q_mqprio.o
> In file included from /usr/include/string.h:635:0,
>                  from q_mqprio.c:20:
> In function ‘memcpy’,
>     inlined from ‘mqprio_print_opt’ at q_mqprio.c:237:2:
> /usr/include/x86_64-linux-gnu/bits/string3.h:53:10: warning: call to __builtin___memcpy_chk will always overflow destination buffer
>    return __builtin___memcpy_chk (__dest, __src, __len, __bos0 (__dest));
>           ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> 
I will send v2 fixing this.
