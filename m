From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] macvlan: fix leak in macvlan_handle_frame
Date: Mon, 16 Nov 2015 17:07:38 -0500 (EST)
Message-ID: <20151116.170738.762655257161553595.davem@davemloft.net>
References: <d4141a7c4841ae5f631858a8537968419f0e396b.1447705984.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us, kaber@trash.net
To: sd@queasysnail.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42428 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752706AbbKPWHl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2015 17:07:41 -0500
In-Reply-To: <d4141a7c4841ae5f631858a8537968419f0e396b.1447705984.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sabrina Dubroca <sd@queasysnail.net>
Date: Mon, 16 Nov 2015 22:54:20 +0100

> Reset pskb in macvlan_handle_frame in case skb_share_check returned a
> clone.
> 
> Fixes: 8a4eb5734e8d ("net: introduce rx_handler results and logic around that")
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>

Thanks for finding all of these bugs which seem to have the same
signature.

I always find pass by reference handling of SKBs to be extremely error
prone, and it's a very inefficient calling convention anyways.

I wondered if we could do better with the interface for rx_handler,
for example returning an error-pointer for the 'new_skb', but nothing
I came up with could provide the same semantics we have now.

Sigh...
