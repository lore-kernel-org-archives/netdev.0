From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] don't put multicasts with mc_ttl=0 on the wire
Date: Tue, 15 May 2007 13:45:40 -0700 (PDT)
Message-ID: <20070515.134540.45873471.davem@davemloft.net>
References: <20070515195602.GK19036@sgi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, arenaud@sgi.com
To: akepner@sgi.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35576
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751153AbXEOUpe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2007 16:45:34 -0400
In-Reply-To: <20070515195602.GK19036@sgi.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akepner@sgi.com
Date: Tue, 15 May 2007 12:56:02 -0700

> A colleague of mine found that multicasts with a ttl of 0
> can be sent on the wire. This happens if the sender doesn't
> belong to the destination multicast group.
> 
> With the following the multicast ttl is respected whether
> or not the sender belongs to the destination multicast group.
> 
> Signed-off-by: Arthur Kepner <akepner@sgi.com>

This is actually used by some things if I remember correctly.
See this command and code in net/ipv4/route.c:

			/* Special hack: user can direct multicasts
			   and limited broadcast via necessary interface
			   without fiddling with IP_MULTICAST_IF or IP_PKTINFO.
			   This hack is not just for fun, it allows
			   vic,vat and friends to work.
			   They bind socket to loopback, set ttl to zero
			   and expect that it will work.
			   From the viewpoint of routing cache they are broken,
			   because we are not allowed to build multicast path
			   with loopback source addr (look, routing cache
			   cannot know, that ttl is zero, so that packet
			   will not leave this host and route is valid).
			   Luckily, this hack is good workaround.
			 */

			fl.oif = dev_out->ifindex;
			goto make_route;
