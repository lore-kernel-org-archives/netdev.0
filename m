From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -rt DO NOT APPLY] Fix for tg3 networking lockup
Date: Thu, 03 Aug 2006 16:43:11 -0700 (PDT)
Message-ID: <20060803.164311.91310742.davem@davemloft.net>
References: <20060803201741.GA7894@thunk.org>
	<20060803.144845.66061203.davem@davemloft.net>
	<1154647699.3117.26.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tytso@mit.edu, herbert@gondor.apana.org.au,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:47842
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751380AbWHCXnJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 19:43:09 -0400
To: mchan@broadcom.com
In-Reply-To: <1154647699.3117.26.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 03 Aug 2006 16:28:19 -0700

> > eth0: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[1] Split[0] WireSpeed[0] TSOcap[0]
> 
> We'll see if we can do away with the timer-based heartbeat.  That's
> probably the best solution.

The tg3 driver is not the only device in the world that requires a
timer based "ping" to work.  The watchdog drivers and the softlockup
detector are other instances which require a timer to not be delayed
an unreasonable amount of time.

Therefore TG3 is not unique in this regard, and I thus don't think
it's worthwhile to change tg3 just to accomodate this broken behavior
of the RT patches.
