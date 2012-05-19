From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: ip6_fragment() should check
 CHECKSUM_PARTIAL
Date: Fri, 18 May 2012 23:54:09 -0400 (EDT)
Message-ID: <20120518.235409.1621981320285066566.davem@davemloft.net>
References: <1337374935.7029.60.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tore@fud.no
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46985 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932954Ab2ESDzS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 May 2012 23:55:18 -0400
In-Reply-To: <1337374935.7029.60.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 18 May 2012 23:02:15 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Quoting Tore Anderson from :
> 
> If the allfrag feature has been set on a host route (due to an ICMPv6
> Packet Too Big received indicating a MTU of less than 1280),
> TCP SYN/ACK packets to that destination appears to get an incorrect
> TCP checksum. This in turn means they are thrown away as invalid.
> 
> In the case of an IPv4 client behind a link with a MTU of less than
> 1260, accessing an IPv6 server through a stateless translator,
> this means that the client can only download a single large file
> from the server, because once it is in the server's routing cache
> with the allfrag feature set, new TCP connections can no longer
> be established.
> 
> </endquote>
> 
> It appears ip6_fragment() doesn't handle CHECKSUM_PARTIAL properly.
> 
> As network drivers are not prepared to fetch correct transport header, a
> safe fix is to call skb_checksum_help() before fragmenting packet.
> 
> Reported-by: Tore Anderson <tore@fud.no>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Tested-by: Tore Anderson <tore@fud.no>

Applied, thanks.
