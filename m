From: Wilco Baan Hofman <wilco@baanhofman.nl>
Subject: Re: /128 link-local subnet on 6in4 (sit) tunnels?
Date: Wed, 27 Mar 2013 16:37:53 +0100
Message-ID: <1364398673.21709.4.camel@localhost>
References: <1364335457.8215.21.camel@localhost>
	 <20130327151210.GA23223@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 37-251-2-65.FTTH.ispfabriek.nl ([37.251.2.65]:54867 "EHLO
	mail.baanhofman.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751837Ab3C0PiN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 11:38:13 -0400
In-Reply-To: <20130327151210.GA23223@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 2013-03-27 at 16:12 +0100, Hannes Frederic Sowa wrote:
> On Tue, Mar 26, 2013 at 11:04:17PM +0100, Wilco Baan Hofman wrote:
> > So I was wondering, is there any particular reason for the use of a /128
> > link-local or is this just a bug?
> 
> Can you show me the commands how you set up the tunnel. It does create /64 ll
> with embedded ipv4 addresses for me here on v3.8.
> 

Weird, but sure, here goes:

ip tunnel add tunv6-uplink1 mode sit remote 192.168.1.1 local
192.168.1.21
ip link set tunv6-uplink1 up mtu 1472


Also, this patch seems to fix it:

--- linux-3.8.3.orig/net/ipv6/addrconf.c
+++ linux-3.8.3/net/ipv6/addrconf.c
@@ -2487,7 +2487,7 @@ static void sit_add_v4_addrs(struct inet
 	}
 
 	if (addr.s6_addr32[3]) {
-		add_addr(idev, &addr, 128, scope);
+		add_addr(idev, &addr, 64, scope);
 		return;
 	}

-- Wilco
