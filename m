From: Kristian Larsson <kristian@spritelink.net>
Subject: Re: pktgen IP address stepping
Date: Thu, 16 Dec 2010 19:27:24 +0100
Message-ID: <20101216182724.GB8404@spritelink.se>
References: <20101216172800.GA8404@spritelink.se>
 <20101216.094426.193723178.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Mail2.SpriteLink.NET ([195.182.5.83]:52841 "EHLO
	Mail2.SpriteLink.NET" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751795Ab0LPS3F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 13:29:05 -0500
Content-Disposition: inline
In-Reply-To: <20101216.094426.193723178.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 16, 2010 at 09:44:26AM -0800, David Miller wrote:
> From: Kristian Larsson <kristian@spritelink.net>
> Date: Thu, 16 Dec 2010 18:28:00 +0100
> 
> > Looking forward to any feedback and / or suggestions.
> 
> If you need a huge type for the step values in order to handle ipv6
> addresses or similar, used a fixed sized type such as "u64" instead of
> "unsigned long long".

It is not developed with IPv6 in mind, it actually doesn't touch
those parts of the code at all. Stepping through the IPv6 space
and incrementing by what would equal one /64 at a time is a
painfully slow process. We'd need all 128 bits there to make it
useful - an alternative would be to set the step length by prefix
mask instead, ie src6_step 16 would step through by increasing
one /16 at a time.

For IPv4 we could settle for less, something like 32 bits!? ;)

And given your comment I suppose u32 is a better choice than
"unsigned long", right? 

I was actually looking at the IPv6 part and noticed how it
appears to lack the option to set a min and max address, only
random addresses. My intention was to write a patch for that too,
though later on and if I'm able :)

Kind regards,
   Kristian.

-- 
Kristian Larsson                                        KLL-RIPE
+46 704 264511			              kll@spritelink.net
