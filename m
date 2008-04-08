From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: Re: [PATCH] forcedeth: new backoff implementation
Date: Tue, 08 Apr 2008 15:13:07 -0400
Message-ID: <47FBC3C3.8090900@nvidia.com>
References: <47FA94CC.7070300@nvidia.com> <20080408011425.ff2dc98a.akpm@linux-foundation.org> <47FB9A24.7030709@colorfullife.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Jeff Garzik <jgarzik@pobox.com>, nedev <netdev@vger.kernel.org>
To: Manfred Spraul <manfred@colorfullife.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate03.nvidia.com ([216.228.112.145]:7168 "EHLO
	hqemgate03.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752602AbYDHWPI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2008 18:15:08 -0400
In-Reply-To: <47FB9A24.7030709@colorfullife.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for the review. I will update the patch and resend it.

Manfred Spraul wrote:
> Andrew Morton wrote:
> 
>> On Mon, 07 Apr 2008 17:40:28 -0400 Ayaz Abdulla <aabdulla@nvidia.com> 
>> wrote:
>>  
>>
>>> +static void nv_gear_backoff_reseed(struct net_device *dev)
>>> +{
>>> +    u8 __iomem *base = get_hwbase(dev);
>>> +    u32 miniseed1, miniseed2, miniseed2_reversed, miniseed3, 
>>> miniseed3_reversed;
>>> +    u32 temp, seedset, combinedSeed;
>>> +    int i;
>>> +
>>> +    /* Setup seed for free running LFSR */
>>> +    /* We are going to read the time stamp counter 3 times and 
>>> swizzle bits around to increase randomness */
>>>     
>>
>>
>> I see this driver rigorously observes the 800-column-xterm convention.
>>
>>  
>>
>>> +    rdtscl(miniseed1);
>>>     
>>
>>
>> err, no.  We don't have sufficient Kconfig dependencies in place to be 
>> able
>> to do this.  You just broke all non-x86.
>>
>> Suitable fixes would be
>>
>> a) add #ifdef CONFIG_X86 all over the place
>>
>> b) use do_gettimeofday() (might be tricky if called from interrupt)
>>
>> c) use cpu_clock().
>>
>>   
> 
> d) use get_random_bytes()?
> It's irq-safe, used e.g. by the network code for the TCP sequence numbers.
> 
>>> +    /* Ensure seeds are not the same */
>>> +    if ((combinedSeed & NVREG_BKOFFCTRL_SEED_MASK) ==
>>> +        (combinedSeed & (NVREG_BKOFFCTRL_SEED_MASK << 
>>> NVREG_BKOFFCTRL_GEAR)))
>>> +        combinedSeed = 0x3FF3FF;
>>> +
>>>     
> 
> I don't understand this block: The seed consists of two parts, each 12 
> bits.
> Both parts mustn't be identical. If both parts are identical, then both 
> are set to 0x3ff.
> But if both are 0x3ff, then they are identical. Is that intentional?
> 
> -- 
>    Manfred

-----------------------------------------------------------------------------------
This email message is for the sole use of the intended recipient(s) and may contain
confidential information.  Any unauthorized review, use, disclosure or distribution
is prohibited.  If you are not the intended recipient, please contact the sender by
reply email and destroy all copies of the original message.
-----------------------------------------------------------------------------------
