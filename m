From: Oskar Schirmer <oskar@linutronix.de>
Subject: Re: [PATCH] net/fec: carrier off initially to avoid root mount failure
Date: Fri, 8 Oct 2010 22:35:30 +0200
Message-ID: <20101008203530.GA11926@www.tglx.de>
References: <1286454630-7396-1-git-send-email-oskar@linutronix.de> <20101008.103112.189689736.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: oskar@linutronix.de, netdev@vger.kernel.org, dan@embeddedalley.com,
	bigeasy@linutronix.de, hjk@linutronix.de, gerg@uclinux.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.tglx.de ([62.245.132.106]:33627 "EHLO www.tglx.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757681Ab0JHUfr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Oct 2010 16:35:47 -0400
Content-Disposition: inline
In-Reply-To: <20101008.103112.189689736.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 08, 2010 at 10:31:12 -0700, David Miller wrote:
> From: Oskar Schirmer <oskar@linutronix.de>
> Date: Thu,  7 Oct 2010 14:30:30 +0200
> 
> > with hardware slow in negotiation, the system did freeze
> > while trying to mount root on nfs at boot time.
> > 
> > the link state has not been initialised so network stack
> > tried to start transmission right away. this caused instant
> > retries, as the driver solely stated business upon link down,
> > rendering the system unusable.
> > 
> > notify carrier off initially to prevent transmission until
> > phylib will report link up.
> > 
> > Signed-off-by: Oskar Schirmer <oskar@linutronix.de>
> 
> Maybe fs_enet_open() is a better place for this netif_carrier_off()
> call?

The patch is for fec, so I guess You propose fec_enet_open().

> Every open the driver probes the PHY and does phy_start().

netif_carrier handling is done in phylib properly
except with initialisation. So when asking for the most
correct place to fix this, I'ld propose phylib itself:
Shouldn't the correct carrier state be set with
phy_start_machine or phy_device_create when phy state is
set to PHY_DOWN?

Seen from this point of view, the patch I did propose is
a workaround, as much as doing it in the ndo_open, I guess.
