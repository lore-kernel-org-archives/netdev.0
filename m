From: David Miller <davem@davemloft.net>
Subject: Re: TTL=0 multicast packets leaving host
Date: Mon, 19 Dec 2011 16:06:01 -0500 (EST)
Message-ID: <20111219.160601.947997861151242331.davem@davemloft.net>
References: <20111207213158.GA2444@BohrerMBP.rgmadvisors.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sbohrer@rgmadvisors.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58943 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752361Ab1LSVGI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2011 16:06:08 -0500
In-Reply-To: <20111207213158.GA2444@BohrerMBP.rgmadvisors.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shawn Bohrer <sbohrer@rgmadvisors.com>
Date: Wed, 7 Dec 2011 15:31:58 -0600

> This looks like a bug to me.  I'd assume that if the local computer
> has not joined the multicast group and I send a TTL=0 packet that it
> would simply get discarded.

This behavior is intentional, several multicast applications set TTL
to zero and expect it to reach the local network.

See the comment elsewhere in route.c:

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
