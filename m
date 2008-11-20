From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/33] netdev: network device operations infrastructure
Date: Wed, 19 Nov 2008 21:26:50 -0800 (PST)
Message-ID: <20081119.212650.102527885.davem@davemloft.net>
References: <20081117234207.854110282@vyatta.com>
	<20081117234354.864259203@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51465
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752623AbYKTF0u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 00:26:50 -0500
In-Reply-To: <20081117234354.864259203@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 17 Nov 2008 15:42:08 -0800

> This patch changes the network device internal API to move adminstrative
> operations out of the network device structure and into a separate structure.
> 
> This patch involves some hackery to maintain compatablity between the
> new and old model, so all 300+ drivers don't have to be changed at once.
> For drivers that aren't converted yet, the netdevice_ops virt function list
> still resides in the net_device structure. For old protocols, the new
> net_device_ops are copied out to the old net_device pointers.
> 
> After the transistion is completed the nag message can be changed to
> an WARN_ON, and the compatiablity code can be made configurable.
> 
> Some function pointers aren't moved:
> * destructor can't be in net_device_ops because 
>   it may need to be referenced after the module is unloaded.
> * neighbor setup is manipulated in a couple of places that need special
>   consideration
> * hard_start_xmit is in the fast path for transmit.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Ok, I'm applying this but it needs the following interdiff to cure some
build failures.

And I'm also going to add the "ndo_*" prefix to the netdev_ops member
names as suggested by Eric.

I'll fix up the remaining patches as needed, so don't worry about that.
