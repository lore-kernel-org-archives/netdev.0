From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] geneve: avoid use-after-free of skb->data
Date: Fri, 02 Dec 2016 14:09:25 -0500 (EST)
Message-ID: <20161202.140925.1784959728501874377.davem@davemloft.net>
References: <027c88dd060f5ca4535cb346db125829b2181a88.1480675406.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linville@tuxdriver.com
To: sd@queasysnail.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39304 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752954AbcLBTTi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 14:19:38 -0500
In-Reply-To: <027c88dd060f5ca4535cb346db125829b2181a88.1480675406.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sabrina Dubroca <sd@queasysnail.net>
Date: Fri,  2 Dec 2016 16:49:29 +0100

> geneve{,6}_build_skb can end up doing a pskb_expand_head(), which
> makes the ip_hdr(skb) reference we stashed earlier stale. Since it's
> only needed as an argument to ip_tunnel_ecn_encap(), move this
> directly in the function call.
> 
> Fixes: 08399efc6319 ("geneve: ensure ECN info is handled properly in all tx/rx paths")
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>

Applied and queued up for -stable, thanks.

This bug happens so many times that I think it might be time for
a debugging mode for pskb_expand_head() that unconditionally
reallocates the skb->data buffer regardless of whether it's
necessary or not and somehow unmaps the previous buffer to
force a trap on stale pointers.

Better ideas welcome, of course :)
