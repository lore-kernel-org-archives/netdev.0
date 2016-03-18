From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next repost] openvswitch: allow output of MPLS
 packets on tunnel vports
Date: Fri, 18 Mar 2016 18:27:56 -0400 (EDT)
Message-ID: <20160318.182756.572852383155549595.davem@davemloft.net>
References: <1458010835-18555-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pshelar@ovn.org, jesse@kernel.org, netdev@vger.kernel.org,
	dev@openvswitch.org
To: simon.horman@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55572 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751207AbcCRW16 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2016 18:27:58 -0400
In-Reply-To: <1458010835-18555-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <simon.horman@netronome.com>
Date: Tue, 15 Mar 2016 12:00:35 +0900

> Currently output of MPLS packets on tunnel vports is not allowed by Open
> vSwitch. This is because historically encapsulation was done in such a way
> that the inner_protocol field of the skb needed to hold the inner protocol
> for both MPLS and tunnel encapsulation in order for GSO segmentation to be
> performed correctly.
> 
> Since b2acd1dc3949 ("openvswitch: Use regular GRE net_device instead of
> vport") Open vSwitch makes use of lwt to output to tunnel netdevs which
> perform encapsulation. As no drivers expose support for MPLS offloads this
> means that GSO packets are segmented in software by validate_xmit_skb(),
> which is called from __dev_queue_xmit(), before tunnel encapsulation occurs.
> This means that the inner protocol of MPLS is no longer needed by the time
> encapsulation occurs and the contention on the inner_protocol field of the
> skb no longer occurs.
> 
> Thus it is now safe to output MPLS to tunnel vports.
> 
> Signed-off-by: Simon Horman <simon.horman@netronome.com>

Applied, thanks.
