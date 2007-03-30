From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 19/19] e1000: major part of the new API changes
Date: Fri, 30 Mar 2007 13:56:32 -0700
Message-ID: <460D7980.5090600@intel.com>
References: <20070329163304.6595.81963.stgit@localhost.localdomain> <20070329164038.6595.18817.stgit@localhost.localdomain> <460D70D9.5020704@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, bruce.w.allan@intel.com,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	cramerj@intel.com, john.ronciak@intel.com, arjan@linux.intel.com,
	akpm@linux-foundation.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:11675 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753629AbXC3U4f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Mar 2007 16:56:35 -0400
In-Reply-To: <460D70D9.5020704@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
>>  
>> +s32
>> +e1000_alloc_zeroed_dev_spec_struct(struct e1000_hw *hw, u32 size)
>> +{
>> +	hw->dev_spec = kmalloc(size, GFP_KERNEL);
>> +
>> +	if (!hw->dev_spec)
>> +		return -ENOMEM;
>> +
>> +	memset(hw->dev_spec, 0, size);
>> +
>> +	return E1000_SUCCESS;
>> +}
>>   
> 
> This is what is wrong with a lot of the new code. It is written as
> verbose as possible.
> 
> What is wrong with open coded
>     hw->dev_spec = kzalloc(size, GFP_KERNEL).

nothing, I'll make sure that we change this. Please remember that this code was 
written over a period of about 1 year, and a lot of cleanups that happened in 
other parts of e1000 may very well have been overlooked. Also, it may be "ugly" 
but it's definately not wrong at all.

>> +
>> +void
>> +e1000_free_dev_spec_struct(struct e1000_hw *hw)
>> +{
>> +	if (!hw->dev_spec)
>> +		return;
>> +
>> +	kfree(hw->dev_spec);
>> +}
>> +
>>   
> Almost looks like you contracted this out to someone paid by the LOC.

will fix, thanks for the comments.

Auke

