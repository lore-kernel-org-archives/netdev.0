From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: Cache source address in nexthop entries.
Date: Tue, 08 Mar 2011 10:38:01 -0800 (PST)
Message-ID: <20110308.103801.193702247.davem@davemloft.net>
References: <20110307.205815.193699096.davem@davemloft.net>
	<alpine.LFD.2.00.1103081030090.1529@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34141
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753970Ab1CHShY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2011 13:37:24 -0500
In-Reply-To: <alpine.LFD.2.00.1103081030090.1529@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Tue, 8 Mar 2011 11:57:38 +0200 (EET)

> 	It means, even if there are addresses on the
> concerned device it does not mean the routes on this device
> are required to use prefsrc from this device. We must
> restrict the scope according to the provided for the
> route: cfg->fc_scope.

Simple to fix, I'll remember the fc_scope value in the nexthop
and use that in the address selection call.

> As the addresses have nothing to do with the link
> state, I don't think it is correct to call fib_update_nh_saddrs
> for DEV events.

fib_update_nh_saddrs() gets called for "DEV" events since those
are what are emitted when addresses are addded and removed.
