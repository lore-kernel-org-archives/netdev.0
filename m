From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: question on raw sockets and source IP address validation
Date: Thu, 24 Sep 2009 15:26:51 -0400
Message-ID: <20090924192651.GC19787@hmsreliant.think-freely.org>
References: <4ABBB223.8090700@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: Chris Friesen <cfriesen@nortel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:56818 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754134AbZIXT0t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2009 15:26:49 -0400
Content-Disposition: inline
In-Reply-To: <4ABBB223.8090700@nortel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 24, 2009 at 11:53:39AM -0600, Chris Friesen wrote:
> Hi all,
> 
> Normally when sending a packet on a SOCK_RAW socket the source IP
> address is validated against the addresses configured on the host.  If
> the address isn't configured, the packet isn't sent.
> 
> This can be avoided by setting IP_HDRINCL, but then the app needs to
> handle all the fragmentation itself.
> 
> Is there any way to bypass the source address validation without IP_HDRINCL?
> 
Nope, not with socket(AF_INET, SOCK_RAW, ...).  its an IPv4 socket, so you get
ipv4 routing.  If you don't want the ipv4 behavior, you can always use
AF_PACKET, to send raw frames direct to network interfaces.  Of course, thats
going to imply that you do all your ip level fragmentation yourself as well.

That said, its not doing source validation, your socket is actually doing a
route lookup on the flow from your specified source address to your destination
address.  So you should be able to fool the socket into doing the lookup by
adding a route to your routing table from your source address to your
destination address via the interface that you want to send the frames out of.

Regards
Neil

> Thanks,
> 
> Chris
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
