From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] inet: remove dead inetpeer sequence code
Date: Mon, 08 Sep 2014 16:43:13 -0700 (PDT)
Message-ID: <20140908.164313.327482493444735038.davem@davemloft.net>
References: <1410217714-26421-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: willemb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45781 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752856AbaIHXnQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 19:43:16 -0400
In-Reply-To: <1410217714-26421-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>
Date: Mon,  8 Sep 2014 19:08:34 -0400

> inetpeer sequence numbers are no longer incremented, so no need to
> check and flush the tree. The function that increments the sequence
> number was already dead code and removed in in "ipv4: remove unused
> function" (068a6e18). Remove the code that checks for a change, too.
> 
> Verifying that v4_seq and v6_seq are never incremented and thus that
> flush_check compares bp->flush_seq to 0 is trivial.
> 
> The second part of the change removes flush_check completely even
> though bp->flush_seq is exactly !0 once, at initialization. This
> change is correct because the time this branch is true is when
> bp->root == peer_avl_empty_rcu, in which the branch and
> inetpeer_invalidate_tree are a NOOP.
> 
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Applied, thanks a lot.
