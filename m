From: Dimitris Michailidis <dm@chelsio.com>
Subject: Re: [PATCH 4/7] cxgb4: Add packet queues and packet DMA code
Date: Sat, 27 Feb 2010 14:41:09 -0800
Message-ID: <4B899F85.1000101@chelsio.com>
References: <8A71B368A89016469F72CD08050AD33401359B69@maui.asicdesigners.com> <20100227.014839.226753616.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:30345 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965003Ab0B0WlO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Feb 2010 17:41:14 -0500
In-Reply-To: <20100227.014839.226753616.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: "Dimitrios Michailidis" <dm@chelsio.com>
> Date: Fri, 26 Feb 2010 16:10:07 -0800
> 
>> I believe this function does not generate any code, the compiler
>> statically figures out the result and optimizes any conditionals that
>> call it.  What option do you have in mind that would tell the compiler
>> if unmap is nop?
> 
> I've got better questions:
> 
> 1) Why is your driver so damn special?
> 
>    If this optimization is useful, it dosen't belong privately in
>    some driver, it belongs in some generic spot.

I agree that it would be better if this were available at some generic 
place, eg an arch header.  It is implicitly available for most arches 
through the definition of DECLARE_PCI_UNMAP_ADDR and related macros, which 
is why the driver is looking at that, but it would be nicer if it were 
explicitly available.  Among the arches MIPS has an explicit indication 
through its CONFIG_DMA_NEED_PCI_MAP_STATE but it's the only one.

> 
> 2) What configuration does this even help for?  Even bog standard x86
>    and x86_64 uses IOMMUs and thus make use of the unmap address.
> 
>    I cannot think of one platform that matters where this will even
>    trigger.

While x86_32 has configurations that don't use unmapping (see 
arch/x86/include/asm/pci.h) it is more helpful with less powerful CPUs, like 
PPC or MIPS one finds in embedded systems.  People use this device with 
embedded CPUs.

> 
> Get rid of this junk, please.  Because even if it's valid, it doesn't
> belong privately in your driver.
> 

I'd love not to have this in the driver but I don't know how to get the same 
result without it with the current state of affairs.
