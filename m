From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] IPV6: remove addresses and routes when carrier is
 lost
Date: Tue, 03 Jun 2008 10:30:59 -0700 (PDT)
Message-ID: <20080603.103059.193720094.davem@davemloft.net>
References: <20080603102144.571df55b@extreme>
	<20080603.102501.193702820.davem@davemloft.net>
	<20080604.022836.31952523.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54032
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755273AbYFCRbC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 13:31:02 -0400
In-Reply-To: <20080604.022836.31952523.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Wed, 04 Jun 2008 02:28:36 +0900 (JST)

> In article <20080603.102501.193702820.davem@davemloft.net> (at Tue, 03 Jun 2008 10:25:01 -0700 (PDT)), David Miller <davem@davemloft.net> says:
> 
> > From: Stephen Hemminger <shemminger@vyatta.com>
> > Date: Tue, 3 Jun 2008 10:21:44 -0700
> > 
> > > The patch just makes carrier_off respond the same as doing 'ip link set dev eth0 down'
> > > (or ifconfig eth0 down). A router needs to be able to re-route when link fails.
> > 
> > But I can't see how this behavior makes sense for the normal desktop case
> > and it disagrees with existing practice for many years.
> > 
> > If I pull out my network cable while making some adjustments in my
> > rack, and then plug it back in, I don't expect to lose my static
> > routes on that interface.
> > 
> > That doesn't make any sense at all.
> 
> How about ignoring routes via down interface?

Look at what happens now in my example case.  The packets simply get
queued in the device queue until the carrier comes back up.  Once
it comes back up, the packets go out with zero packet loss.

With your suggestion, the packets will get dropped if there are no
other devices with active routes to the destination, which is a very
poor quality of implementation decision in my opinion, especially for
this case.
