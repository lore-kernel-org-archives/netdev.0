From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] netpoll: rework skb transmit queue
Date: Fri, 20 Oct 2006 12:27:53 -0700 (PDT)
Message-ID: <20061020.122753.45515833.davem@davemloft.net>
References: <20061019171814.281988608@osdl.org>
	<20061020.001530.35664340.davem@davemloft.net>
	<20061020084015.5c559326@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:53467
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S2992723AbWJTT1x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Oct 2006 15:27:53 -0400
To: shemminger@osdl.org
In-Reply-To: <20061020084015.5c559326@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Fri, 20 Oct 2006 08:40:15 -0700

> The only user of the drop hook was netconsole, and I fixed that path.
> This probably breaks netdump, but that is out of tree, so it needs
> to fix itself.

I believe that netdump needs to requeue things because dropping the
packet is simply not allowed, and the ->drop callback gives the
netdump code a way to handle things without actually dropping the
packet.  If that's true, you can't just free the SKB on it.

Are you sure your new TX strategy can avoid such drops properly?

Please take a quick peek at the netdump code, it's available, and make
some reasonable effort to determine whether it can still work with
your new code.
