From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] sis900: Fix the tx queue timeout issue
Date: Fri, 02 Aug 2013 15:04:00 -0700 (PDT)
Message-ID: <20130802.150400.1854139334376781614.davem@davemloft.net>
References: <1375437054-1995-1-git-send-email-kda@linux-powerpc.org>
	<1375471135.32254.15.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kda@linux-powerpc.org, venza@brownhat.org, B38611@freescale.com,
	netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42320 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753747Ab3HBWEB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Aug 2013 18:04:01 -0400
In-Reply-To: <1375471135.32254.15.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 2 Aug 2013 21:18:55 +0200

> This looks reasonable.  It looks like link changes now work like this:
> 
> 1. When sis900_timer() detects link-down, it calls netif_carrier_off()
> but does not clear autong_complete.
> 2. When sis900_timer() detects link-up, it calls sis900_check_mode()
> which restarts autonegotiation and clears autong_complete.
> 3. sis900_timer() will now call sis900_read_mode().  When that detects
> link-up, it sets autong_complete and calls netif_carrier_on().
> 
> This patch has moved the call to netif_carrier_on() from step 2 to step
> 3.  However, I don't understand why autonegotiation is restarted in step
> 2.  When autonegotiation is enabled, the PHY should not indicate link-up
> until it has completed.  Perhaps this is a necessary workaround for a
> hardware bug.  Otherwise it's a waste of time.

Agreed, if the PHY was configured to use autonegotiation, getting a link
up event afterwards implies that autonegotiation is complete.

In any event, I'm going to apply this patch anyways because it is far and
above a significant move forward.
