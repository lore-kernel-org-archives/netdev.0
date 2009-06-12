From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] Restricting MDIO reads
Date: Thu, 11 Jun 2009 21:00:44 -0700 (PDT)
Message-ID: <20090611.210044.189146193.davem@davemloft.net>
References: <1244736247.2785.35.camel@achroite>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36263
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752022AbZFLEAl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jun 2009 00:00:41 -0400
In-Reply-To: <1244736247.2785.35.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 11 Jun 2009 17:04:07 +0100

> Currently most drivers[1] that support the "MII" ioctls allow all users
> to read MDIO registers, while MDIO writes require CAP_NET_ADMIN.
> 
> However, some MDIO registers and register bits have read-to-clear (latch
> high, latch low or non-rollover) or multi-word latching semantics[2].
> So reading from them may interfere with the driver or other users and
> should also require CAP_NET_ADMIN.
> 
> It's not clear to me just which registers should be safe to read, and
> this can vary between PHYs.   I think the correct thing to do is either
> to restrict all MDIO reads or to whitelist standard-defined safe
> registers.
> 
> Which applications, if any, depend on performing MDIO reads as an
> unprivileged user?  Which registers do they expect to read?

I think we should apply CAP_NET_ADMIN to all register reads.

Anything without privs trying to read those things is asking
for trouble.  It's an access with arbitrary, device specific,
side effects.  Not exactly something we should ever allow the
user to do without privs.

