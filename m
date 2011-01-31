From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Add default_mtu() methods to blackhole dst_ops
Date: Mon, 31 Jan 2011 13:15:18 -0800 (PST)
Message-ID: <20110131.131518.39181100.davem@davemloft.net>
References: <87fws8zsit.fsf@shaolin.home.digitalvampire.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roland@digitalvampire.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43601
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756002Ab1AaVOn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Jan 2011 16:14:43 -0500
In-Reply-To: <87fws8zsit.fsf@shaolin.home.digitalvampire.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roland Dreier <roland@digitalvampire.org>
Date: Mon, 31 Jan 2011 13:12:58 -0800

> From: Roland Dreier <roland@purestorage.com>
> 
> When an IPSEC SA is still being set up, __xfrm_lookup() will return
> -EREMOTE and so ip_route_output_flow() will return a blackhole route.
> This can happen in a sndmsg call, and after d33e455337ea ("net: Abstract
> default MTU metric calculation behind an accessor.") this leads to a
> crash in ip_append_data() because the blackhole dst_ops have no
> default_mtu() method and so dst_mtu() calls a NULL pointer.
> 
> Fix this by adding default_mtu() methods (that simply return 0, matching
> the old behavior) to the blackhole dst_ops.
> 
> The IPv4 part of this patch fixes a crash that I saw when using an IPSEC
> VPN; the IPv6 part is untested because I don't have an IPv6 VPN, but it
> looks to be needed as well.
> 
> Signed-off-by: Roland Dreier <roland@purestorage.com>

Thanks so much for tracking this down and fixing it.  I was going to look
at your traces and report later today.

I'll apply this, thanks again Roland.
