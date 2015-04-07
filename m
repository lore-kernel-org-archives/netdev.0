From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/4] via-rhine: commit receive buffer address
 before descriptor status update.
Date: Tue, 07 Apr 2015 17:27:48 -0400 (EDT)
Message-ID: <20150407.172748.700634713750750146.davem@davemloft.net>
References: <87c90b27962c818239073d3a65341054922bd563.1428340371.git.romieu@fr.zoreil.com>
	<20150407.155209.47396464487922345.davem@davemloft.net>
	<20150407210248.GC24631@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nix@esperi.org.uk, rl@hellgate.ch,
	gurligebis@gentoo.org, alexander.h.duyck@redhat.com
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59782 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753833AbbDGV1u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2015 17:27:50 -0400
In-Reply-To: <20150407210248.GC24631@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Tue, 7 Apr 2015 23:02:48 +0200

> David Miller <davem@davemloft.net> :
>> From: Francois Romieu <romieu@fr.zoreil.com>
> [...]
>> > @@ -2063,6 +2063,7 @@ static int rhine_rx(struct net_device *dev, int limit)
>> >  				break;
>> >  			}
>> >  			rp->rx_ring[entry].addr = cpu_to_le32(rp->rx_skbuff_dma[entry]);
>> > +			wmb();
>> 
>> dma_wmb() perhaps?  I think this is exactly the situation that interface was
>> added for.
> 
> I need the buffer address to be written in the receive descriptor before
> the descriptor status is. The cpu does W1, W2 and the nic mustn't see W2, W1.

That's exactly dma_wmb().

It barriers cpu writes so that the device sees things in a certain
order.

It's what all the most common ethernet chip drivers use in their
descriptor handling routines now.
