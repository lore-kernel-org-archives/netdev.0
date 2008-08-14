From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: Multicast socket behaviour?
Date: Wed, 13 Aug 2008 18:30:44 -0700
Message-ID: <OF9194BEB8.A965F7A7-ON882574A5.00076CE8-882574A5.00084E9D@us.ibm.com>
References: <loom.20080814T000653-690@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev@vger.kernel.org
To: Daniel Ng <daniel_ng11@lycos.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:49641 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750989AbYHNBat (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2008 21:30:49 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m7E1UlCv017083
	for <netdev@vger.kernel.org>; Wed, 13 Aug 2008 21:30:47 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m7E1Ukej179968
	for <netdev@vger.kernel.org>; Wed, 13 Aug 2008 19:30:46 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m7E1Uk1x021572
	for <netdev@vger.kernel.org>; Wed, 13 Aug 2008 19:30:46 -0600
In-Reply-To: <loom.20080814T000653-690@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev-owner@vger.kernel.org wrote on 08/13/2008 05:08:58 PM:

> David Stevens <dlstevens <at> us.ibm.com> writes:
> > it usually doesn't make sense for an app in a single multicast
> > routing domain to want to join on multiple interfaces
> 
> Now, what if I have a linear network of say 3 Linux boxes, connected 
together 
> simply:
> 
> A----PPP0-------B-----PPP1------C
> 
> All machines are DVMRP multicast routers.
> 
> In order for B to hear the multicast packets originated from both A and 
C, 
> wouldn't B need to join the DVMRP multicast group on *both* its PPP 
interfaces?

        I don't believe so. An application on B can join the
group on either PPP0 or PPP1 and the multicast router on
whichever one you join is responsible for forwarding any
packets for that group to all links that have a listener
for it.
        If B itself is the multicast router, then it may
touch the packets twice, but logically all three hosts are
in the same routing domain and an application can listen
to groups on any link. If your app joins on both links,
I'd expect you to get 2 copies of everything.

        I've done a lot of work on the host-side of multicasting,
but nothing with multicast routing, so I certainly could
be wrong, but I believe an app on B in this case shouldn't
join on both links, either.

                                                        +-DLS


