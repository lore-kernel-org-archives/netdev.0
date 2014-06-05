From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 net-next] MPLS: Use mpls_features to activate
 software MPLS GSO segmentation
Date: Thu, 05 Jun 2014 15:05:42 -0700 (PDT)
Message-ID: <20140605.150542.874543494136715316.davem@davemloft.net>
References: <1401839597-8961-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse@nicira.com, tgraf@suug.ch,
	yamamoto@valinux.co.jp, dev@openvswitch.org
To: horms@verge.net.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51295 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751306AbaFEWFn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2014 18:05:43 -0400
In-Reply-To: <1401839597-8961-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <horms@verge.net.au>
Date: Wed,  4 Jun 2014 08:53:17 +0900

> If an MPLS packet requires segmentation then use mpls_features
> to determine if the software implementation should be used.
> 
> As no driver advertises MPLS GSO segmentation this will always be
> the case.
> 
> I had not noticed that this was necessary before as software MPLS GSO
> segmentation was already being used in my test environment. I believe that
> the reason for that is the skbs in question always had fragments and the
> driver I used does not advertise NETIF_F_FRAGLIST (which seems to be the
> case for most drivers). Thus software segmentation was activated by
> skb_gso_ok().
> 
> This introduces the overhead of an extra call to skb_network_protocol()
> in the case where where CONFIG_NET_MPLS_GSO is set and
> skb->ip_summed == CHECKSUM_NONE.
> 
> Thanks to Jesse Gross for prompting me to investigate this.
> 
> Signed-off-by: Simon Horman <horms@verge.net.au>
> Acked-by: YAMAMOTO Takashi <yamamoto@valinux.co.jp>

Applied to net-next, thanks Simon.
