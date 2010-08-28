From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] net: blackhole route should always be recalculated
Date: Sat, 28 Aug 2010 15:48:39 -0700 (PDT)
Message-ID: <20100828.154839.28807157.davem@davemloft.net>
References: <4C77DE1C.4080506@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56116
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750831Ab0H1WsX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Aug 2010 18:48:23 -0400
In-Reply-To: <4C77DE1C.4080506@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Fri, 27 Aug 2010 17:47:40 +0200

> It seems to come from commit d11a4dc18bf41719c9f0d7ed494d295dd2973b92,
> which check validy of routes. With this patch, blackhole routes are
> not recalculated (when route table is not updated).
> But this kind of routes are used when xfrm_lookup() returns -EREMOTE,
> so it seems logical to check the route again for next packets, and
> then get the right route.

Thanks Nicolas.  At first glance I think you're approach is correct,
but I will investigate things more closely to make certain of this.

Blackhole routes never had a check operation, because before the XFRM
stuff they were never expected to revalidate in the future.  But with
XFRM now they can, so we likely need to force revalidation now as your
patch does.
