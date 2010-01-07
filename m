From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] ip: fix mc_loop checks for tunnels with
 multicast outer addresses
Date: Wed, 06 Jan 2010 20:37:18 -0800 (PST)
Message-ID: <20100106.203718.180097165.davem@davemloft.net>
References: <200912302201.37735.opurdila@ixiacom.com>
	<20100103.215855.267134875.davem@davemloft.net>
	<201001041248.26095.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: opurdila@ixiacom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53965
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932411Ab0AGEhK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2010 23:37:10 -0500
In-Reply-To: <201001041248.26095.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Octavian Purdila <opurdila@ixiacom.com>
Date: Mon, 4 Jan 2010 12:48:25 +0200

> On Monday 04 January 2010 07:58:55 you wrote:
> 
>> This won't compile with IPV6 disabled.  Switch closing brace is
>> erroneously inside of the ifdef test.
>> 
> 
> Oops... Here is a new version:
> 
> [PATCH] ip: fix mc_loop checks for tunnels with multicast outer addresses
> 
> When we have L3 tunnels with different inner/outer families
> (i.e. IPV4/IPV6) which use a multicast address as the outer tunnel
> destination address, multicast packets will be loopbacked back to the
> sending socket even if IP*_MULTICAST_LOOP is set to disabled.
> 
> The mc_loop flag is present in the family specific part of the socket
> (e.g. the IPv4 or IPv4 specific part).  setsockopt sets the inner
> family mc_loop flag. When the packet is pushed through the L3 tunnel
> it will eventually be processed by the outer family which if different
> will check the flag in a different part of the socket then it was set.
> 
> Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>

Applied to net-2.6, thanks!
