From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: avoid ptype_all packet handling
Date: Fri, 02 Mar 2007 13:26:38 -0800 (PST)
Message-ID: <20070302.132638.38710461.davem@davemloft.net>
References: <20070228171846.679d8733@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bridge@linux-foundation.org, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42478
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965662AbXCBV0j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Mar 2007 16:26:39 -0500
In-Reply-To: <20070228171846.679d8733@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Wed, 28 Feb 2007 17:18:46 -0800

> I was measuring bridging/routing performance and noticed this.
> 
> The current code runs the "all packet" type handlers before calling the
> bridge hook.  If an application (like some DHCP clients) is using AF_PACKET,
> this means that each received packet gets run through the Berkeley Packet Filter
> code in sk_run_filter (slow).

I know we closed this out by saying that even though performance
sucks, we can't really apply this without breaking things.

What would be broken is if the DHCP client isn't specifying
a device ifindex when it binds the AF_PACKET socket.  That
would be an easy way to fix this performance problem at the
application level.

The DHCP client should only care about a particular interface's
traffic, the one it wants to listen on.
