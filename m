From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sky2: Lock transmit queue while disabling device
Date: Wed, 06 Jan 2010 20:27:01 -0800 (PST)
Message-ID: <20100106.202701.161194890.davem@davemloft.net>
References: <4B3C8323.1080301@ring3k.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org, flyboy@gmail.com,
	dhazelton@enter.net, mbreuer@majjas.com,
	"netdev@vger.kernel.org"@ogre.sisk.pl
To: mikem@ring3k.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33746
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756021Ab0AGE0x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2010 23:26:53 -0500
In-Reply-To: <4B3C8323.1080301@ring3k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike McCormack <mikem@ring3k.org>
Date: Thu, 31 Dec 2009 19:55:31 +0900

> 
> netif_device_detach() does not take the tx_lock, so it's
>  possible that a call to sky2_xmit_frame is still in
>  progress after netif_device_detach() is complete.
> 
> Take netif_tx_lock() to make sure all transmits have
>  stopped while we're disabling the devices and that
>  no other CPU is still transmitting a frame after
>  we've disabling the device.
> 
> Proposed fix for "sky2 panic under load" reported by Berck E. Nash.
> 
> Signed-off-by: Mike McCormack <mikem@ring3k.org>

Applied to net-next-2.6

Stephen has asked for some further refinements, once that is
all sorted we can think about backporting this to net-2.6
and -stable if necessary.

Thanks.
