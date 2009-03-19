From: David Miller <davem@davemloft.net>
Subject: Re: iproute2: prints bogus hoplimit
Date: Wed, 18 Mar 2009 17:54:59 -0700 (PDT)
Message-ID: <20090318.175459.00928247.davem@davemloft.net>
References: <20090318151216.60cd0363@nehalam>
	<alpine.LSU.2.00.0903182334410.30559@fbirervta.pbzchgretzou.qr>
	<20090318162928.163a2408@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jengelh@medozas.de, stephen.hemminger@vyatta.com,
	netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43228
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754341AbZCSAzN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2009 20:55:13 -0400
In-Reply-To: <20090318162928.163a2408@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 18 Mar 2009 16:29:28 -0700

> The issue is that the hoplimit metric in ipv6 gets converted
> to -1 (if it is zero on the incoming route request)..  
> 
> int ip6_route_add(struct fib6_config *cfg)
> {
> ...
> 	  if (dst_metric(&rt->u.dst, RTAX_HOPLIMIT) == 0)
>                 rt->u.dst.metrics[RTAX_HOPLIMIT-1] = -1;
> 
> 
> What should happen is when ip6 returns the route back
> on the dump request (rt6_fill_node), it should translate the -1 back to 0
> to keep it symmetrical and logical. The metrics are unsigned.

This is how "default" is represented.

If you look, ipv4 does the same thing.
