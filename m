From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH -rt DO NOT APPLY] Fix for tg3 networking lockup
Date: Thu, 03 Aug 2006 16:28:19 -0700
Message-ID: <1154647699.3117.26.camel@rh4>
References: <E1G8a0J-0002Pn-00@gondolin.me.apana.org.au>
 <1154630207.3117.17.camel@rh4> <20060803201741.GA7894@thunk.org>
 <20060803.144845.66061203.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: tytso@mit.edu, herbert@gondor.apana.org.au,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:54276 "EHLO
	mms1.broadcom.com") by vger.kernel.org with ESMTP id S1751387AbWHCX0p
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 19:26:45 -0400
To: "David Miller" <davem@davemloft.net>
In-Reply-To: <20060803.144845.66061203.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-08-03 at 14:48 -0700, David Miller wrote:
> From: Theodore Tso <tytso@mit.edu>
> Date: Thu, 3 Aug 2006 16:17:41 -0400
> 
> > eth0: Tigon3 [partno(BCM95704s) rev 2100 PHY(serdes)] (PCIX:100MHz:64-bit) 10/100/1000BaseT Ethernet 00:14:5e:86:44:24
> 
> The 5704 chip will set TG3_FLAG_TAGGED_STATUS, and therefore
> doesn't need the periodic poking done by tg3_timer().
> 

True.  But they also have ASF enabled which requires tg3_timer() to send
the heartbeat periodically.  If the heartbeat is late, ASF may reset the
chip believing that the system has crashed.

> eth0: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[1] Split[0] WireSpeed[0] TSOcap[0]

We'll see if we can do away with the timer-based heartbeat.  That's
probably the best solution.

