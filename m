From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Make virtio_net support carrier detection
Date: Fri, 13 Mar 2009 12:01:00 -0700 (PDT)
Message-ID: <20090313.120100.266753164.davem@davemloft.net>
References: <20090312.055235.56926675.davem@davemloft.net>
	<200903130809.49523.rusty@rustcorp.com.au>
	<200903131017.11572.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pktoss@gmail.com, dcbw@redhat.com, netdev@vger.kernel.org
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46289
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750971AbZCMTBO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 15:01:14 -0400
In-Reply-To: <200903131017.11572.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Fri, 13 Mar 2009 10:17:11 +1030

> Subject: virtio_net: set carrier on by default.
> 
> Impact: fix carrier detection, older NetworkManager
> 
> This is actually two fixes:
> 1) If the virtio_net device doesn't support carrier, the answer is
>    "yes".  This is because before the status feature there was no way
>    of turning the link off in any host implementation, and it also helps
>    (older) NetworkManager versions to see the device.
> 
> 2) We should start with carrier on: virtnet_update_status() does nothing
>    if the status hasn't changed (ie. doesn't call netif_carrier_on()).
> 
> Reported-by: Pantelis Koukousoulas <pktoss@gmail.com>
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

You can set netif_carrier_on() until you are blue in the face,
but until you hook up the ethtool link indication operation
NetworkManager won't see it.

I don't understand what all of this hob-knobbing is about,
Pantelis's patch was perfect, appropriate, and should have
gone straight in to net-2.6 and probably -stable too.

Is this some kind of control issue Rusty?  It's the only
explanation I can come up with :-))
