From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] ip6tnl/sit: drop packet if ECN present
 with not-ECT
Date: Wed, 28 Nov 2012 11:37:47 -0500 (EST)
Message-ID: <20121128.113747.1565942713593912016.davem@davemloft.net>
References: <1354021631-13602-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50239 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752071Ab2K1Qhu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 11:37:50 -0500
In-Reply-To: <1354021631-13602-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Tue, 27 Nov 2012 14:07:11 +0100

> This patch reports the change made by Stephen Hemminger in ipip and gre[6] in
> commit eccc1bb8d4b4 (tunnel: drop packet if ECN present with not-ECT).
> 
> Goal is to handle RFC6040, Section 4.2:
> 
> Default Tunnel Egress Behaviour.
>  o If the inner ECN field is Not-ECT, the decapsulator MUST NOT
>       propagate any other ECN codepoint onwards.  This is because the
>       inner Not-ECT marking is set by transports that rely on dropped
>       packets as an indication of congestion and would not understand or
>       respond to any other ECN codepoint [RFC4774].  Specifically:
> 
>       *  If the inner ECN field is Not-ECT and the outer ECN field is
>          CE, the decapsulator MUST drop the packet.
> 
>       *  If the inner ECN field is Not-ECT and the outer ECN field is
>          Not-ECT, ECT(0), or ECT(1), the decapsulator MUST forward the
>          outgoing packet with the ECN field cleared to Not-ECT.
> 
> The patch takes benefits from common function added in net/inet_ecn.h.
> 
> Like it was done for Xin4 tunnels, it adds logging to allow detecting broken
> systems that set ECN bits incorrectly when tunneling (or an intermediate
> router might be changing the header). Errors are also tracked via
> rx_frame_error.
> 
> CC: Stephen Hemminger <shemminger@vyatta.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied.
