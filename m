From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] mpls: fix sending of local encapped packets
Date: Mon, 07 Dec 2015 16:33:27 -0500 (EST)
Message-ID: <20151207.163327.128104390576260749.davem@davemloft.net>
References: <56656219.7070009@brocade.com>
	<1449492795-12406-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	ebiederm@xmission.com, sam.h.russell@gmail.com
To: rshearma@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50904 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755881AbbLGVd2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 16:33:28 -0500
In-Reply-To: <1449492795-12406-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Shearman <rshearma@brocade.com>
Date: Mon, 7 Dec 2015 12:53:15 +0000

> Locally generated IPv4 and (probably) IPv6 packets are dropped because
> skb->protocol isn't set. We could write wrappers to lwtunnel_output
> for IPv4 and IPv6 that set the protocol accordingly and then call
> lwtunnel_output, but mpls_output relies on the AF-specific type of dst
> anyway to get the via address.
> 
> Therefore, make use of dst->dst_ops->family in mpls_output to
> determine the type of nexthop and thus protocol of the packet instead
> of checking skb->protocol.
> 
> Fixes: 61adedf3e3f1 ("route: move lwtunnel state to dst_entry")
> Reported-by: Sam Russell <sam.h.russell@gmail.com>
> Signed-off-by: Robert Shearman <rshearma@brocade.com>

Applied, thanks.
