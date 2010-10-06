From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/fec: fix link/queue interaction, wake queue iff
 link is up
Date: Wed, 06 Oct 2010 14:15:40 -0700 (PDT)
Message-ID: <20101006.141540.260064338.davem@davemloft.net>
References: <1286364718-20070-1-git-send-email-oskar@linutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dan@embeddedalley.com,
	bigeasy@linutronix.de, hjk@linutronix.de
To: oskar@linutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43081
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933101Ab0JFVPT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Oct 2010 17:15:19 -0400
In-Reply-To: <1286364718-20070-1-git-send-email-oskar@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oskar Schirmer <oskar@linutronix.de>
Date: Wed,  6 Oct 2010 13:31:58 +0200

> with hardware slow in negotiation, the system did freeze
> while trying to mount root on nfs at boot time.
> 
> while the driver did report being busy when the link is down
> or no transmission buffers are available, it did not stop the
> queue, causing instant retries. furthermore, transmission being
> triggered with link down was caused by unconditional queue
> wakes, especially on timeouts.
> 
> now, wake queue only iff link is up and transmission
> buffers are available, and dont forget to wake queue
> when link has been adjusted. next, add stop queue notification
> upon driver induced transmission problems, so network stack has
> a chance to handle the situation.
> 
> Signed-off-by: Oskar Schirmer <oskar@linutronix.de>

You should never have to do this.

As long as netif_carrier_on() and netif_carrier_off() are invoked
properly by the driver, the core networking will never send you
packets when netif_carrier_ok() is false.

I am not applying this patch, drivers should not manage tx queue
state using link status as a condition, that's the job of the
core networking.
