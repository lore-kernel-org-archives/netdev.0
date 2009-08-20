From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ibm_newemac: emac_close() needs to call
 netif_carrier_off()
Date: Thu, 20 Aug 2009 02:20:58 -0700 (PDT)
Message-ID: <20090820.022058.160961745.davem@davemloft.net>
References: <fc21faff0908191440p5db84f79h8bb8a73501facae1@mail.gmail.com>
	<fc21faff0908191532i2de570a1g1a6674bf5fe64a05@mail.gmail.com>
	<1250748142.10937.4.camel@pasglop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pgynther@google.com, shemminger@vyatta.com, netdev@vger.kernel.org
To: benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41484
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753383AbZHTJUq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2009 05:20:46 -0400
In-Reply-To: <1250748142.10937.4.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Thu, 20 Aug 2009 16:02:22 +1000

> On Wed, 2009-08-19 at 15:32 -0700, Petri Gynther wrote:
>> Stephen,
>> 
>> I think your suggestion of adding netif_running() check to
>> bond_check_dev_link() is valid and a good fix to the bonding driver.
>> We can do this in a separate patch.
>> 
>> However, I think that the change to ibm_newemac: emac_close() is
>> needed as well. ibm_newemac netdevs should not return
>> netif_carrier_ok() == TRUE when they have been shut down.
> 
> Well, we definitely don't do that in sungem either, since we continue
> the link polling while the interface is down... IE. interface up/down is
> the data path and is orthogonal to the PHY polling in sungem. I suppose
> we -could- stop the polling while the interface is down, though I think
> my initial implementation did only poll the link while the interface was
> up and that was causing endless problems with various laptop-net style
> tools (however that was years and years ago).

It just shows how few people use sungem with bonding :-)

Short term I'm going to add the ibm_newemac change.

Longer term we should probably add the netif_running() check to
bond_check_dev_link().
