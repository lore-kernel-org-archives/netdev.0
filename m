From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [net-next-2.6 PATCH v2] x86: Align skb w/ start of cacheline
 on newer core 2/Xeon Arch
Date: Thu, 01 Jul 2010 13:37:27 -0700
Message-ID: <4C2CFC87.6020003@intel.com>
References: <20100630043728.9224.64191.stgit@localhost.localdomain> <87tyojzbjm.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"bphilips@novell.com" <bphilips@novell.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:57255 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756014Ab0GAUh3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Jul 2010 16:37:29 -0400
In-Reply-To: <87tyojzbjm.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen wrote:
> Jeff Kirsher <jeffrey.t.kirsher@intel.com> writes:
> 
> 
> Sorry for the late comment.
> 
>>  
>> +#ifdef CONFIG_MCORE2
>> +/*
>> + * We handle most unaligned accesses in hardware.  On the other hand
>> + * unaligned DMA can be quite expensive on some Nehalem processors.
>> + *
>> + * Based on this we disable the IP header alignment in network drivers.
>> + */
>> +#define NET_IP_ALIGN	0
>> +#endif
>>  #endif /* _ASM_X86_SYSTEM_H */
> 
> The ifdef should be imho dropped and the option be made unconditional
> for all x86. I am not aware of any x86 core where unalignment is really
> slow. This would increase the chance of it actually working on many
> configurations which do not necessarily optimize for Core2.
> 
> -Andi

Seems to make sense to me.  I will see about generating a patch that 
drops the check for CONFIG_MCORE2.

Thanks,

Alex
