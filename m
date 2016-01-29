From: tndave <tushar.n.dave@oracle.com>
Subject: Re: i40e: Kernel unaligned access due to 'struct i40e_dma_mem' being
 'packed'
Date: Fri, 29 Jan 2016 14:47:27 -0800
Message-ID: <56ABEBFF.6030004@oracle.com>
References: <56A973D6.4060202@oracle.com>
 <20160128.015643.125847430094859447.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, shannon.nelson@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	bruce.w.allan@intel.com, john.ronciak@intel.com,
	mitch.a.williams@intel.com, intel-wired-lan@lists.osuosl.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:36583 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753171AbcA2Wrg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 17:47:36 -0500
In-Reply-To: <20160128.015643.125847430094859447.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 01/27/2016 10:56 PM, David Miller wrote:
> From: tndave <tushar.n.dave@oracle.com>
> Date: Wed, 27 Jan 2016 17:50:14 -0800
>
>> Hi,
>>
>> i40e driver has 'struct i40e_dma_mem' defined with 'packed' directive
>> causing kernel unaligned errors on sparc (when
>> 40e_allocate_dma_mem_d()
>> is being called)
>>
>> log_unaligned: 1031 callbacks suppressed
>> Kernel unaligned access at TPC[448ae8]
>> dma_4v_alloc_coherent+0x188/0x2e0
>> Kernel unaligned access at TPC[448ae8]
>> dma_4v_alloc_coherent+0x188/0x2e0
>> Kernel unaligned access at TPC[448ae8]
>> dma_4v_alloc_coherent+0x188/0x2e0
>> Kernel unaligned access at TPC[448ae8]
>> dma_4v_alloc_coherent+0x188/0x2e0
>>
>> This can be fixed with get_unaligned/put_unaligned(). However I don't
>> see 'struct i40e_dma_mem' is being directly shoved into NIC hardware.
>> But instead fields of the struct are being read and used for hardware
>> (e.g. dma_addr_t pa). For the test, I remove __packed, and i40e driver
>> and HW works fine. (of course kernel unaligned errors are gone too).
>> My question is, does 'struct i40e_dma_mem' required to be __packed?
>
> People get overzealoud with __packed.
>
> And even if it doesn't cause unaligned accesses like this, it generates
> terrible code (byte at a time accesses to words) on several architectures.
True. For the same reason I want to clarify if __packed is actually 
needed? instead of fixing it with get_unaligned/put_unaligned()!

-Tushar
>
