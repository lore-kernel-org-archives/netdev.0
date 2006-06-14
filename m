From: jamal <hadi@cyberus.ca>
Subject: Re: netif_tx_disable and lockless TX
Date: Wed, 14 Jun 2006 08:52:56 -0400
Message-ID: <1150289576.5233.48.camel@jzny2>
References: <20060531051451.GA7110@gondor.apana.org.au>
	 <20060530.232626.00456312.davem@davemloft.net>
	 <20060531063152.GA8032@gondor.apana.org.au>
	 <20060531.000818.78646242.davem@davemloft.net>
	 <20060531120626.GA11925@gondor.apana.org.au>
	 <1149078972.5462.72.camel@jzny2>  <17533.55270.172654.98522@robur.slu.se>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <ak@suse.de>, David Miller <davem@davemloft.net>,
	mchan@broadcom.com, jgarzik@pobox.com, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:3307 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S932329AbWFNMzu
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jun 2006 08:55:50 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1FqUuW-0003oz-Mk
	for netdev@vger.kernel.org; Wed, 14 Jun 2006 08:55:52 -0400
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <17533.55270.172654.98522@robur.slu.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-31-05 at 19:52 +0200, Robert Olsson wrote:
> jamal writes:
> 
>  > Latency-wise: TX completion interrupt provides the best latency.
>  > Processing in the poll() -aka softirq- was almost close to the hardirq
>  > variant. So if you can make things run in a softirq such as transmit
>  > one, then the numbers will likely stay the same.
>  
>  I don't remember we tried tasklet for TX a la Herbert's suggestion but we 
>  used use tasklets for controlling RX processing to avoid hardirq livelock
>  in pre-NAPI versions.
> 

Hrm - it may have been a private thing i did then. I could swear we did
that experiment together ...
Perhaps Herbert's motivation was not really to optimize but rather to
get something unstuck in the transmit path state machine maybe in a
context of netconsole? The conditions for which that tasklet would even
run require a CPU collision to the transmit. Sorry, I didnt quiet follow
the motivation/discussion that ended in that patch.

>  Had variants of tulip driver with both TX cleaning at ->poll and TX
>  cleaning at hardirq and didn't see any performance difference. The 
>  ->poll was much cleaner but we kept Alexey's original work for tulip.
> 

It certainly is cleaner - but i do recall the hardirq variant had better
latency much observable under high packet rates aka small packets. 

>  > Sorry, I havent been following discussions on netchannels[1] so i am not
>  > qualified to comment on the "replacement" part Dave mentioned earlier.
>  > What I can say is the tx processing doesnt have to be part of the NAPI
>  > poll() and still use hardirq.
> 
>  Yes true but I see TX numbers with newer boards (wire rate small pakets)
>  with cleaing in ->poll. Also now linux is very safe in network "overload" 
>  situations. Moving work to hardirq may change that.
> 

Oh, I am not suggesting a change - i am a lot more conservative than
that ;-> these areas are delicate (not code-delicate Acme ;->) but
rather what seems obvious requires a lot of experimental results first.

Robert, your transmit results Intel or AMD based?

cheers,
jamal



