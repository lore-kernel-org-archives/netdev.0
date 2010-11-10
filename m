From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] Prevent reading uninitialized memory with socketfilters
Date: Wed, 10 Nov 2010 21:25:43 +0000
Message-ID: <1289424343.2249.28.camel@achroite.uk.solarflarecom.com>
References: <201011102325.JAF82308.OSVLFHtFJMQFOO@I-love.SAKURA.ne.jp>
	 <20101110.103923.59670339.davem@davemloft.net>
	 <1289422664.2249.1.camel@achroite.uk.solarflarecom.com>
	 <20101110.125929.245406622.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: penguin-kernel@I-love.SAKURA.ne.jp, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:4782 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756859Ab0KJVZq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Nov 2010 16:25:46 -0500
In-Reply-To: <20101110.125929.245406622.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-11-10 at 12:59 -0800, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Wed, 10 Nov 2010 20:57:44 +0000
> 
> > On Wed, 2010-11-10 at 10:39 -0800, David Miller wrote:
> > [...]
> >> In this patch, I use a bitmap (a single long var) so that only filters
> >> using mem[] loads/stores pay the price of added security checks.
> >> 
> >> For other filters, additional cost is a single instruction.
> >> 
> >> [ Since we access fentry->k a lot now, cache it in a local variable
> >>   and mark filter entry pointer as const. -DaveM ]
> > [...]
> > 
> > I don't see the justification for combining these changes.  One patch,
> > one fix, right?
> 
> I'm minimizing the performance impact of the new bitmap checks.

This seems like an entirely separate optimisation, since fentry->k was
*already* being used all over the place.  (And a smart compiler should
optimise that anyway... though I realise gcc is often not that smart.)

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

