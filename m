From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net] sfc: fix calling of free_irq with 0 argument
Date: Wed, 07 May 2014 21:45:51 +0200
Message-ID: <536A8D6F.9090108@redhat.com>
References: <1399380556-25797-1-git-send-email-nikolay@redhat.com> <20140507.153925.2030838202936450086.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	sshah@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52500 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750938AbaEGTqV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 May 2014 15:46:21 -0400
In-Reply-To: <20140507.153925.2030838202936450086.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/07/2014 09:39 PM, David Miller wrote:
> From: Nikolay Aleksandrov <nikolay@redhat.com>
> Date: Tue,  6 May 2014 14:49:16 +0200
> 
>> If the sfc driver is in legacy interrupt mode (either explicitly by
>> using interrupt_mode module param or by falling back to it) it will
>> hit a warning at kernel/irq/manage.c because it will try to free irq 0
>> in efx_nic_fini_interrupt() since the MSI interrupts were freed always,
>> but in legacy irq mode they're == 0. So fix it by checking if we
>> actually have an interrupt allocated and only then free it.
>>
>> CC: <linux-net-drivers@solarflare.com>
>> CC: Shradha Shah <sshah@solarflare.com>
>> CC: David S. Miller <davem@davemloft.net>
>>
>> Reported-by: Zenghui Shi <zshi@redhat.com>
>> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
>> ---
>> There're other ways to fix this as well, but I chose this one as it follows
>> the logic in the code. Also I saw it used in a few places to check if
>> there's an IRQ allocated for that channel.
> 
> Zero can be a valid interrupt on some systems.
> 
> This is a discussion that keeps popping up from time to time, and Linus
> usually gets upset when someone adds a "!irq" test somewhere.
> 
> Why not just guard the efx_for_each_channel() loop with a top-level
> test of whether we are using legacy interrupt mode?  That will avoid
> this issue entirely.
> 
Yeah, that was my other solution - looking at the mode the card's in.
I'm fine both ways, like I said earlier I did it this way to be consistent
with the style used (it's used like that in other places, too).
And then I found out it's been like that before the commit I mentioned.

If the Solarflare folks are okay with it I can re-write the function to be
based on the mode used instead of checking for zero irq. I'll post an
adjusted patch after I get a chance to test it.

Nik
