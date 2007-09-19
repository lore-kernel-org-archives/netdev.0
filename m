From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [PATCH 5/7] CAN: Add virtual CAN netdevice driver
Date: Wed, 19 Sep 2007 08:26:48 +0200
Message-ID: <46F0C128.70601@hartkopp.net>
References: <20070917100321.18347.0@janus.isnogud.escape.de>	<20070917100440.18347.5@janus.isnogud.escape.de>	<46EFE89D.7050006@trash.net> <ygf7imnzk60.fsf@janus.isnogud.escape.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
To: Urs Thuermann <urs@isnogud.escape.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:18625 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751726AbXISG2P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 02:28:15 -0400
In-Reply-To: <ygf7imnzk60.fsf@janus.isnogud.escape.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Urs Thuermann wrote:
> Now I think we should consider removing the loopback code from
> can_send() and demand from each CAN driver that it *has to* implement
> this itself.
>   

I also thought about this solution, which would remove the 'loopback'
parameter in vcan.c and some loopback code in can_send().

My only concern was, that this would break with standard netdev
behaviour just to send and receive data to/from the medium.
To break with the standard behaviour might be ok here as the PF_CAN only
deals with CAN netdevs (ARPHRD_CAN) which can be seen as some closed
eco-system. But i don't know what should happen, if someone in the
future gets the idea to route CAN-frames over ethernet devices for any
reason? In this case we would have to touch every driver we'd like to
support.

IMO it makes more sense to let the 9 lines of loopback fallback code in
can_send() than to remove it.

Oliver


