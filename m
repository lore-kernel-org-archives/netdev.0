From: venkatesh natarajan <venks@hp.com>
Subject: Re: GTSM and TCP accept problem
Date: Mon, 3 Oct 2011 01:46:51 +0000 (UTC)
Message-ID: <loom.20111003T034624-148@post.gmane.org>
References: <20100814214634.24a87715@s6510> <1281951825.2524.5.camel@edumazet-laptop> <20100818143913.1478acea@nehalam> <20100818.144837.179941999.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:42250 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754887Ab1JCBzK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Oct 2011 21:55:10 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1RAXkJ-00052R-90
	for netdev@vger.kernel.org; Mon, 03 Oct 2011 03:55:07 +0200
Received: from bbnwebdproxy3.europe.hp.net ([15.195.185.83])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 03 Oct 2011 03:55:07 +0200
Received: from venks by bbnwebdproxy3.europe.hp.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 03 Oct 2011 03:55:07 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem <at> davemloft.net> writes:

> 
> From: Stephen Hemminger <shemminger <at> vyatta.com>
> Date: Wed, 18 Aug 2010 14:39:13 -0700
> 
> > On Mon, 16 Aug 2010 11:43:45 +0200
> > Eric Dumazet <eric.dumazet <at> gmail.com> wrote:
> > 
> >> Another idea would be to store the TTL of the SYN packet (or third
> >> packet) and let application read it after accept(), allowing it to
> >> reject the connection if it doesnt match expected TTL.
> > 
> > could be in tcp_info?
> 
> I'm sure we can squeeze a byte out of there 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo <at> vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 


I am facing the same issue with the implementation of GTSM for BGP. Typically 
the outbound TTL value set is 64. With min_ttl implementaion we set the outbound 
TTL value of 255 by default. So all bgp speakers will send out 255 in their 
connect SYN packets. Lets say we configure the min_ttl of 254 on the listen 
socket then it will allow only those peers that are 2 hops away to connect 
(Which is correct for eBGP Peers) but it will also filter out legitimate connect 
SYN packets that come from iBGP peers that are more than 2 hops away (Which I 
feel is a unexpected behavior). 

How can accept check for iBGP peers and not check for the MIN_TTL. I feel this 
could be done only by pushing the iBGP Peer ip-address information to accept so 
that it can bypass MIN_TTL Checks for them.

If I apply the MIN_TTL setsockopt on the accepted socket (Instead of seting it 
on the listen socket) then I open up the port for DOS attack at the tcp level by 
allowing attackers to establish connection and repeatedly..

Have I understood the problem correctly or have gone off-tangent on this.

Thanks
Venks
