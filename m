From: Ben Greear <greearb@candelatech.com>
Subject: Re: More details on why received UDP packets are treated as errors?
Date: Wed, 07 Aug 2013 17:10:35 -0700
Message-ID: <5202E1FB.8020405@candelatech.com>
References: <51F6B2AB.5050607@candelatech.com> <1375129292.10515.21.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:37807 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933310Ab3HHAKg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Aug 2013 20:10:36 -0400
In-Reply-To: <1375129292.10515.21.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/29/2013 01:21 PM, Eric Dumazet wrote:
> On Mon, 2013-07-29 at 11:21 -0700, Ben Greear wrote:
>> We have a test case on 3.9.9+ (local patches applied) where sending from
>> VETH interface, through peer VETH bridged (with our own emulator bridge module)
>> to physical interface, which is then looped to another physical interface (B).
>> The VETH and the wired B interface are sending UDP traffic to each other.
>> Routing rules should be configured such that this all works appropriately.
>>
>> Replacing our bridging module with a user-space bridge has same behaviour.
>>
>> This setup works on the 3.7.y kernel, but we only get one-way traffic
>> (B to VETH) on 3.9.9+.
>>
>> I sniffed the B port, and traffic appears to be sent and received
>> properly (ie, no checksum errors, etc).  But, our user-space app
>> shows no received UDP frames on B, and netstat -s gives the
>> output below.
>>
>> Is there any way to get more details about what these 'packet receive errors'
>> are caused by using normal-ish tools?
>
> You could try dropwatch for this kind of obscure drops
>
> https://fedorahosted.org/dropwatch/

I had a chance to crank this up today.

dropwatch is pretty sweet...turns out it's dropping due to bad UDP checksums,
due to the VETH bug/issue where it claims to calculate HW checksum but appearantly does
not actually do so (see previous email in another thread).

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
