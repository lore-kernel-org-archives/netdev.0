From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/fec: carrier off initially to avoid root mount
 failure
Date: Fri, 08 Oct 2010 10:31:12 -0700 (PDT)
Message-ID: <20101008.103112.189689736.davem@davemloft.net>
References: <1286454630-7396-1-git-send-email-oskar@linutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dan@embeddedalley.com,
	bigeasy@linutronix.de, hjk@linutronix.de
To: oskar@linutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55881
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753784Ab0JHRav (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Oct 2010 13:30:51 -0400
In-Reply-To: <1286454630-7396-1-git-send-email-oskar@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oskar Schirmer <oskar@linutronix.de>
Date: Thu,  7 Oct 2010 14:30:30 +0200

> with hardware slow in negotiation, the system did freeze
> while trying to mount root on nfs at boot time.
> 
> the link state has not been initialised so network stack
> tried to start transmission right away. this caused instant
> retries, as the driver solely stated business upon link down,
> rendering the system unusable.
> 
> notify carrier off initially to prevent transmission until
> phylib will report link up.
> 
> Signed-off-by: Oskar Schirmer <oskar@linutronix.de>

Maybe fs_enet_open() is a better place for this netif_carrier_off()
call?

Every open the driver probes the PHY and does phy_start().
