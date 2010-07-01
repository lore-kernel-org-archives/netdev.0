From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [net-next-2.6 PATCH v2] x86: Align skb w/ start of cacheline on newer core 2/Xeon Arch
Date: Thu, 01 Jul 2010 13:28:13 +0200
Message-ID: <87tyojzbjm.fsf@basil.nowhere.org>
References: <20100630043728.9224.64191.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	bphilips@novell.com, Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:41279 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753330Ab0GAL2Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jul 2010 07:28:16 -0400
In-Reply-To: <20100630043728.9224.64191.stgit@localhost.localdomain> (Jeff
	Kirsher's message of "Tue, 29 Jun 2010 21:38:00 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Kirsher <jeffrey.t.kirsher@intel.com> writes:


Sorry for the late comment.

>  
> +#ifdef CONFIG_MCORE2
> +/*
> + * We handle most unaligned accesses in hardware.  On the other hand
> + * unaligned DMA can be quite expensive on some Nehalem processors.
> + *
> + * Based on this we disable the IP header alignment in network drivers.
> + */
> +#define NET_IP_ALIGN	0
> +#endif
>  #endif /* _ASM_X86_SYSTEM_H */

The ifdef should be imho dropped and the option be made unconditional
for all x86. I am not aware of any x86 core where unalignment is really
slow. This would increase the chance of it actually working on many
configurations which do not necessarily optimize for Core2.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.
