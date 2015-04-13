From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: use jump label patching for ingress
 qdisc in __netif_receive_skb_core
Date: Mon, 13 Apr 2015 13:35:05 -0400 (EDT)
Message-ID: <20150413.133505.56878477510338170.davem@davemloft.net>
References: <66b2c2faaa0f629dd9a8c0981bf51f6484bc4ee9.1428699635.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, ast@plumgrid.com, edumazet@google.com,
	netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53154 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751996AbbDMRfH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 13:35:07 -0400
In-Reply-To: <66b2c2faaa0f629dd9a8c0981bf51f6484bc4ee9.1428699635.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Fri, 10 Apr 2015 23:07:54 +0200

> Even if we make use of classifier and actions from the egress
> path, we're going into handle_ing() executing additional code
> on a per-packet cost for ingress qdisc, just to realize that
> nothing is attached on ingress.
> 
> Instead, this can just be blinded out as a no-op entirely with
> the use of a static key. On input fast-path, we already make
> use of static keys in various places, e.g. skb time stamping,
> in RPS, etc. It makes sense to not waste time when we're assured
> that no ingress qdisc is attached anywhere.
> 
> Enabling/disabling of that code path is being done via two
> helpers, namely net_{inc,dec}_ingress_queue(), that are being
> invoked under RTNL mutex when a ingress qdisc is being either
> initialized or destructed.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

This seems reasonable.  If it is shown to slow things down or
whatever, we can revert it.

Applied, thanks Daniel.
