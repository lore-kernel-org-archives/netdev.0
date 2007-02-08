From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH 1/4] ucc_geth: Change private immrbar_virt_to_phys to
	generic iopa
Date: Wed, 7 Feb 2007 23:57:53 -0600
Message-ID: <CD216D17-B494-4B86-992D-453D68694A31@kernel.crashing.org>
References: <989B956029373F45A0B8AF02970818900D43E9@zch01exm26.fsl.freescale.net>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Tabi Timur-B04825 <timur@freescale.com>,
	linuxppc-dev@ozlabs.org
To: "Li Yang-r58472" <LeoLi@freescale.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <989B956029373F45A0B8AF02970818900D43E9@zch01exm26.fsl.freescale.net>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org


On Feb 7, 2007, at 11:52 PM, Li Yang-r58472 wrote:

>> -----Original Message-----
>> From: Timur Tabi [mailto:timur@freescale.com]
>> Sent: Thursday, February 08, 2007 1:03 AM
>> To: Kumar Gala
>> Cc: Li Yang-r58472; netdev@vger.kernel.org; linuxppc-dev@ozlabs.org
>> Subject: Re: [PATCH 1/4] ucc_geth: Change private  
>> immrbar_virt_to_phys
> to generic
>> iopa
>>
>> Kumar Gala wrote:
>>
>>> If its been mapped with ioremap() you know the physical address
> already
>>> so why do you need iopa().
>>
>> That's what the original function immrbar_virt_to_phys() does.  We're
> trying to
>> get rid of it, because we thought is redundant with iopa().
>>
>> static inline unsigned long immrbar_virt_to_phys(volatile void *
> address)
>> {
>> 	if ( ((u32)address >= (u32)qe_immr) &&
>> 			((u32)address < ((u32)qe_immr + QE_IMMAP_SIZE))
> )
>> 		return (unsigned long)(address - (u32)qe_immr +
>> 				(u32)get_qe_base());
>> 	return (unsigned long)virt_to_phys(address);
>> }
>>
>> get_qe_base() does a search of the OF tree the first time it's  
>> called.
>>
>> Here's the code that calls immrbar_virt_to_phys():
>>
>> 	out_be32(&ugeth->p_send_q_mem_reg->sqqd[i].bd_ring_base,
>> 		 (u32) immrbar_virt_to_phys(ugeth->
>> 					    p_tx_bd_ring[i]));
>>
>>
>> Would it be better to replace this code with something like this:
>>
>> out_be32(&ugeth->p_send_q_mem_reg->sqqd[i].bd_ring_base,
>> 	get_qe_base() + ((void *) ugeth->p_tx_bd_ring[i] - (void *)
> qe_immr));
>
> No, we don't know if the BD ring is in MURAM or main memory as it is
> configurable.  iopa() is best choice to handle both case, IMHO.

Does MURAM behave differently than normal memory?

- k
