From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Re: IPv4 / IPv6 over IPv4 IPsec tunnel: setting the DF bit
Date: Thu, 30 Jan 2014 16:59:45 +0100
Message-ID: <20140130155945.GF25336@order.stressinduktion.org>
References: <20140130142116.GD25336@order.stressinduktion.org> <trinity-a9289159-8d0c-4ad1-8586-e8987e008643-1391095583899@3capp-gmx-bs16>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Simon Schneider <simon-schneider@gmx.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:47123 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753273AbaA3P7r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jan 2014 10:59:47 -0500
Content-Disposition: inline
In-Reply-To: <trinity-a9289159-8d0c-4ad1-8586-e8987e008643-1391095583899@3capp-gmx-bs16>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 30, 2014 at 04:26:24PM +0100, Simon Schneider wrote:
> Hi Hannes,
> thanks once again for the quick reply.
> 
> Quickly checked the ip manpage. I'm clear about the case where pmtudisc is in effect (default) - the DF bit must be TRUE in this case, for PMTUD to work.
> 
> Not sure what you meant by:
> 
> "but DF bit should get copied from inner packet up to tunnel header in every
> case"
> 
> Do you mean the nopmtudisc case?

Exactly. In nopmtudisc mode the flag is set based on the inner protocols df
bit, default cleared. In pmtudisc mode the DF-flag is always set.

> Also, IPv6 must be different then - there's no DF bit to be copied.

If packet cannot traverse a router frag_needed is returned, tunnel
endpoint relays the icmp info to the original sender and it should update
its pmtu. There is no way to fragment the packet mid-path.

Also IPv6 tunnel endpoint do not fragment the tunnel packets while
encapsulating.

ipsec mode tunnel is allowed to fragment the packets while encapsulation.

> Could you please clarify?

Hope I did. ;)

Greetings,

  Hannes
