From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [net-next-2.6 PATCH v2] x86: Align skb w/ start of cacheline
 on newer core 2/Xeon Arch
Date: Thu, 01 Jul 2010 13:41:16 -0700
Message-ID: <4C2CFD6C.10809@zytor.com>
References: <20100630043728.9224.64191.stgit@localhost.localdomain> <87tyojzbjm.fsf@basil.nowhere.org> <4C2CFC87.6020003@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"bphilips@novell.com" <bphilips@novell.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"x86@kernel.org" <x86@kernel.org>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([198.137.202.10]:49966 "EHLO mail.zytor.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754702Ab0GAUlr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Jul 2010 16:41:47 -0400
In-Reply-To: <4C2CFC87.6020003@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/01/2010 01:37 PM, Alexander Duyck wrote:
> Andi Kleen wrote:
>> Jeff Kirsher <jeffrey.t.kirsher@intel.com> writes:
>>
>>
>> Sorry for the late comment.
>>
>>>  
>>> +#ifdef CONFIG_MCORE2
>>> +/*
>>> + * We handle most unaligned accesses in hardware.  On the other hand
>>> + * unaligned DMA can be quite expensive on some Nehalem processors.
>>> + *
>>> + * Based on this we disable the IP header alignment in network drivers.
>>> + */
>>> +#define NET_IP_ALIGN	0
>>> +#endif
>>>  #endif /* _ASM_X86_SYSTEM_H */
>>
>> The ifdef should be imho dropped and the option be made unconditional
>> for all x86. I am not aware of any x86 core where unalignment is really
>> slow. This would increase the chance of it actually working on many
>> configurations which do not necessarily optimize for Core2.
>>
>> -Andi
> 
> Seems to make sense to me.  I will see about generating a patch that 
> drops the check for CONFIG_MCORE2.
> 

Just drop the #ifdef ... #endif.

	-hpa
