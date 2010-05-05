From: Andy Fleming <afleming@freescale.com>
Subject: Re: [PATCH v2] net/gianfar: drop recycled skbs on MTU change
Date: Wed, 5 May 2010 10:18:40 -0500
Message-ID: <C4C9C232-1DA6-43BE-A9FF-4A591E3FF672@freescale.com>
References: <20100503151745.GA17997@Chamillionaire.breakpoint.cc> <o2g2acbd3e41005040829rc5bf7e0dwee8419b2b65e5468@mail.gmail.com> <20100505.005704.115933493.davem@davemloft.net> <20100505083047.GA4398@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0 (Apple Message framework v1078)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>, afleming@gmail.com,
	netdev@vger.kernel.org
To: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:51131 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753084Ab0EEPTF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 May 2010 11:19:05 -0400
In-Reply-To: <20100505083047.GA4398@Chamillionaire.breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On May 5, 2010, at 3:30 AM, Sebastian Andrzej Siewior wrote:

> From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
> 
> The size for skbs which is added to the recycled list is using the
> current descriptor size which is current MTU. gfar_new_skb() is also
> using this size. So after changing or alteast increasing the MTU all
> recycled skbs should be dropped.
> 
> Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
> ---
>>> I think we should probably do this in free_skb_resources.  And remove
>>> the call from gfar_close().
>> 
>> Ok, Sebastian please rework your patch as requested by Andy.
> 
> This has the side effect of dropping them on reset which is not
> required.

Sure, but that's true of the buffers in the BD ring, too.  My theory, here, is just that it's best to treat it the same as the other "skb resources".  If we want to avoid reallocation during a reset, that's a separate patch.  :)

Acked-by: Andy Fleming <afleming@freescale.com>

