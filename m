From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] igb: add module param to set max-rss-queues.
Date: Fri, 24 Mar 2017 18:35:28 -0700
Message-ID: <ca61a7cf-9e64-6077-9ea9-c039a2314da0@candelatech.com>
References: <1490389127-23171-1-git-send-email-greearb@candelatech.com>
 <20170324.141237.1992801159655201421.davem@davemloft.net>
 <255aaae0-8634-c6b5-f4aa-545d2f717aed@candelatech.com>
 <20170324161457.13d86ee0@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:36630 "EHLO
        mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965359AbdCYBfa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 21:35:30 -0400
In-Reply-To: <20170324161457.13d86ee0@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 03/24/2017 04:14 PM, Stephen Hemminger wrote:
> On Fri, 24 Mar 2017 14:20:56 -0700
> Ben Greear <greearb@candelatech.com> wrote:
>
>> On 03/24/2017 02:12 PM, David Miller wrote:
>>> From: greearb@candelatech.com
>>> Date: Fri, 24 Mar 2017 13:58:47 -0700
>>>
>>>> From: Ben Greear <greearb@candelatech.com>
>>>>
>>>> In systems where you may have a very large number of network
>>>> adapters, certain drivers may consume an unfair amount of
>>>> IRQ resources.  So, allow a module param that will limit the
>>>> number of IRQs at driver load time.  This way, other drivers
>>>> (40G Ethernet, for instance), which probably will need the
>>>> multiple IRQs more, will not be starved of IRQ resources.
>>>>
>>>> Signed-off-by: Ben Greear <greearb@candelatech.com>
>>>
>>> Sorry, no module params.
>>>
>>> Use generic run-time facilities such as ethtool to configure
>>> such things.
>>
>> You cannot call ethtool before module load time, and that is when
>> the IRQs are first acquired.  It may be way more useful to give each
>> of 20 network adapters 2 irqs than have the first few grab 16 and the rest
>> get lumped into legacy crap.
>
> Almost all network devices do not acquire interrupts until device is brought up.
> I.e request_irq is called from open not probe. This is done so that configuration
> can be done and also so that unused ports don't consume interrupt space.

If I ever have to deal with this on stock kernels again I'll keep that in mind.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
