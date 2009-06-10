From: David Miller <davem@davemloft.net>
Subject: Re: IPoIB: Fix multicast packet drops before join is complete
Date: Tue, 09 Jun 2009 22:12:09 -0700 (PDT)
Message-ID: <20090609.221209.07018418.davem@davemloft.net>
References: <ada1vps4u9e.fsf@cisco.com>
	<20090609.215719.214969588.davem@davemloft.net>
	<adaski83ciy.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cl@linux-foundation.org, netdev@vger.kernel.org,
	yosefe@Voltaire.COM
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35850
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752310AbZFJFMH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 01:12:07 -0400
In-Reply-To: <adaski83ciy.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roland Dreier <rdreier@cisco.com>
Date: Tue, 09 Jun 2009 22:04:21 -0700

>  > If a facility doesn't exist yet, we're going to have to create
>  > one.  It would need to do a downcall to the device when the
>  > user joins a multicast group on a socket, and then the device
>  > can do whatever magic is necessary to speak multicast immediately
>  > and sleep until it really is available for immediate use.
> 
> But a send-only membership is created when a multicast packet is sent,
> which an application can do just with sendto() -- do we want to plumb
> all the way from sendto() down to the device the packet is ultimately
> going to be sent on?
> 
> There isn't any corresponding code to block an app during ARP
> resolution, is there?

Nope.

But the problem is that it's incredibly invasive to applications
how IPoIB behaves for multicast traffic.  It's much more biting
than ARP because usually ARP hits you when you do your connection
attempt or initial DNS request, then it's resolved and smooth
sailing.

Here the app can send a voluminous amount of application data
at the destination and it'll mostly drop on the floor currently.
This is bad.

ARP doesn't typically toss real application data, this does.
