From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 6/6] net: Implmement RFC 6936 (zero RX csums
 for UDP/IPv6)
Date: Mon, 07 Apr 2014 13:16:33 -0400 (EDT)
Message-ID: <20140407.131633.1635128478858805272.davem@davemloft.net>
References: <alpine.DEB.2.02.1404041720560.21339@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55121 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755356AbaDGRQe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Apr 2014 13:16:34 -0400
In-Reply-To: <alpine.DEB.2.02.1404041720560.21339@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Fri, 4 Apr 2014 17:28:24 -0700 (PDT)

> RFC 6936 relaxes the requirement of RFC 2460 that UDP/IPv6 packets which
> are received with a zero UDP checksum value must be dropped. RFC 6936
> allow zero checksums to support tunnels over UDP.
> 
> This patch adds a new socket option UDP_CHECK6_ZERO_OKAY whcih can be
> set on a UDP socket to indicate that a zero checksum is acceptable
> (e.g. the socket is for a tunnel). The ip6 checksum and UDP receive
> functions were updated accordingly to deal with this.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>

I see you reply to this later and say we can use sk_no_check.

Are you really sure?  This might create a surprise for someone
inadvertantly setting that now and expecting it to have a very
specific effect only for ipv4 UDP sockets.

The safest thing to do is to create the new option, then there
is no discrepancy.
