From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH 1/4] ucc_geth: Change private immrbar_virt_to_phys to generic iopa
Date: Thu, 8 Feb 2007 00:53:23 -0600
Message-ID: <17A046C6-5FD3-46D5-AB96-EAEDF22FA829@kernel.crashing.org>
References: <989B956029373F45A0B8AF02970818900D4401@zch01exm26.fsl.freescale.net>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Tabi Timur-B04825" <timur@freescale.com>,
	<netdev@vger.kernel.org>, <linuxppc-dev@ozlabs.org>
To: "Li Yang-r58472" <LeoLi@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nommos.sslcatacombnetworking.com ([67.18.224.114]:50391 "EHLO
	nommos.sslcatacombnetworking.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1422783AbXBHGyT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Feb 2007 01:54:19 -0500
In-Reply-To: <989B956029373F45A0B8AF02970818900D4401@zch01exm26.fsl.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Feb 8, 2007, at 12:48 AM, Li Yang-r58472 wrote:

>> -----Original Message-----
>> From: Kumar Gala [mailto:galak@kernel.crashing.org]
>> Sent: Thursday, February 08, 2007 1:58 PM
>> To: Li Yang-r58472
>> Cc: Tabi Timur-B04825; netdev@vger.kernel.org; linuxppc- 
>> dev@ozlabs.org
>> Subject: Re: [PATCH 1/4] ucc_geth: Change private  
>> immrbar_virt_to_phys
> to generic
>> iopa
>>
>>
>> On Feb 7, 2007, at 11:52 PM, Li Yang-r58472 wrote:
>>
>>>> -----Original Message-----
>>>> From: Timur Tabi [mailto:timur@freescale.com]
>>>> Sent: Thursday, February 08, 2007 1:03 AM
>>>> To: Kumar Gala
>>>> Cc: Li Yang-r58472; netdev@vger.kernel.org; linuxppc-dev@ozlabs.org
>>>> Subject: Re: [PATCH 1/4] ucc_geth: Change private
>>>> immrbar_virt_to_phys
>>> to generic
>>>> iopa
>>>>
>>>> Kumar Gala wrote:
>>>>
>>>>> If its been mapped with ioremap() you know the physical address
>>> already
>>>>> so why do you need iopa().
>>>>
>>>> That's what the original function immrbar_virt_to_phys() does.
> We're
>>> trying to
>>>> get rid of it, because we thought is redundant with iopa().
>>>>
>>>> static inline unsigned long immrbar_virt_to_phys(volatile void *
>>> address)
>>>> {
>>>> 	if ( ((u32)address >= (u32)qe_immr) &&
>>>> 			((u32)address < ((u32)qe_immr + QE_IMMAP_SIZE))
>>> )
>>>> 		return (unsigned long)(address - (u32)qe_immr +
>>>> 				(u32)get_qe_base());
>>>> 	return (unsigned long)virt_to_phys(address);
>>>> }
>>>>
>>>> get_qe_base() does a search of the OF tree the first time it's
>>>> called.
>>>>
>>>> Here's the code that calls immrbar_virt_to_phys():
>>>>
>>>> 	out_be32(&ugeth->p_send_q_mem_reg->sqqd[i].bd_ring_base,
>>>> 		 (u32) immrbar_virt_to_phys(ugeth->
>>>> 					    p_tx_bd_ring[i]));
>>>>
>>>>
>>>> Would it be better to replace this code with something like this:
>>>>
>>>> out_be32(&ugeth->p_send_q_mem_reg->sqqd[i].bd_ring_base,
>>>> 	get_qe_base() + ((void *) ugeth->p_tx_bd_ring[i] - (void *)
>>> qe_immr));
>>>
>>> No, we don't know if the BD ring is in MURAM or main memory as it is
>>> configurable.  iopa() is best choice to handle both case, IMHO.
>>
>> Does MURAM behave differently than normal memory?
>
> MURAM is a mmio region so it don't share the characteristic of main
> memory that phy_addr = virt_addr - PAGE_OFFSET.  While they can  
> both be
> mapped through page table using iopa().

Right, so when do you know if you'll be using MURAM or normal  
memory?  Why not just keep around a token that is the physical  
address at the point you make the decision of MURAM vs normal memory.

- k
