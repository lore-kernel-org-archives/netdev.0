From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: PROBLEM: Linux kernel 2.6.31 IPv4 TCP fails to open huge amount of outgoing connections (unable to bind ... )
Date: Wed, 21 Apr 2010 22:27:23 +0400
Message-ID: <20100421182723.GA17202@ioremap.net>
References: <4BCE392F.60104@candelatech.com> <y2p46c8cb3e1004201635s8f84672dq90d3115dca04a1ed@mail.gmail.com> <4BCE3D8D.3030500@candelatech.com> <1271808314.7895.614.camel@edumazet-laptop> <20100421003022.GA3107@ioremap.net> <1271828799.7895.1287.camel@edumazet-laptop> <20100421082559.GA32475@ioremap.net> <1271840535.7895.1612.camel@edumazet-laptop> <20100421095812.GA14778@ioremap.net> <1271849253.7895.1929.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Greear <greearb@candelatech.com>,
	David Miller <davem@davemloft.net>,
	Gaspar Chilingarov <gasparch@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cs-studio.ru ([195.178.208.66]:57910 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756095Ab0DUS12 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Apr 2010 14:27:28 -0400
Content-Disposition: inline
In-Reply-To: <1271849253.7895.1929.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 21, 2010 at 01:27:33PM +0200, Eric Dumazet (eric.dumazet@gmail.com) wrote:
> Here is the patch I use now and my test application is now able to open
> and connect 1000000 sockets (ulimit -n 1000000)
> 
> Trick is bind_conflict() must refuse a socket to bind to a port on a non
> null IP if another socket already uses same port on same IP.
> 
> Plus the previous patch sent (check a conflict before exiting the search
> loop)
> 
> What do you think ?

Looks good, but do we want to check only reused socket's address there?
What if one of the sockets does not have reuse option turned on, will it
break?

-- 
	Evgeniy Polyakov
