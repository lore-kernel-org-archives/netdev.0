From: David Miller <davem@davemloft.net>
Subject: Re: gro: Fix use after free in tcp_gro_receive
Date: Fri, 17 Apr 2009 02:34:47 -0700 (PDT)
Message-ID: <20090417.023447.227346165.davem@davemloft.net>
References: <20090417092553.GA1601@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mwagner@redhat.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54736
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760220AbZDQJe4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 05:34:56 -0400
In-Reply-To: <20090417092553.GA1601@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 17 Apr 2009 17:25:53 +0800

> gro: Fix use after free in tcp_gro_receive
> 
> After calling skb_gro_receive skb->len can no longer be relied
> on since if the skb was merged using frags, then its pages will
> have been removed and the length reduced.
> 
> This caused tcp_gro_receive to prematurely end merging which
> resulted in suboptimal performance with ixgbe.
> 
> The fix is to store skb->len on the stack.
> 
> Reported-by: Mark Wagner <mwagner@redhat.com>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks!
