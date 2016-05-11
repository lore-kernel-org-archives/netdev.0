From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net] openvswitch: Fix cached ct with helper.
Date: Wed, 11 May 2016 15:15:59 -0400 (EDT)
Message-ID: <20160511.151559.438965239616890068.davem@davemloft.net>
References: <1462987766-5151-1-git-send-email-joe@ovn.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jarno@ovn.org
To: joe@ovn.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51622 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751413AbcEKTQF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 May 2016 15:16:05 -0400
In-Reply-To: <1462987766-5151-1-git-send-email-joe@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Stringer <joe@ovn.org>
Date: Wed, 11 May 2016 10:29:26 -0700

> When using conntrack helpers from OVS, a common configuration is to
> perform a lookup without specifying a helper, then go through a
> firewalling policy, only to decide to attach a helper afterwards.
> 
> In this case, the initial lookup will cause a ct entry to be attached to
> the skb, then the later commit with helper should attach the helper and
> confirm the connection. However, the helper attachment has been missing.
> If the user has enabled automatic helper attachment, then this issue
> will be masked as it will be applied in init_conntrack(). It is also
> masked if the action is executed from ovs_packet_cmd_execute() as that
> will construct a fresh skb.
> 
> This patch fixes the issue by making an explicit call to try to assign
> the helper if there is a discrepancy between the action's helper and the
> current skb->nfct.
> 
> Fixes: cae3a2627520 ("openvswitch: Allow attaching helpers to ct action")
> Signed-off-by: Joe Stringer <joe@ovn.org>
> ---
> v2: Only apply to connections that we will commit.

Applied and queued up for -stable, thanks.
