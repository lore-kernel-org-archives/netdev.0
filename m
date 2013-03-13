From: Timo Teras <timo.teras@iki.fi>
Subject: linux-3.6+, gre+ipsec+forwarding = IP fragmentation broken
Date: Wed, 13 Mar 2013 17:14:53 +0200
Message-ID: <20130313171453.0297f179@vostro>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f181.google.com ([209.85.215.181]:45016 "EHLO
	mail-ea0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933699Ab3CMPOQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 11:14:16 -0400
Received: by mail-ea0-f181.google.com with SMTP id z10so478478ead.12
        for <netdev@vger.kernel.org>; Wed, 13 Mar 2013 08:14:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the typical DMVPN setup with IPv4-ESP-GRE-IPv4 stack, it seems that
IPv4 fragmentation got broke around 3.6 for forwarded packets.

It would seem that fragmentation works for locally generated packets.
Also PMTU (DF set) seems to work for both forwarded and locally
generated packets. But forwarded packets to gre device that gets IPsec
encrypted do not get fragmented properly.

3.4.x kernels work, 3.6 and 3.8 series tested and fail similarly.

I was going through the changelog and it seems that MTU is now handled
in nexthop exceptions and one needs to produce the full flow info to
update it. I'm wonding if this does not hold true in my code path as
ip_gre rewraps the forwarded packet and creates new IP header - when it
next goes to the xfrm code (which sends the ICMP error) the inner iphdr
is no longer accessible. Would this cause the breakage that I'm seeing?
Or the forward flow's mtu still updated somehow?

- Timo
