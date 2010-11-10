From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Prevent reading uninitialized memory with socketfilters
Date: Wed, 10 Nov 2010 12:59:29 -0800 (PST)
Message-ID: <20101110.125929.245406622.davem@davemloft.net>
References: <201011102325.JAF82308.OSVLFHtFJMQFOO@I-love.SAKURA.ne.jp>
	<20101110.103923.59670339.davem@davemloft.net>
	<1289422664.2249.1.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: penguin-kernel@I-love.SAKURA.ne.jp, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49844
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755676Ab0KJU7E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Nov 2010 15:59:04 -0500
In-Reply-To: <1289422664.2249.1.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 10 Nov 2010 20:57:44 +0000

> On Wed, 2010-11-10 at 10:39 -0800, David Miller wrote:
> [...]
>> In this patch, I use a bitmap (a single long var) so that only filters
>> using mem[] loads/stores pay the price of added security checks.
>> 
>> For other filters, additional cost is a single instruction.
>> 
>> [ Since we access fentry->k a lot now, cache it in a local variable
>>   and mark filter entry pointer as const. -DaveM ]
> [...]
> 
> I don't see the justification for combining these changes.  One patch,
> one fix, right?

I'm minimizing the performance impact of the new bitmap checks.
