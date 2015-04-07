From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next 1/4] via-rhine: commit receive buffer address
 before descriptor status update.
Date: Tue, 7 Apr 2015 23:02:48 +0200
Message-ID: <20150407210248.GC24631@electric-eye.fr.zoreil.com>
References: <cover.1428340371.git.romieu@fr.zoreil.com>
 <cover.1428340371.git.romieu@fr.zoreil.com>
 <87c90b27962c818239073d3a65341054922bd563.1428340371.git.romieu@fr.zoreil.com>
 <20150407.155209.47396464487922345.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, nix@esperi.org.uk, rl@hellgate.ch,
	gurligebis@gentoo.org,
	Alexander Duyck <alexander.h.duyck@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:54209 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752972AbbDGVDD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2015 17:03:03 -0400
Content-Disposition: inline
In-Reply-To: <20150407.155209.47396464487922345.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> :
> From: Francois Romieu <romieu@fr.zoreil.com>
[...]
> > @@ -2063,6 +2063,7 @@ static int rhine_rx(struct net_device *dev, int limit)
> >  				break;
> >  			}
> >  			rp->rx_ring[entry].addr = cpu_to_le32(rp->rx_skbuff_dma[entry]);
> > +			wmb();
> 
> dma_wmb() perhaps?  I think this is exactly the situation that interface was
> added for.

I need the buffer address to be written in the receive descriptor before
the descriptor status is. The cpu does W1, W2 and the nic mustn't see W2, W1.

-- 
Ueimor
