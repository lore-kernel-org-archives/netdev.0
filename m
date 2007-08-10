From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] Add ETHTOOL_[GS]FLAGS sub-ioctls
Date: Fri, 10 Aug 2007 15:10:39 -0700 (PDT)
Message-ID: <20070810.151039.31642625.davem@davemloft.net>
References: <20070810202426.GA25050@havoc.gtf.org>
	<46BCD263.6050807@garzik.org>
	<46BCD47C.9060408@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, auke-jan.h.kok@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42041
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1766007AbXHJWKj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 18:10:39 -0400
In-Reply-To: <46BCD47C.9060408@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Greear <greearb@candelatech.com>
Date: Fri, 10 Aug 2007 14:11:24 -0700

> Jeff Garzik wrote:
> 
> > This patch copies Auke in adding NETIF_F_LRO.  Is that just for 
> > temporary merging, or does the net core really not touch it at all?
> > 
> > Because, logically, if NETIF_F_LRO exists nowhere else but this patch, 
> > we should not add it to dev->features.  LRO knowledge can be contained 
> > entirely within the driver, if the net core never tests NETIF_F_LRO.
> > 
> > I haven't reviewed the other NETIF_F_XXX flags, but, that logic can be 
> > applied to any other NETIF_F_XXX flag:  if the net stack isn't using it, 
> > it's a piece of information specific to that driver.
> 
> I believe LRO is going to have to be disabled for routing/bridging,
> so the stack will probably need to become aware of it at some point...

The packet will be GSO'd on output I believe, so it won't
break anything.

Alternatively, we could make the driver only LRO accumulate if the
packet is unicast and matches one of the MAC's programmed into the
chip.
