From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] IPv4-mapped on wire, :: dst address issue
Date: Tue, 14 Feb 2017 12:14:12 -0500 (EST)
Message-ID: <20170214.121412.1792184705986404249.davem@davemloft.net>
References: <cover.1486937974.git.jtleight@udel.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jtleight@udel.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36998 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754428AbdBNROO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 12:14:14 -0500
In-Reply-To: <cover.1486937974.git.jtleight@udel.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jonathan T. Leighton" <jtleight@udel.edu>
Date: Sun, 12 Feb 2017 17:26:05 -0500

> Under some circumstances IPv6 datagrams are sent with IPv4-mapped IPv6
> addresses as the source. Given an IPv6 socket bound to an IPv4-mapped
> IPv6 address, and an IPv6 destination address, both TCP and UDP will
> will send packets using the IPv4-mapped IPv6 address as the source. Per
> RFC 6890 (Table 20), IPv4-mapped IPv6 source addresses are not allowed
> in an IP datagram. The problem can be observed by attempting to
> connect() either a TCP or UDP socket, or by using sendmsg() with a UDP
> socket. The patch is intended to correct this issue for all socket
> types.
> 
> linux follows the BSD convention that an IPv6 destination address
> specified as in6addr_any is converted to the loopback address.
> Currently, neither TCP nor UDP consider the possibility that the source
> address is an IPv4-mapped IPv6 address, and assume that the appropriate
> loopback address is ::1. The patch adds a check on whether or not the
> source address is an IPv4-mapped IPv6 address and then sets the
> destination address to either ::ffff:127.0.0.1 or ::1, as appropriate.

Series applied, thanks.
