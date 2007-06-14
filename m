From: David Miller <davem@davemloft.net>
Subject: Re: [IPV6] addrconf: Fix IPv6 on tuntap tunnels
Date: Thu, 14 Jun 2007 13:03:58 -0700 (PDT)
Message-ID: <20070614.130358.90120374.davem@davemloft.net>
References: <20070614081607.GA22931@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	koster@debian.org.tw, socketcan@hartkopp.net, urs@isnogud.escape.de
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34131
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751360AbXFNUEE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jun 2007 16:04:04 -0400
In-Reply-To: <20070614081607.GA22931@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 14 Jun 2007 18:16:07 +1000

> [IPV6] addrconf: Fix IPv6 on tuntap tunnels
> 
> The recent patch that added ipv6_hwtype is broken on tuntap tunnels.
> Indeed, it's broken on any device that does not pass the ipv6_hwtype
> test.
> 
> The reason is that the original test only applies to autoconfiguration,
> not IPv6 support.  IPv6 support is allowed on any device.  In fact,
> even with the ipv6_hwtype patch applied you can still add IPv6 addresses
> to any interface that doesn't pass thw ipv6_hwtype test provided that
> they have a sufficiently large MTU.  This is a serious problem because
> come deregistration time these devices won't be cleaned up properly.
> 
> I've gone back and looked at the rationale for the patch.  It appears
> that the real problem is that we were creating IPv6 devices even if the
> MTU was too small.  So here's a patch which fixes that and reverts the
> ipv6_hwtype stuff.
> 
> Thanks to Kanru Chen for reporting this issue.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks for fixing this up Herbert.

Patch applied.
