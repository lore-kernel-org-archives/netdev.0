From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: netif_tx_disable and lockless TX
Date: Wed, 31 May 2006 19:52:38 +0200
Message-ID: <17533.55270.172654.98522@robur.slu.se>
References: <20060531051451.GA7110@gondor.apana.org.au>
	<20060530.232626.00456312.davem@davemloft.net>
	<20060531063152.GA8032@gondor.apana.org.au>
	<20060531.000818.78646242.davem@davemloft.net>
	<20060531120626.GA11925@gondor.apana.org.au>
	<1149078972.5462.72.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	jgarzik@pobox.com, mchan@broadcom.com,
	David Miller <davem@davemloft.net>, Andi Kleen <ak@suse.de>,
	Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:9650 "EHLO mx1.slu.se")
	by vger.kernel.org with ESMTP id S965070AbWEaSXP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 May 2006 14:23:15 -0400
To: hadi@cyberus.ca
In-Reply-To: <1149078972.5462.72.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


jamal writes:

 > Latency-wise: TX completion interrupt provides the best latency.
 > Processing in the poll() -aka softirq- was almost close to the hardirq
 > variant. So if you can make things run in a softirq such as transmit
 > one, then the numbers will likely stay the same.
 
 I don't remember we tried tasklet for TX a la Herbert's suggestion but we 
 used use tasklets for controlling RX processing to avoid hardirq livelock
 in pre-NAPI versions.

 Had variants of tulip driver with both TX cleaning at ->poll and TX
 cleaning at hardirq and didn't see any performance difference. The 
 ->poll was much cleaner but we kept Alexey's original work for tulip.

 > Sorry, I havent been following discussions on netchannels[1] so i am not
 > qualified to comment on the "replacement" part Dave mentioned earlier.
 > What I can say is the tx processing doesnt have to be part of the NAPI
 > poll() and still use hardirq.

 Yes true but I see TX numbers with newer boards (wire rate small pakets)
 with cleaing in ->poll. Also now linux is very safe in network "overload" 
 situations. Moving work to hardirq may change that.

 Cheers.

					--ro
