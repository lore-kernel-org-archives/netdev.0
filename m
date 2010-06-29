From: Ben Greear <greearb@candelatech.com>
Subject: Re: [iproute2] iproute2: Allow 'ip addr flush' to loop more than
 10 times.
Date: Mon, 28 Jun 2010 23:27:39 -0700
Message-ID: <4C29925B.9090008@candelatech.com>
References: <1277790959-28075-1-git-send-email-greearb@candelatech.com> <20100628.231204.229752207.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: greearb@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:36773 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751810Ab0F2G1o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 02:27:44 -0400
In-Reply-To: <20100628.231204.229752207.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/28/2010 11:12 PM, David Miller wrote:
> From: greearb@gmail.com
> Date: Mon, 28 Jun 2010 22:55:59 -0700
>
>> From: Ben Greear<greearb@candelatech.com>
>>
>> The default remains at 10 for backwards compatibility.
>>
>> For instance:
>>   # ip addr flush dev eth2
>>   *** Flush remains incomplete after 10 rounds. ***
>>   # ip -l 20 addr flush dev eth2
>>   *** Flush remains incomplete after 20 rounds. ***
>>   # ip -loops 0 addr flush dev eth2
>>   #
>>
>> This is useful for getting rid of large numbers of IP
>> addresses in scripts.
>>
>> Signed-off-by: Ben Greear<greearb@candelatech.com>
>
> I would suggest to instead add some logic to this code to detect that
> forward progress is being made.
>
> I really don't see any value in having a hard limit that triggers on a
> bulk delete when no other address changing activity is happening in
> the system.

I'm not sure I understand how this loop could have run forever
anyway, unless some other process(es) was constantly adding addresses at
the same time?  Or maybe some ipv6 auto config thing?

It appears there is already code to detect when the loop
is done (flushing ~70 IPv4 addresses with -l 0 was one of my
test cases, and worked as expected).

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
