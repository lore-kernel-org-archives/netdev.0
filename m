From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 0/2] net: vrf: Fixup PKTINFO to return
 enslaved device index
Date: Wed, 11 May 2016 19:33:12 -0400 (EDT)
Message-ID: <20160511.193312.74692525355352113.davem@davemloft.net>
References: <1462904391-1253-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53005 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751793AbcEKXdO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 May 2016 19:33:14 -0400
In-Reply-To: <1462904391-1253-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Tue, 10 May 2016 11:19:49 -0700

> Applications such as OSPF and BFD need the original ingress device not
> the VRF device; the latter can be derived from the former. To that end
> move the packet intercept from an rx handler that is invoked by
> __netif_receive_skb_core to the ipv4 and ipv6 receive processing.
> 
> IPv6 already saves the skb_iif to the control buffer in ipv6_rcv. Since
> the skb->dev has not been switched the cb has the enslaved device. Make
> the same happen for IPv4 by adding the skb_iif to inet_skb_parm and set
> it in ipv4 code after clearing the skb control buffer similar to IPv6.
> From there the pktinfo can just pull it from cb with the PKTINFO_SKB_CB
> cast.

Series applied.
