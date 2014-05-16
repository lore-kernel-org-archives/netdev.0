From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH net-next] pktgen: Add NOINIT option to leave packet data
 uninitialized
Date: Fri, 16 May 2014 06:28:38 -0700
Message-ID: <53761286.2040505@candelatech.com>
References: <01eda9d1e9de457f72e0b48e22633c05cca5146f.1400236390.git.tgraf@suug.ch> <1400246202.7973.163.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>, Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:34867 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752052AbaEPN2j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 09:28:39 -0400
In-Reply-To: <1400246202.7973.163.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 05/16/2014 06:16 AM, Eric Dumazet wrote:
> On Fri, 2014-05-16 at 12:34 +0200, Thomas Graf wrote:
>> The memset() on the packet data is expensive and severely limiting
>> the pps throughput for large frame sizes.
>>
>> Considering that pktgen requires root privileges to run it is safe
>> to introduce an option to optionally avoid the memset() and leave
>> the packet data uninitialized.
>>
>> VM test results, 2 VCPU, 2 threads, pkt_size=9K:
>>
>>      12.44%  -11.15%  [kernel.kallsyms]   [k] memset
>>       4.84%   +1.58%  [kernel.kallsyms]   [k] get_page_from_freelist
>>
>> Signed-off-by: Thomas Graf <tgraf@suug.ch>
>> ---
>>   Documentation/networking/pktgen.txt |  3 +++
>>   net/core/pktgen.c                   | 16 ++++++++++++++--
>>   2 files changed, 17 insertions(+), 2 deletions(-)
>
> We do not want to leak content of memory, even if 'root' is willing to.
>
> Sorry, you need to do something else if you really care.

Is there currently no other way for root to grab memory contents and
send them over the network?

I mean, it could load it's own module and do bad things if nothing else?

Thanks,
Ben

>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
