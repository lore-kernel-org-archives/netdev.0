From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [RFC] Potential bug in defining 'irq field' of 'ifmap
 structure'
Date: Mon, 06 Jul 2009 17:25:01 -0700 (PDT)
Message-ID: <20090706.172501.136390568.davem@davemloft.net>
References: <CD8CC2B65FEE304DA95744A5472698F202952C3124@dlee06.ent.ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-omap@vger.kernel.org,
	vikram.pandita@ti.com
To: m-sonasath@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50244
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759966AbZGGAYy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2009 20:24:54 -0400
In-Reply-To: <CD8CC2B65FEE304DA95744A5472698F202952C3124@dlee06.ent.ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Sonasath, Moiz" <m-sonasath@ti.com>
Date: Mon, 6 Jul 2009 17:23:36 -0500

> There seems to be a bug in the ioctl implementation in /kernel/net/core/dev.c 
>  
> dev_ifsioc_locked()
> 	case SIOCGIFMAP:
> 			ifr->ifr_map.irq = dev->irq;   // ?? type mismatch
> 
> Here
> ifr->ifr_map.irq) is of type unsigned char
> dev-irq is of type unsigned int
> 
> So ifconfig reports a wrong irq number when the dev->irq number is > 255.

This is a known and unavoidable limitation of this interface.
It's only real use is to control ISA style IRQs which are
< 255.

> I am confused to see the same typedefs in file: net/if.h 
> Not sure how to make changes for the user side net/if.h file?
> 
> Signed-off-by: Moiz Sonasath <m-sonasath@ti.com>
> Signed-off-by: Vikram Pandita <vikram.pandita@ti.com>

You can't make these kinds of changes, every userland binary out there
using this structure would break.
