From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Fix ESP SA loading (by default)
Date: Wed, 05 Nov 2008 11:03:18 +0100
Message-ID: <49116F66.4030305@trash.net>
References: <20081103010431.GA29905@gondor.apana.org.au>	<20081105.013148.156667310.davem@davemloft.net>	<20081105095428.GA4584@x200.localdomain> <20081105.015552.33573006.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: adobriyan@gmail.com, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33674 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750812AbYKEKD0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2008 05:03:26 -0500
In-Reply-To: <20081105.015552.33573006.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Alexey Dobriyan <adobriyan@gmail.com>
> Date: Wed, 5 Nov 2008 12:54:28 +0300
> 
>> It was ENOENT from crypto_alg_mod_lookup(), actually.
>>
>> I think liberal printk additions are the way to go.
> 
> Saying "type dmesg" to figure out why an IPSEC configuration fails
> is not very user friendly, even for application developers.

Indeed. I also prefer the *error_desc, for netlink errors we could
then include the message in an extended error attribute or something
like that. Probably its even a necessity for userspace to be able to
associate errors properly in case multiple messages are sent at once.

> About the rmmod thing, we can do something similar to how
> we handle nesting of irq_regs().  Ie. there are things that
> push and pop the stack of ->error_desc.  rmmod operations
> could be one of those things

Alternatively we could simply strdup the error message (or copy it
to a reserved area to avoid running into memory allocation errors).
That avoids having to mess with foreign task structs when
unloading modules.

