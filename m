From: David Miller <davem@davemloft.net>
Subject: Re: multiqueue interrupts...
Date: Fri, 19 Sep 2008 13:12:54 -0700 (PDT)
Message-ID: <20080919.131254.44610374.davem@davemloft.net>
References: <20080918.193815.175549834.davem@davemloft.net>
	<1221824281.3103.8.camel@achroite>
	<48D39B13.60401@myri.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org
To: brice@myri.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43097
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751371AbYISUNI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2008 16:13:08 -0400
In-Reply-To: <48D39B13.60401@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brice Goglin <brice@myri.com>
Date: Fri, 19 Sep 2008 14:29:07 +0200

> Ben Hutchings wrote:
> > On Thu, 2008-09-18 at 19:38 -0700, David Miller wrote:
> > [...]
> >   
> >> So on a multiqueue card with 2 RX queues and 2 TX queues we'd
> >> have names like:
> >>
> >> 	eth0-rx-0
> >> 	eth0-rx-1
> >> 	eth0-tx-0
> >> 	eth0-tx-1
> >>
> >> So let's make an effort to get this done right in 2.6.28 and meanwhile
> >> Arjan can add the irqbalanced code.
> >>     
> >
> > What about the case where an interrupt is shared between RX and TX
> > completions?  Our hardware is very flexible in this regard, but based on
> > performance testing prior to the introduction of TX multiqueue we
> > currently allocate multiple interrupts for RX completions and share the
> > first with TX completions.
> >   
> 
> myri10ge uses the same interrupts for TX and RX. The current name is
> eth%d:slice-%d but we could change it if there's a consensus.

You might be OK as-is.  If we make irqbalanced look for X-%d, you'll
likely be fine.
