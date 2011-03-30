From: David Miller <davem@davemloft.net>
Subject: Re: ethtool physical identify vs netlink locking?
Date: Tue, 29 Mar 2011 17:13:28 -0700 (PDT)
Message-ID: <20110329.171328.28814158.davem@davemloft.net>
References: <20110329135252.116bf5e0@s6510>
	<1301443676.10056.57.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36981
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751605Ab1C3AOH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2011 20:14:07 -0400
In-Reply-To: <1301443676.10056.57.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 30 Mar 2011 01:07:56 +0100

> In the sfc driver, physical ID used to be delegated to the PHY
> operations.  Then I realised that it was pointless to use a PHY's blink
> mode where it was available and a periodic timer on the host where it
> wasn't, when the latter would work for all of them.  So I would propose:
> 
> 4. Define a ethtool operation 'set_id_state' with an argument that sets
> identification on/off/inactive/active (the last optional, for any driver
> that really wants to do this differently).  When this is defined, the
> ethtool core runs the loop and acquires the lock each time it calls this
> operation.
> 
> This requires changes to every driver, though not all at once.  As an
> additional benefit, it should result in consistent behaviour for the
> count = 0 case.

This seems like a good way to solve the problem.
