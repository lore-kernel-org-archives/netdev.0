From: Jakub Sitnicki <jkbs@redhat.com>
Subject: Re: [PATCH net-next v2] net: ipv4: add support for ECMP hash policy choice
Date: Wed, 08 Mar 2017 17:00:05 +0100
Message-ID: <8760jjep2y.fsf@redhat.com>
References: <929a2609-51f8-c385-a727-3f819cf28b4f@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, edumazet@google.com, davem@davemloft.net,
        roopa@cumulusnetworks.com, dsa@cumulusnetworks.com
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f173.google.com ([209.85.220.173]:36338 "EHLO
        mail-qk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751906AbdCHQAz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 11:00:55 -0500
Received: by mail-qk0-f173.google.com with SMTP id 1so72441972qkl.3
        for <netdev@vger.kernel.org>; Wed, 08 Mar 2017 08:00:11 -0800 (PST)
In-reply-to: <929a2609-51f8-c385-a727-3f819cf28b4f@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 08, 2017 at 12:43 PM GMT, Nikolay Aleksandrov wrote:
> On 08/03/17 14:05, Jakub Sitnicki wrote:
>> On Tue, Mar 07, 2017 at 11:01 AM GMT, Nikolay Aleksandrov wrote:
>>> This patch adds support for ECMP hash policy choice via a new sysctl
>>> called fib_multipath_hash_policy and also adds support for L4 hashes.
>>> The current values for fib_multipath_hash_policy are:
>>>  0 - layer 3 (default)
>>>  1 - layer 4
>>> If there's an skb hash already set and it matches the chosen policy then it
>>> will be used instead of being calculated. The ICMP inner IP addresses use
>>> is removed.
>>>
>>> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>>> ---
>>> v2:
>>>  - removed the output_key_hash as it's not needed anymore
>>>  - reverted to my original/internal patch with L3 as default hash
>> 
>> What about ICMP PTB (Fragmentation Needed) forwarding that makes PMTUD
>> work with ECMP in setups like described in RFC7690 [1]?
>> 
>>   ptb -> router ecmp -> next hop L4/L7 load balancer -> destination
>> 
>>        router --> load balancer 1 --->
>>             \\--> load balancer 2 ---> load-balanced service
>>              \--> load balancer N --->
>> 
>> Removing special treatment of ICMP errors will break it, won't it?
>> 
>
> Yes, I am aware and this decision was made with that in mind.
> We'd like to use the HW hash when available and IIRC that doesn't play well with
> special-casing ICMP errors for anycast as it may not match also. Another thing,
> again if I remember correctly, was that this behaviour is closer to how hardware
> handles ECMP.

OK, I wanted to make sure that is not an oversight that ECMP routing in
ipv4 stack is to be dumbed down to match the hardware behavior. I
thought that it was an advantage that we want to have over hardware
routers. (To be fair, I should mention that we don't have it in ipv6
stack ATM.)

>
> One thing we can do is leave the current L3 behaviour with ICMP error handling
> and add a new L3 mode that tries to use the skb hash when available and doesn't
> care about the packet type.
>
> What do you think ?

Sounds good to me. Would be good to hear other opinions also.

Thanks,
Jakub
