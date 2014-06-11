From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: fix UDP tunnel GSO of frag_list GRO packets
Date: Wed, 11 Jun 2014 00:49:04 -0700 (PDT)
Message-ID: <20140611.004904.2053967979976189800.davem@davemloft.net>
References: <1402296534-8978-1-git-send-email-weichunc@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: weichunc@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43141 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751311AbaFKHtF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 03:49:05 -0400
In-Reply-To: <1402296534-8978-1-git-send-email-weichunc@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei-Chun Chao <weichunc@plumgrid.com>
Date: Sun,  8 Jun 2014 23:48:54 -0700

> This patch fixes a kernel BUG_ON in skb_segment. It is hit when
> testing two VMs on openvswitch with one VM acting as VXLAN gateway.
> 
> During VXLAN packet GSO, skb_segment is called with skb->data
> pointing to inner TCP payload. skb_segment calls skb_network_protocol
> to retrieve the inner protocol. skb_network_protocol actually expects
> skb->data to point to MAC and it calls pskb_may_pull with ETH_HLEN.
> This ends up pulling in ETH_HLEN data from header tail. As a result,
> pskb_trim logic is skipped and BUG_ON is hit later.
> 
> Move skb_push in front of skb_network_protocol so that skb->data
> lines up properly.
 ...
> Signed-off-by: Wei-Chun Chao <weichunc@plumgrid.com>

Applied, thank you.
