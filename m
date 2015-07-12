From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] Revert "ipv4: use skb coalescing in
 defragmentation"
Date: Sat, 11 Jul 2015 21:17:14 -0700 (PDT)
Message-ID: <20150711.211714.1422141941490741042.davem@davemloft.net>
References: <1436571456-27905-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60392 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750736AbbGLERP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jul 2015 00:17:15 -0400
In-Reply-To: <1436571456-27905-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Sat, 11 Jul 2015 01:37:36 +0200

> This reverts commit 3cc4949269e01f39443d0fcfffb5bc6b47878d45.
> 
> There is nothing wrong with coalescing during defragmentation, it
> reduces truesize overhead and simplifies things for the receiving
> socket (no fraglist walk needed).
> 
> However, it also destroys geometry of the original fragments.
> While that doesn't cause any breakage (we make sure to not exceed largest
> original size) ip_do_fragment contains a 'fastpath' that takes advantage
> of a present frag list and results in fragments that (in most cases)
> match what was received.
> 
> In case its needed the coalescing could be done later, when we're sure
> the skb is not forwarded.  But discussion during NFWS resulted in
> 'lets just remove this for now'.
> 
> Cc: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied, thanks for following up on this.
