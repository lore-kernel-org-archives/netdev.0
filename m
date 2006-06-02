From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: netif_tx_disable and lockless TX
Date: Fri, 2 Jun 2006 12:46:35 +0200
Message-ID: <17536.5899.786413.547480@robur.slu.se>
References: <20060531051451.GA7110@gondor.apana.org.au>
	<20060530.232626.00456312.davem@davemloft.net>
	<20060531063152.GA8032@gondor.apana.org.au>
	<20060531.000818.78646242.davem@davemloft.net>
	<20060531120626.GA11925@gondor.apana.org.au>
	<1149078972.5462.72.camel@jzny2>
	<17533.55270.172654.98522@robur.slu.se>
	<447FAFAD.9000503@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>, hadi@cyberus.ca,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org, jgarzik@pobox.com, mchan@broadcom.com,
	David Miller <davem@davemloft.net>, Andi Kleen <ak@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:25501 "EHLO mx1.slu.se")
	by vger.kernel.org with ESMTP id S1751385AbWFBKrl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2006 06:47:41 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <447FAFAD.9000503@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Stephen Hemminger writes:

 > I also noticed that you really don't save much by doing TX cleaning at 
 > hardirq, because in hardirq you need to do dev_kfree_irq and that causes 
 > a softirq (for the routing case where users=1). So when routing it 
 > doesn't make much difference, both methods cause the softirq delayed 
 > processing to be invoked. For locally generated packets which are 
 > cloned, the hardirq will drop the ref count, and that is faster than 
 > doing the whole softirq round trip.

 Right. Also the other way around, repeated ->poll can avoid TX hardirq's.

 Cheers.
						--ro
